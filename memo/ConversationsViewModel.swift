import SwiftUI

class ConversationsViewModel: ObservableObject {
    @Published var recentMessages = [Message]()
    private var recentMessagesDictionary = [String: Message]()
    
    //@Binding var loading:Bool
        
    init() {
        fetchRecentMessages()
        print("aaaaa")
    }
    
    
    // 最新のメッセージ一覧をとってくる（トリガー処理）
    func fetchRecentMessages() {
        
        //self.loading = true
        
        guard let uid = AuthViewModel.shared.userSession?.uid else { return }
        let query = COLLECTION_MESSAGES.document(uid).collection("recent-messages")
        query.order(by: "timestamp", descending: true)
        
        // query結果に対してデータ取得
        query.getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }

            documents.forEach { document in
                let uid = document.documentID
                guard var message = try? document.data(as: Message.self) else { return }
                
                COLLECTION_USERS.document(uid).getDocument { snapshot, _ in
                    print(snapshot)
                    guard let user = try? snapshot?.data(as: User.self) else { return }
                    print(user)
                    message.user = user
                    self.recentMessagesDictionary[uid] = message
                    self.recentMessages = Array(self.recentMessagesDictionary.values)
                        .sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() })
                }
            }
            
        }
        
        //self.loading = false
        
    }
    
    
    
    // イベントリスナーのデータ取得を行う。
    func fetchRecentMessages2(){
        
        guard let uid = AuthViewModel.shared.userSession?.uid else { return }
        
        COLLECTION_MESSAGES.document(uid).collection("recent-messages").addSnapshotListener { (documentSnapshot, error) in
            guard let documentSnapshot = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }

            documentSnapshot.documentChanges.forEach{ diff in

                guard let user = try? diff.document.data(as: User.self) else { return }  // ここでデータが取得できずreturnになる
                guard var message = try? diff.document.data(as: Message.self) else { return }
                message.user = user
                self.recentMessagesDictionary[uid] = message
                self.recentMessages = Array(self.recentMessagesDictionary.values)
                    .sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() })
            }
        }
        
        print(self.recentMessages)
    }
    
    
}

import SwiftUI

// 新しくメッセージをやり取りするユーザーを追加する画面（＋ボタンをクリックした時の）
struct NewMessageView: View {
    @State var searchText = ""
    @State var isEditing = false
    @Binding var show: Bool
    @Binding var startChat: Bool
    @Binding var user: User?
    @ObservedObject var viewModel = NewMessageViewModel(config: .chat)
    
    var body: some View {
        
        ScrollView {
            SearchBar(text: $searchText, isEditing: $isEditing)
                .onTapGesture {isEditing.toggle() }
                .padding()

            VStack(alignment: .leading) {
                ForEach(searchText.isEmpty ? viewModel.users : viewModel.filteredUsers(searchText)) { user in
                    HStack { Spacer() }
                    
                    // ここのbuttonが親ViewとなるConversationsViewのプロパティ更新走って、そこで再度body更新となって表示されてるんかな？
                    Button(action: {
                        //self.show.toggle()   // こいつが原因だった。showによってsheetを閉じるが、これはconversationsviewのbodyの中でこれを更新する必要がある。となるとViewを再構築しないといけなくなるので、おかしな挙動。実際に裏ではchatViewに遷移しているけど、sheetは閉じてない。これを閉じるとbodyを更新することになり、強制的に戻される
                        self.startChat.toggle()  //コメントアウトするとこいつが悪さしてる気がする。上のshowも関連。これによって確かにchatviewが表示されるが、conversationsviewも更新されてそれで再構築で表示されてる。
                        self.user = user
                    }, label: {
                        UserCell(user: user)
                    })
                }
            }.padding(.leading)
        }
    }
}

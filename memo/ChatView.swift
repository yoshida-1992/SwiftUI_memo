import SwiftUI
import Dispatch

// 各メッセージ（ユーザーとのやり取り）の中の画面
struct ChatView: View {
    let user: User
    @ObservedObject var viewModel: ChatViewModel
    @State private var messageText: String = ""
    @State private var selectedImage: UIImage?
        
    init(user: User) {
        self.user = user
        self.viewModel = ChatViewModel(user: user)
    }
    
    var body: some View {
        VStack {
            ScrollViewReader { value in
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            MessageView(viewModel: MessageViewModel(message: message))
                                .id(message.id)
                        }
                    }.padding(.top)
                }
                .onReceive(viewModel.$messageToSetVisible, perform: { id in
                    value.scrollTo(id)
                })
            }
                        
            CustomInputView(inputText: $messageText,
                            selectedImage: $selectedImage,
                            action: sendMessage)
                .padding()
        }
        .navigationTitle(user.username)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // 送信処理
    func sendMessage() {
        if let image = selectedImage {
            viewModel.send(type: .image(image))
            selectedImage = nil
        } else {
            viewModel.send(type: .text(messageText))
            messageText = ""
        }
    }
}

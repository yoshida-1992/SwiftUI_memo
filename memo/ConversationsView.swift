import SwiftUI


// メッセージ画面のユーザー一覧
struct ConversationsView: View {
    @State var isShowingNewMessageView = false
    @State var showChat = false
    @State var user: User?
        
    @ObservedObject var viewModel = ConversationsViewModel()
    

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
 
            if let user = user {
                // 新規メッセージをしたら、userが追加されるので、それでここから表示。isActiveがtrueになり表示されるが、showChatが更新されるので、ConversationsViewが再表示される（戻される）
                var _ = print("testYoshida1111111111111111")
                NavigationLink(destination: LazyView(ChatView(user: user)),
                               isActive: $showChat,
                               label: {} )
            }
            
            ScrollView {
                VStack {
                    ForEach(viewModel.recentMessages) { message in
                        if let user = message.user {
                            NavigationLink(
                                destination:
                                    LazyView(ChatView(user: user))
                                    .onDisappear(perform: {
                                        viewModel.fetchRecentMessages()
                                    }),
                                label: {
                                    ConversationCell(viewModel: MessageViewModel(message: message))
                                })
                        }
                    }
                }.padding()
            }
            
            HStack {
                Spacer()
                // 新規メッセージ追加用ボタン（sheetでnewMessageViewを表示してる）
                FloatingButton(show: $isShowingNewMessageView)
                    .sheet(isPresented: $isShowingNewMessageView, content: {
                        NewMessageView(show: $isShowingNewMessageView,
                                       startChat: $showChat,
                                       user: $user
                        )
                    })
            }
            .navigationTitle("メッセージ")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

/*struct ConversationsView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationsView()
    }
}*/

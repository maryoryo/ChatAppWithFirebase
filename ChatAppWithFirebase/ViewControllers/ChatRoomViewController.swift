//
//  ChatRoomViewController.swift
//  ChatAppWithFirebase
//
//  Created by 清藤凌真 on 2023/01/15.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class ChatRoomViewController: UIViewController {

    @IBOutlet weak var chatRoomTableView: UITableView!
    
    // 引き継ぎパラメータ
    var user: User?
    var chatroom: ChatRoom?
    
    private let cellId = "cellId"
    private var messages = [Message]()
    
    private let accessoryHeight: CGFloat = 100
    private var safeAreaBottom: CGFloat {
        get {
            // safeAreaのボトムが認識された（値が入ってきた）タイミングでこのプロパティに値が入る
            self.view.safeAreaInsets.bottom
        }
    }
    
    // chatInputAccessoryViewのインスタンス化
    private lazy var chatInputAccessoryView: ChatInputAccessoryView = {
        let view = ChatInputAccessoryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: accessoryHeight)
        view.delegate = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNotification()
        setupChatRoomTableView()
        fetchMessages()
    }
    
    // TableViewの表示処理
    private func setupChatRoomTableView() {
        chatRoomTableView.delegate = self
        chatRoomTableView.dataSource = self
        chatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        chatRoomTableView.backgroundColor = .rgb(red: 118, green: 140, blue: 188)
        // チャット欄の下から距離をとる
        chatRoomTableView.contentInset = .init(top: 60, left: 0, bottom: 0, right: 0)
        // チャット欄のスクロールバーの下から距離をとる
        chatRoomTableView.scrollIndicatorInsets = .init(top: 60, left: 0, bottom: 0, right: 0)
        chatRoomTableView.keyboardDismissMode = .interactive
        chatRoomTableView.transform = CGAffineTransform(1, 0, 0, -1, 0, 0)
    }
    
    private func setupNotification() {
        // 端末キーボードが表示された時の処理
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        // 端末キーボードが非表示になった時の処理
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
            
            if keyboardFrame.height <= accessoryHeight { return }
            
            let top = keyboardFrame.height - safeAreaBottom
            var moveY = -(top - chatRoomTableView.contentOffset.y)
            if chatRoomTableView.contentOffset.y != -60 { moveY += 60 }
            let contentInset = UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0)
            
            chatRoomTableView.contentInset = contentInset
            chatRoomTableView.scrollIndicatorInsets = contentInset
            chatRoomTableView.contentOffset = CGPoint(x: 0, y: moveY)
        }
    }
    @objc private func keyboardWillHide() {
        chatRoomTableView.contentInset = .init(top: 60, left: 0, bottom: 0, right: 0)
        chatRoomTableView.scrollIndicatorInsets = .init(top: 60, left: 0, bottom: 0, right: 0)
    }
    
    // ChatRoom下部のメッセージ入力に必要な定義
    override var inputAccessoryView: UIView? {
        get {
            return chatInputAccessoryView
        }
    }
    // ChatRoom下部のメッセージ入力に必要な定義
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // FireStoreからのメッセージやりとりの内容を反映
    private func fetchMessages() {
        guard let chatroomDocId = chatroom?.documentId else { return }
        Firestore.firestore().collection("chatRooms").document(chatroomDocId).collection("messages").addSnapshotListener({ (snapshots, error) in
            if let error = error {
                print("メッセージ情報の取得に失敗しました：\(error)")
                return
            }
            snapshots?.documentChanges.forEach({ (documetChange) in
                switch documetChange.type {
                case .added:
                    let dic = documetChange.document.data()
                    let message = Message(dic: dic)
                    message.pertnerUser = self.chatroom?.pertnerUser
                    
                    self.messages.append(message)
                    self.messages.sort { (m1, m2) -> Bool in
                        let m1Date = m1.createdAt.dateValue()
                        let m2Date = m2.createdAt.dateValue()
                        return m1Date > m2Date
                    }
                    
                    self.chatRoomTableView.reloadData()
//                    self.chatRoomTableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: false)
                    
                case.modified, .removed:
                    print("nothing to do")
                }
                
            })
        })
    }
}

// 送信ボタン押下時の処理（デリゲート）
extension ChatRoomViewController: ChatInputAccessoryViewDelegate {
    
    func tappedSendButton(text: String) {
        addMessageToFirestore(text: text)
        
    }
    
    private func addMessageToFirestore(text: String) {
        guard let chatroomDocId = chatroom?.documentId else { return }
        guard let name = user?.username else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        chatInputAccessoryView.removeText()
        
        let messageId = randomString(length: 20)
        
        let docData = [
            "name": name,
            "createdAt": Timestamp(),
            "uid": uid,
            "message": text
        ] as [String : Any]
        
        Firestore.firestore().collection("chatRooms").document(chatroomDocId).collection("messages").document(messageId).setData(docData) { (error) in
            if let error = error {
                print("メッセージ情報の保存に失敗しました：\(error)")
                return
            }
            let latestMessageData = [
                "latestMessageId": messageId
            ]
            
            Firestore.firestore().collection("chatRooms").document(chatroomDocId).updateData(latestMessageData) { (error) in
                if let error = error  {
                    print("最新メッセージの保存に失敗しました：\(error)")
                }
                print("メッセージの保存に成功しました")
            }
        }
    }
    
    // ランダムなIDを生成
    func randomString(length: Int) -> String {
        let letters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len: UInt32 = UInt32((letters.length))
        
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
}

// ChatRoomのメッセージのTableView
extension ChatRoomViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! ChatRoomTableViewCell
//        cell.messageTextView.text = messages[indexPath.row]
        cell.messageText = messages[indexPath.row]
        cell.transform = CGAffineTransform(1, 0, 0, -1, 0, 0)

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        chatRoomTableView.estimatedRowHeight = 20
        return UITableView.automaticDimension
    }
}

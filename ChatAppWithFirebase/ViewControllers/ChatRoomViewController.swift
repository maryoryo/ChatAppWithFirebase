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
    
    var user: User?
    var chatroom: ChatRoom?
    
    private let cellId = "cellId"
    private var messages = [Message]()
    
    // chatInputAccessoryViewのインスタンス化
    private lazy var chatInputAccessoryView: ChatInputAccessoryView = {
        let view = ChatInputAccessoryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 100)
        view.delegate = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        chatRoomTableView.delegate = self
        chatRoomTableView.dataSource = self
        chatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        chatRoomTableView.backgroundColor = .rgb(red: 118, green: 140, blue: 188)
        
        fetchMessages()
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
                    self.messages.append(message)
                    self.chatRoomTableView.reloadData()
                    
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

        guard let chatroomDocId = chatroom?.documentId else { return }
        guard let name = user?.username else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        chatInputAccessoryView.removeText()
        
        let docData = [
            "name": name,
            "createdAt": Timestamp(),
            "uid": uid,
            "message": text
        ] as [String : Any]
        
        Firestore.firestore().collection("chatRooms").document(chatroomDocId).collection("messages").document().setData(docData) { (error) in
            if let error = error {
                print("メッセージ情報の保存に失敗しました：\(error)")
                return
            }
            print("メッセージの保存に成功しました")
        }
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        chatRoomTableView.estimatedRowHeight = 20
        return UITableView.automaticDimension
    }
}

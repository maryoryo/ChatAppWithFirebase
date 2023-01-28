//
//  ChatListViewController.swift
//  ChatAppWithFirebase
//
//  Created by 清藤凌真 on 2023/01/14.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Nuke

class ChatListViewController: UIViewController {

    @IBOutlet weak var chatListTableView: UITableView!
    
    private let cellId = "cellId"
    private var user: User? {
        // ユーザー情報が入ったらタイトルを設定
        didSet {
            navigationItem.title = user?.username
        }
    }
    private var chatrooms = [ChatRoom]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        confirmLoggedInUser()
        fetchLoginUserInfo()
        fetchChatroomsInfoFromFirebase()

    }
    
    // FireStoreからチャットルームの情報を取得する
    private func fetchChatroomsInfoFromFirebase() {
        Firestore.firestore().collection("chatRooms")
        // リアルタイムで情報を変更させる
            .addSnapshotListener{ (snapshots, error) in
                // .getDocuments(completion: { (snapshots, error) in
                if let error = error {
                    print("チャットルーム情報の取得に失敗しました：\(error)")
                    return
                }
                snapshots?.documentChanges.forEach({ (documentChange) in
                    switch documentChange.type {
                    case .added:
                        self.handleAddedDocumentChange(documentChange: documentChange)
                    case .modified, .removed:
                        print("nothing to do")
                    }
                })
                
            }
    }
    
    // Firebaseにリアルタイムで更新された時に追加で反映する処理
    private func handleAddedDocumentChange(documentChange: DocumentChange) {
        let dic = documentChange.document.data()
        let chatroom = ChatRoom(dic: dic)
        chatroom.documentId = documentChange.document.documentID
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        chatroom.members.forEach({ (memberUid) in
            if memberUid != uid {
                Firestore.firestore().collection("users").document(memberUid).getDocument(completion: { (snapshot, error) in
                    if let error = error {
                        print("ユーザー情報の取得に失敗しました：\(error)")
                        return
                    }
                    guard let dic = snapshot?.data() else { return }
                    let user = User(dic: dic)
                    user.uid = snapshot?.documentID
                    
                    chatroom.pertnerUser = user
                    
                    print("ユーザー情報の取得に成功しました")
                    self.chatrooms.append(chatroom)
                    print("self.chatrooms.count: \(self.chatrooms.count)")
                    self.chatListTableView.reloadData()
                })
            }
        })
    }
    
    // チャットリストのviewを設定
    private func setupViews() {
        // ナビゲーションバーの背景色と文字色変更
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .rgb(red: 39, green: 49, blue: 69)
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        self.navigationItem.title = "トーク"
        self.navigationController?.navigationBar.standardAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        self.navigationController?.navigationBar.scrollEdgeAppearance?.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]

        chatListTableView.tableFooterView = UIView()
        chatListTableView.delegate = self
        chatListTableView.dataSource = self
        
        // 会話相手を追加するボタン
        let rightBarButton = UIBarButtonItem(title: "新規チャット", style: .plain, target: self, action: #selector(tappedNavRightBarButton))
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
    
    // ログイン済みかどうかを判定
    private func confirmLoggedInUser() {
        if Auth.auth().currentUser?.uid == nil {
            let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "SignUpViewController")
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
        
    @objc private func tappedNavRightBarButton() {
        let storyboard = UIStoryboard.init(name: "UserList", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "UserListViewController")
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
    }
    
    // 現在ログインしているユーザーの情報を反映
    private func fetchLoginUserInfo() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(uid).getDocument(completion: { (snapshot, error) in
            if let error = error {
                print("ユーザー情報の取得に失敗しました：\(error)")
                return
            }
            guard let snapshot = snapshot, let dic = snapshot.data() else { return }
            
            let user = User(dic: dic)
            
            self.user = user
        })
    }
    
//    // FirebaseStoreに保存されているデータを反映
//    private func fetchUserInfoFromFirebase() {
//        Firestore.firestore().collection("users").getDocuments(completion: { (snapshots, error) in
//            if let error = error {
//                print("User情報の取得に失敗しました：\(error)")
//                return
//            }
//            snapshots?.documents.forEach({ (snapshot) in
//                let data = snapshot.data()
//                // Userのデータに変換
//                let user = User(dic: data)
//
//                self.users.append(user)
//                self.chatListTableView.reloadData()
//
//                self.users.forEach { (user) in
//                    print("username: \(user.username)")
//                }
//
//            })
//        })
//    }
}

// チャットリストのTableView
extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatrooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatListTableViewCell
        cell.chatroom = chatrooms[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "ChatRoom", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ChatRoomViewController") as! ChatRoomViewController
        vc.user = user
        vc.chatroom = chatrooms[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

class ChatListTableViewCell: UITableViewCell {
    
//    var user: User? {
//        didSet {
//            if let user = user {
//                pertnerLabel.text = user.username
//    //            userImageView.image = user.profileImageUrl
//                dateLabel.text = dataFormatterForDateLabel(date: user.createdAt.dateValue())
//                latestMessageLabel.text = user.email
//            }
//        }
//    }
    var chatroom: ChatRoom? {
        didSet {
            if let chatroom = chatroom {
                pertnerLabel.text = chatroom.pertnerUser?.username
                
                guard let url = URL(string: chatroom.pertnerUser?.profileImageUrl ?? "") else { return }
                Nuke.loadImage(with: url, into: userImageView)
                
                dateLabel.text = dataFormatterForDateLabel(date: chatroom.createdAt.dateValue())
            }
        }
    }
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var latestMessageLabel: UILabel!
    @IBOutlet weak var pertnerLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = 30
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // メッセージの最終更新時間
    private func dataFormatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
//        formatter.dateFormat = "hh:mm"
        formatter.locale = Locale(identifier: "ja-JP")
//        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        return formatter.string(from: date)
    }
    
}

//
//  UserListViewController.swift
//  ChatAppWithFirebase
//
//  Created by 清藤凌真 on 2023/01/21.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Nuke

class UserListViewController: UIViewController {

    @IBOutlet weak var userListTableView: UITableView!
    @IBOutlet weak var startChatButton: UIButton!
    
    private var users = [User]()
    private let cellId = "cellId"
    private var selectedUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userListTableView.tableFooterView = UIView()
        userListTableView.delegate = self
        userListTableView.dataSource = self
        
        startChatButton.layer.cornerRadius = 15
        startChatButton.isEnabled = false
        // 会話を開始ボタンを押下した時の処理
        startChatButton.addTarget(self, action: #selector(tappedStartChatButton), for: .touchUpInside)
        
        navigationController?.navigationBar.tintColor = .rgb(red: 39, green: 49, blue: 69)

        fetchUserInfoFromFirebase()
    }
    
    @objc func tappedStartChatButton() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let partnerUid = self.selectedUser?.uid else { return }
        let members = [uid, partnerUid]

        let docData = [
            "members": members,
            "latestMessageId": "",
            "createdAt": Timestamp()
        ] as [String : Any]
        
        Firestore.firestore().collection("chatRooms").addDocument(data: docData, completion: { (error) in
            if let error = error {
                print("ChatRoom情報の保存に失敗しました：\(error)")
                return
            }
            self.dismiss(animated: true, completion: nil)
            print("ChatRoom情報の保存に成功しました")
        })
    }
    
    // FirebaseStoreに保存されているデータを反映
    private func fetchUserInfoFromFirebase() {
        Firestore.firestore().collection("users").getDocuments(completion: { (snapshots, error) in
            if let error = error {
                print("User情報の取得に失敗しました：\(error)")
                return
            }
            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                // Userのデータに変換
                let user = User(dic: dic)
                
                // 会話相手のuidをセット
                user.uid = snapshot.documentID
                
                guard let uid = Auth.auth().currentUser?.uid else { return }
                
                // 現在ログインしているユーザーは表示させない
                if uid == snapshot.documentID {
                    return
                }
                self.users.append(user)
                self.userListTableView.reloadData()
            })
        })
    }
}

// 会話相手のTableViewを表示
extension UserListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserListTableViewCell
        cell.user = users[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        startChatButton.isEnabled = true
        let user = users[indexPath.row]
        self.selectedUser = user
        print("user: \(user.username)")
    }
}

// TableViewCellの情報
class UserListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    var user: User? {
        didSet {
            usernameLabel.text = user?.username
            if let url = URL(string: user?.profileImageUrl ?? "") {
                Nuke.loadImage(with: url, into: userImageView, completion: nil)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.layer.cornerRadius = 32.5
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}

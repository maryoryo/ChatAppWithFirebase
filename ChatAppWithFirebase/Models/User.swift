//
//  User.swift
//  ChatAppWithFirebase
//
//  Created by 清藤凌真 on 2023/01/21.
//

import Foundation
import Firebase
import FirebaseFirestore

class User {
    let email: String
    let username: String
    let createdAt: Timestamp
    let profileImageUrl: String
    
    var uid: String?
    
    init(dic: [String: Any]) {
        self.email = dic["email"] as? String ?? ""
        self.username = dic["username"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.profileImageUrl = dic["profileImageUrl"] as? String ?? ""
    }
}

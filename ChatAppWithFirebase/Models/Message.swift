//
//  Message.swift
//  ChatAppWithFirebase
//
//  Created by 清藤凌真 on 2023/01/28.
//

import Foundation
import Firebase
import FirebaseFirestore

class Message {
    let name: String
    let message: String
    let uid: String
    let createdAt: Timestamp
    
    var pertnerUser: User?
    
    init(dic: [String:Any]) {
        self.name = dic["name"] as? String ?? ""
        self.message = dic["message"] as? String ?? ""
        self.uid = dic["uid"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
    }
}

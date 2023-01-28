//
//  ChatRoom.swift
//  ChatAppWithFirebase
//
//  Created by 清藤凌真 on 2023/01/22.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseFirestore

class ChatRoom {
    
    let latestMessageId: String
    let members: [String]
    let createdAt: Timestamp
    
    var documentId: String?
    var pertnerUser: User?
    
    init(dic: [String: Any]) {
        self.latestMessageId = dic["latestMessageId"] as? String ?? ""
        self.members = dic["members"] as? [String] ?? [String]()
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
    }
    
}

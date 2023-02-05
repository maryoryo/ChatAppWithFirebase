//
//  ChatRoomTableViewCell.swift
//  ChatAppWithFirebase
//
//  Created by 清藤凌真 on 2023/01/15.
//

import UIKit
import Firebase
import FirebaseAuth
import Nuke

class ChatRoomTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var pertnerMessageTextView: UITextView!
    @IBOutlet weak var pertnerDateLabel: UILabel!
    @IBOutlet weak var myMessageTextView: UITextView!
    @IBOutlet weak var myDateLabel: UILabel!
    @IBOutlet weak var pertnerMessageTextViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var myMessageTextViewWidthConstraint: NSLayoutConstraint!
    
    var messageText: Message?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        userImageView.layer.cornerRadius = 30
        pertnerMessageTextView.layer.cornerRadius = 15
        
        myMessageTextView.layer.cornerRadius = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        checkWhichUserMessage()
    }
    
    private func checkWhichUserMessage() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        if uid == messageText?.uid {
            pertnerMessageTextView.isHidden = true
            pertnerDateLabel.isHidden = true
            userImageView.isHidden = true
            
            myMessageTextView.isHidden = false
            myDateLabel.isHidden = false
            
            if let message = messageText {
                myMessageTextView.text = message.message
                myDateLabel.text = dataFormatterForDateLabel(date: message.createdAt.dateValue())
                let width = estimateFrameForTexyView(text: message.message).width + 20
                myMessageTextViewWidthConstraint.constant = width
            }
        } else {
            pertnerMessageTextView.isHidden = false
            pertnerDateLabel.isHidden = false
            userImageView.isHidden = false
            
            myMessageTextView.isHidden = true
            myDateLabel.isHidden = true
            
            if let message = messageText {
                pertnerMessageTextView.text = message.message
                pertnerDateLabel.text = dataFormatterForDateLabel(date: message.createdAt.dateValue())
                let width = estimateFrameForTexyView(text: message.message).width + 20
                pertnerMessageTextViewWidthConstraint.constant = width
            }
            
            if let urlString = messageText?.pertnerUser?.profileImageUrl, let url = URL(string: urlString) {
                Nuke.loadImage(with: url, into: userImageView, completion: nil)
            }
        }
    }
    
    // 入力されたテキストの文字によって幅を変える
    private func estimateFrameForTexyView(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    // メッセージの最終更新時間
    private func dataFormatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
//        formatter.dateFormat = "hh:mm"
        formatter.locale = Locale(identifier: "ja-JP")
//        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        return formatter.string(from: date)
    }

}

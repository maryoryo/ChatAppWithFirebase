//
//  ChatRoomTableViewCell.swift
//  ChatAppWithFirebase
//
//  Created by 清藤凌真 on 2023/01/15.
//

import UIKit

class ChatRoomTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var messageTextViewWidthConstraint: NSLayoutConstraint!
    
    var messageText: Message? {
        didSet {
            if let message = messageText {
                messageTextView.text = message.message
                dateLabel.text = dataFormatterForDateLabel(date: message.createdAt.dateValue())
                let width = estimateFrameForTexyView(text: message.message).width + 20
                messageTextViewWidthConstraint.constant = width
//                userImageView.image =
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        userImageView.layer.cornerRadius = 30
        messageTextView.layer.cornerRadius = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // 入力されたテキストの文字によって幅を変える
    private func estimateFrameForTexyView(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], context: nil)
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

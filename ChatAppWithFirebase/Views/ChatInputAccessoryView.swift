//
//  ChatInputAccessoryView.swift
//  ChatAppWithFirebase
//
//  Created by 清藤凌真 on 2023/01/15.
//

import UIKit

// 送信されたメッセージのデリゲートプロトコル
protocol ChatInputAccessoryViewDelegate: class {
    func tappedSendButton(text: String)
}

class ChatInputAccessoryView: UIView {
    
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    weak var delegate: ChatInputAccessoryViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        xibInit()
        setupViews()
        
        // メッセージ送信欄のレイアウト
        autoresizingMask = .flexibleHeight
    }
    
    // メッセージ送信欄のレイアウト
    private func setupViews() {
        chatTextView.layer.cornerRadius = 15
        chatTextView.layer.borderColor = UIColor.rgb(red: 230, green: 230, blue: 230).cgColor
        chatTextView.layer.borderWidth = 1
        
        sendButton.layer.cornerRadius = 15
        sendButton.imageView?.contentMode = .scaleAspectFill
        sendButton.contentHorizontalAlignment = .fill
        sendButton.contentVerticalAlignment = .fill
        sendButton.isEnabled = false
        
        // メッセージ入力欄の初期空文字と送信ロジック
        chatTextView.text = ""
        chatTextView.delegate = self
    }
    
    // メッセージ送信欄のレイアウト
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    // xibファイルを配置
    private func xibInit() {
        let nib = UINib(nibName: "ChatInputAccessoryView", bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(view)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 送信ボタン押下
    @IBAction func tappedSendButton(_ sender: Any) {
        guard let text = chatTextView.text else { return }
        delegate?.tappedSendButton(text: text)
    }
    
    // 送信ボタン押下後の処理
    func removeText() {
        chatTextView.text = ""
        sendButton.isEnabled = false
    }
    
}

extension ChatInputAccessoryView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            sendButton.isEnabled = false
        } else {
            sendButton.isEnabled = true
        }
    }
}

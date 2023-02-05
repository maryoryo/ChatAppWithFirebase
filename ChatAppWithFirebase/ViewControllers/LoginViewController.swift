//
//  LoginViewController.swift
//  ChatAppWithFirebase
//
//  Created by 清藤凌真 on 2023/02/04.
//

import UIKit
import Firebase
import FirebaseAuth
import PKHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var dontHaveAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loginButton.layer.cornerRadius = 8
        
        // ログインボタンが押下された時
        loginButton.addTarget(self, action: #selector(tappedLoginButton), for: .touchUpInside)
        // アカウントを持っていない時の画面遷移処理
        dontHaveAccountButton.addTarget(self, action: #selector(tappedDontHaveAccountButton), for: .touchUpInside)
    }
    
    @objc private func tappedDontHaveAccountButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func tappedLoginButton() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        HUD.show(.progress)
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (result, error) in
            if let error = error {
                HUD.hide()
                print("ログインに失敗しました：\(error)")
                return
            }
            HUD.hide()
            print("ログインに成功しました。")
            
            // ログイン成功時にfetchChatroomsInfoFromFirebase()メソッドを呼ぶ
            let nav = self.presentingViewController as! UINavigationController
            let chatListViewController = nav.viewControllers[nav.viewControllers.count - 1] as? ChatListViewController
            chatListViewController?.fetchChatroomsInfoFromFirebase()
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    // 外枠を押下した時にキーボードが閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

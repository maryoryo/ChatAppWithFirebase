//
//  SignUpViewController.swift
//  ChatAppWithFirebase
//
//  Created by 清藤凌真 on 2023/01/15.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import PKHUD

class SignUpViewController: UIViewController {

    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextFiled: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var alreadyHaveAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    // Viewに表示される処理
    private func setupViews() {
        profileImageButton.layer.cornerRadius = 85
        profileImageButton.layer.borderWidth = 1
        profileImageButton.layer.borderColor = UIColor.rgb(red: 240, green: 240, blue: 240).cgColor
        registerButton.layer.cornerRadius = 12
        
        // 登録ボタン押下時
        registerButton.addTarget(self, action: #selector(tappedRegisterButton), for: .touchUpInside)
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        usernameTextFiled.delegate = self
        
        registerButton.isEnabled = false
        registerButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
        
        // 既にアカウントをお持ちの方ボタン押下時
        alreadyHaveAccountButton.addTarget(self, action: #selector(tappedAlreadyAccountButton), for: .touchUpInside)
    }
    
    @IBAction func tappedProfileImageButton(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc private func tappedRegisterButton() {
        
        // 選択されたプロフィール画像
        let image = profileImageButton.imageView?.image ?? UIImage(named: "profImage")
        // プロフィール画像のクオリティ
        guard let uploadImage = image?.jpegData(compressionQuality: 0.3) else { return }
        
        HUD.show(.progress)
        
        // ファイル名は一意のIDにする
        let fileName = NSUUID().uuidString
        // ストレージを配置
        let strageRef = Storage.storage().reference().child("profile_image").child(fileName)
        
        strageRef.putData(uploadImage, metadata: nil) { (metaData, error) in
            if let error = error {
                HUD.hide()
                print("FireStrageへの保存に失敗しました：\(error)")
                return
            }
            print("FireStrageへの情報の保存が成功しました")
            strageRef.downloadURL(completion: { (url, error) in
                if let error = error {
                    HUD.hide()
                    print("FireStrageからのダウンロードに失敗しました：\(error)")
                    return
                }
                guard let urlString = url?.absoluteString else { return }
                print("urlString: \(urlString)")
                print("FireStrageからのダウンロードに成功しました")
                self.createUserToFirebase(profileImage: urlString)

            })
        }
    }
    
    @objc private func tappedAlreadyAccountButton() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func createUserToFirebase(profileImage: String) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        // FireAuthへの登録
        Auth.auth().createUser(withEmail: email, password: password) { (res, error) in
            if let error = error {
                HUD.hide()
                print("認証情報の保存に失敗しました：\(error)")
                return
            }
            print("認証情報の保存に成功しました")
            
            // Firestroreへの保存
            guard let uid = res?.user.uid else { return }
            guard let username = self.usernameTextFiled.text else { return }
            let docData = [
                "email": email,
                "username": username,
                "createdAt": Timestamp(),
                "profileImageUrl": profileImage
            ]
            Firestore.firestore().collection("users").document(uid).setData(docData) { (error) in
                if let error = error {
                    HUD.hide()
                    print("Firestroreへの保存に失敗しました：\(error)")
                    return
                }
                HUD.hide()
                print("Firestroreへの情報の保存が成功しました")
                
                self.dismiss(animated: true, completion: nil)
                
            }
        }
    }
    
    // 外枠を押下した時にキーボードが閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        print("textField: \(textField.text)")
        let emailIsEmpty = emailTextField.text?.isEmpty ?? false
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? false
        let usernameIsEmpty = usernameTextFiled.text?.isEmpty ?? false
        
        if emailIsEmpty || passwordIsEmpty || usernameIsEmpty {
            registerButton.isEnabled = false
            registerButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
        } else {
            registerButton.isEnabled = true
            registerButton.backgroundColor = .rgb(red: 0, green: 185, blue: 0)
        }
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 画像編集画面でレイアウトを変更した時
        if let editImage = info[.editedImage] as? UIImage {
            profileImageButton.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
        // 画像編集画面でレイアウトを変更しなかった時
        } else if let originalImage = info[.originalImage] as? UIImage {
            profileImageButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        profileImageButton.setTitle("", for: .normal)
        profileImageButton.imageView?.contentMode = .scaleAspectFill
        profileImageButton.contentHorizontalAlignment = .fill
        profileImageButton.contentVerticalAlignment =  .fill
        profileImageButton.clipsToBounds = true
        
        dismiss(animated: true, completion: nil)
    }
}

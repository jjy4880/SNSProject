

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn

import SnapKit
class LoginViewController: UIViewController, GIDSignInUIDelegate,GIDSignInDelegate {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    // googleLoginButton
    var button: GIDSignInButton = {
        var bt = GIDSignInButton()
        bt.style = .wide
        return bt
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        email.delegate = self
        password.delegate = self
        self.view.addSubview(button)
        
        // 구글 버튼 설정
        // Snapkit사용하여 정해진 로그인 버튼에 사이즈 맞추도록 custom
        button.snp.makeConstraints { (make) in
            make.centerX.equalTo(loginButton)
            make.leading.equalTo(loginButton).offset(-4)
            make.trailing.equalTo(loginButton).offset(4)
            make.top.equalTo(loginButton.snp.bottom).offset(8)
        }
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signOut()
        textFieldStyleSetting(sender: [email, password])
    }
    
    deinit {
        
    }
    
    // 자동 로그인
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "signIntoTabbarVC", sender: nil)
        }
    }
    
    func textFieldStyleSetting(sender: [UITextField]) {
        for tf in sender {
            tf.backgroundColor = .clear
            tf.tintColor = .white
            tf.textColor = .white
            tf.attributedPlaceholder = NSAttributedString(
                string: tf.placeholder ?? "",
                attributes: [NSAttributedStringKey.foregroundColor: UIColor(white:0.8, alpha: 0.4)])
        }
    }
    
    @IBAction func signinPressed(_ sender: Any) {
        guard let emailAddress = email.text,
            let passwordValue = password.text else {
                print("로그인 에러")
                return
        }
        
        password.resignFirstResponder()
        
        Auth.auth().signIn(withEmail: emailAddress, password: passwordValue) { (user, err) in
            if err != nil {
                let alertController = UIAlertController(title: "로그인 실패", message: err.debugDescription, preferredStyle: .alert)
                
                let okButton = UIAlertAction(title: "확인", style: .default, handler: { (action) in
                    self.email.resignFirstResponder()
                })
                
                alertController.addAction(okButton)
                self.present(alertController, animated: true, completion: {
                    self.email.text = ""
                    self.password.text = ""
                })
                return
            }
            self.email.text = ""
            self.password.text = ""
            self.performSegue(withIdentifier: "signIntoTabbarVC", sender: nil)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            print("찾고있음")
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (user, err) in
            if let error = err {
                print(error.localizedDescription)
                return
            }
            print("Success")
            
            if let name = user?.displayName,
                let email = user?.email,
                let profileImageUrl = user?.photoURL?.absoluteString,
                let userid = user?.uid {
                self.pushDataToFirebase(userName: name, email: email, profileImageUrl: profileImageUrl, uid: userid)
            }
        }
        GIDSignIn.sharedInstance().signOut()
        self.performSegue(withIdentifier: "signIntoTabbarVC", sender: nil)
    }
    
    func pushDataToFirebase(userName: String, email: String, profileImageUrl: String, uid: String){
        let ref = Database.database().reference().child("users")
        
        let userReference = ref.child(uid)
        userReference.setValue(["username": userName,
                                "email": email,
                                "profileImageUrl": profileImageUrl,
                                "uid": uid
            ])
        print(" description: \(userReference.description())")
    }
}


extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.beginEditingTF(isOn: true)
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.beginEditingTF(isOn: false)
        return true
    }
}


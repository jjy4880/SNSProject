

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
        
        
        AuthService.fetchDatabase()
        
        
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
        
        textFieldStyleSetting(sender: [email, password])
    }
    
    deinit {
        
    }
    
    // 자동 로그인
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //자동로그인
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
        
        // email 로그인 성공시 탭바 실패시 알럿
        AuthService.signIn(email: emailAddress, password: passwordValue, onSuccess: {
            self.email.text = ""
            self.password.text = ""
            self.performSegue(withIdentifier: "signIntoTabbarVC", sender: nil)
        }) {
            self.loginFairueAlert()
        }
    }
    
    func loginFairueAlert() {
        let alertController = UIAlertController(title: "로그인 실패", message: "ID/Password를 확인하여주세요.", preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "확인", style: .default, handler: { (action) in
            self.email.becomeFirstResponder()
        })
        
        alertController.addAction(okButton)
        self.present(alertController, animated: true, completion: {
            self.email.text = ""
            self.password.text = ""
        })
    }
    
    // 구글로그인 델리게이트
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        // GoogleLogin
        AuthService.signIn(credential: credential) {
            self.performSegue(withIdentifier: "signIntoTabbarVC", sender: nil)
            GIDSignIn.sharedInstance().signOut()
        }
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


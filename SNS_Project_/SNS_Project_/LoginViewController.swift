//
//  LoginViewController.swift
//  SNS_Project_
//
//  Created by Jiyong on 2018. 1. 11..
//  Copyright © 2018년 yong. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        email.delegate = self
        password.delegate = self
        
        textFieldStyleSetting(sender: [email, password])
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


import UIKit
import Photos
import RxSwift
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class SignUpViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var signUp: UIButton!
    
    @IBOutlet weak var nickname: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordCheck: UITextField!
    
    let signupViewModel = SignupViewModel()
    let disposdBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // textfield 셋팅
        delegateSetting(sender: [nickname, email, password, passwordCheck])
        textFieldStyleSetting(sender: [nickname, email, password, passwordCheck])
        
        // RxSwift 를 활용하여 뷰모델과 바인딩.
        _ = email.rx.text.map { $0 ?? "" }.bind(to: signupViewModel.emailText)
        _ = password.rx.text.map { $0 ?? "" }.bind(to: signupViewModel.passwordText)
        _ = passwordCheck.rx.text.map { $0 ?? "" }.bind(to: signupViewModel.passwordCheckText)
        
        //가입조건 체크.
       signupButtonisEnabled()
        
        /*
         -Extension을 활용
         입력한 값이 적절한 email값인지 상태를 체크
         입력한 값이 특수문자 1개를 포함하여 8자리 이상인지 체크
        */
        emailEnabled()
        passwordEnabled()
        passwordCheckEnabled()
        
        // ProfileImageView Setting
        profileImageViewSetting()
    }
    
    
    @IBAction func signupPressed(_ sender: Any) {
        
        passwordCheck.resignFirstResponder()
        
        guard let email = email.text,
            let password = password.text,
            let name = nickname.text,
            let image = profileImageView.image else { return }
        
        let alertController = UIAlertController(title: "\(name)님 축하합니다.", message: "성공적으로 가입 되었습니다.", preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default) { (action) in
            DispatchQueue.global().async {
                //FirebaseAuth
                Auth.auth().createUser(
                    withEmail: email,
                    password: password,
                    completion: { (user: User?, err) in
                        if let error = err {
                            print(error.localizedDescription)
                            return
                        }
                        guard let uid = user?.uid else { return }
                        
                        // 이미지 저장하기 위해 변형.
                        guard let saveImage = UIImageJPEGRepresentation(image, 0.1)  else { return }
                        user?.createProfileChangeRequest().displayName = name
                        user?.createProfileChangeRequest().commitChanges(completion: nil)
                        
                        Storage.storage().reference(withPath: "userProfileImages").child(uid).putData(saveImage, metadata: nil, completion: { (data, err) in
                            let imageURL = data?.downloadURL()?.absoluteString ?? "Has not Found"
                            // Database Connect
                            // ref 를 통하여 통신한다.uid
                            self.pushDataToFirebase(userName: name, email: email, profileImageUrl: imageURL, uid: uid)
                        })
                })
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        alertController.addAction(action)
        self.present(alertController, animated: true) {
          self.signupViewDataReset()
        }
    }
    
    // Database Push
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
    
    @IBAction func dismissSignUp(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func signupViewDataReset() {
        email.text = ""
        password.text = ""
        passwordCheck.text = ""
        nickname.text = ""
        profileImageView.image = nil
    }
    
    // UITextFields set style
    func textFieldStyleSetting(sender: [UITextField]) {
        for tf in sender {
            tf.backgroundColor = .clear
            tf.tintColor = .white
            tf.textColor = .white
            tf.attributedPlaceholder = NSAttributedString(
                string: tf.placeholder ?? "",
                attributes: [NSAttributedStringKey.foregroundColor: UIColor(white:1.0, alpha: 0.6)])
        }
    }
    // UITextFields set delegate
    func delegateSetting(sender: [UITextField]) {
        for tf in sender {
            tf.delegate = self
        }
    }
    
    // keyboard hide
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func signupButtonisEnabled() {
        _ = signupViewModel.signupValid.subscribe(onNext: { isValid in
            self.signUp.tintColor = isValid ? .black : .lightGray
            self.signUp.alpha = isValid ? 1.0 : 0.3
            self.signUp.isEnabled = isValid
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposdBag)
    }
    //EmailCheck
    func emailEnabled() {
        
        _ = signupViewModel.isValidEmail.subscribe(onNext: { (isvalid) in
            self.email.checkstatus(isValid: isvalid)
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposdBag)
    }
    
    func passwordEnabled() {
        _ = signupViewModel.isValidPassword.subscribe(onNext: { (isvalid) in
            self.password.checkstatus(isValid: isvalid)
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposdBag)
    }
    
    func passwordCheckEnabled() {
        _ = signupViewModel.isvalidPasswordCheck.subscribe(onNext: { (isvalid) in
            self.passwordCheck.checkstatus(isValid: isvalid)
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposdBag)
    }
    
    
    func profileImageViewSetting() {
        profileImageView.isUserInteractionEnabled = true
        profileImageView.layer.cornerRadius = (self.view.frame.width * 0.3) / 2
        profileImageView.clipsToBounds = true
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(presentImagepicker))
        profileImageView.addGestureRecognizer(tapgesture)
    }
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.beginEditingTF(isOn: true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.beginEditingTF(isOn: false)
        return true
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func presentImagepicker() {
        PHPhotoLibrary.requestAuthorization { [weak self] (status) in
            guard let `self` = self else { return }
            
            DispatchQueue.main.async {
                guard status == .authorized else {
                    self.needPermissionAlert()
                    return
                }
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.allowsEditing = true
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        profileImageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func needPermissionAlert() {
        let alertController = UIAlertController(title: "사진 접근 거절됨",
                                                message: "게시물을 작성하려면 사진이 필요합니다. \n설정에서 접근을 허용할 수 있습니다.",
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "설정", style: .destructive) { (action) in
            guard let url = URL(string:UIApplicationOpenSettingsURLString) else { return }
            UIApplication.shared.open(url)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

### AuthService

[FirebaseDatabase](https://firebase.google.com/docs/database/ios/start?authuser=0)
[FirebaseAuth](https://firebase.google.com/docs/auth/ios/start?authuser=0)
[FirebaseStorage](https://firebase.google.com/docs/storage/ios/start?authuser=0)

* 인증관련 기능들을 모아서 구현.   [AuthService](https://github.com/jjy4880/SNSProject/blob/master/SNS_Project_/SNS_Project_/Helper/AuthService.swift)


---


* DB에 있는 모든email값을 가져오는 코드
```Swift

static var userList: [String] = []

    static func fetchDatabase() {
        Database.database().reference().child("users").observe(.value) { (snapshot) in
            for child in snapshot.children {
                let son = child as! DataSnapshot
                let values = son.value as! NSDictionary
                let email = values["email"] as! String
                self.userList.append(email)
            }
        }
    }
```

* 기본 Email 양식으로 가입할 경우
```Swift
//회원 가입 + 프로필 이미지 Storage저장 User데이타 DB 저장
  static func createUser(name: String,
                         email: String,
                         password: String,
                         image: UIImage,
                         onSuccess: @escaping () -> Void,
                         onFailure: @escaping () -> Void) {

      if !userList.contains(email) {
          Auth.auth().createUser(withEmail: email, password: password) { (user, err) in
              if err != nil {
                  print(err?.localizedDescription ?? "Error")
                  return
              }

              guard let uid = user?.uid else { return }
              guard let saveImage = UIImageJPEGRepresentation(image, 0.1)  else { return }
              user?.createProfileChangeRequest().displayName = name
              user?.createProfileChangeRequest().commitChanges(completion: nil)

              Storage.storage().reference(withPath: "userProfileImages").child(uid).putData(saveImage, metadata: nil, completion: { (data, err) in
                  let imageURL = data?.downloadURL()?.absoluteString ?? "Has not Found"
                  self.pushUserDataToDatabase(userName: name, email: email, profileImageUrl: imageURL, uid: uid)
              })
              onSuccess()
          }
      } else {
          onFailure()
      }
  }
```



#### 구글 로그인

* GoogleButton.
```swift
  import GoogleSignIn
  var button: GIDSignInButton = {
    var bt = GIDSignInButton()
    bt.style = .wide
    return bt
  }()
```

* Snapkit을 활용한 레이아웃설정
```swift
  import Snapkit
  button.snp.makeConstraints { (make) in
            make.centerX.equalTo(loginButton)
            make.leading.equalTo(loginButton).offset(-4)
            make.trailing.equalTo(loginButton).offset(4)
            make.top.equalTo(loginButton.snp.bottom).offset(8)
        }
```
>일반 뷰처럼 UIButton과 leading,trailing 을 같게 주었더니 크기가 좀 삐뚤게 설정되어 적정값을 주어 맞추어줌.



* 구글 계정 Credential 을 통해 정보를 DB로 저장,이미지를 Storage이 저장한다.
이미 저장되 있는 값이라면 저장하지않고, 다음으로 진행
```swift
static func signIn(credential: AuthCredential, onSuccess: @escaping () -> Void) {
  //GIDSignIn.sharedInstance() delegate
      Auth.auth().signIn(with: credential) { (user, err) in
          if err != nil {
              print("Google = \(err!.localizedDescription)")
              return
          }
          print("Google Login Success")
          if let name = user?.displayName,
              let email = user?.email,
              let profileImageUrl = user?.photoURL?.absoluteString,
              let userid = user?.uid {

              if !userList.contains(email) {
                  self.pushUserDataToDatabase(userName: name,
                                              email: email,
                                              profileImageUrl: profileImageUrl,
                                              uid: userid)
                  do {
                      let data = try Data(contentsOf: (user?.photoURL)!)
                      Storage.storage().reference(withPath: "userProfileImages").child(userid).putData(data, metadata: nil, completion: nil)
                  } catch {
                      print("GoogleLogin Process")
                  }
                  onSuccess()
              } else {
                  onSuccess()
              }

          }
      }
  }
```


* 구글 아이디로 인증하기를 누르면 아래 함수가 실행되어 id값을 확인
```Swift
// 구글 로그인 델리게이트
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
```

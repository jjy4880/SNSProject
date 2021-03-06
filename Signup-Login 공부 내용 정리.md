## Sign Up
### Custom UITextField Style 적용
  * 기본상태 border - 없음
  * 터치 발생 시 하얀색 layer 적용
  * Email/password 상태에 따라 layer 파랑색,빨간색 적용하여 유저에게 적절한 형식인지 알려줌
  * layer에 id를 부여하고 특정 id에 해당하는 스타일을 변경시켜 적용

  ```Swift
  extension UITextField {
    func checkstatus(isValid: Bool) {
      if isValid {
          if let layerArray = self.layer.sublayers {
              for lay in layerArray {
                  if let id = lay.name {
                      if id == "editing" {
                          lay.backgroundColor = UIColor.blue.cgColor
                      }
                  }
              }
          }
      } else {
          if let layerArray = self.layer.sublayers {
              for lay in layerArray {
                  if let id = lay.name {
                      if id == "editing" {
                          if self.text == "" {
                              lay.backgroundColor = UIColor.white.cgColor
                          } else {
                              lay.backgroundColor = UIColor.red.cgColor
                          }
                      }
                  }
              }
          }
      }
    }
  }

  ```
### Email , Password 확인

* **RxSwift**

  * email,password ... `ViewModel.swift`의 값과 바인딩 시킴.

  * ViewModel 에서 각 입력값에 대한 형식 체크 하도록 구현해놓고 상태를 구독시켜둠. `[Observe,subscribe]`

  * [SignupViewModel](https://github.com/jjy4880/SNSProject/blob/master/SNS_Project_/SNS_Project_/ViewModel/SignupViewModel.swift)
* **정규표현식**  사용하여 email,password 형식 체크

```Swift
extension String {
  var validEmailAddress: Bool {
      var returnValue = true
      let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Z0-9a-z.-_]+\\.[A-Za-z]{2,3}"

      do {
          let regex = try NSRegularExpression(pattern: emailRegEx)
          let results = regex.matches(in: self, range: NSRange(location: 0, length: self.count))

          if results.count == 0 {
              returnValue = false
          }
      } catch let error as NSError {
          print("invalid regex: \(error.localizedDescription)")
          returnValue = false
      }
      return returnValue
  }

  func isPasswordValid() -> Bool{
      let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
      return passwordTest.evaluate(with: self)
  }
}
```

### Login FirebaseAuth
```swift
import FirebaseAuth
Auth.auth().createUser(withEmail: email,
                                     password: password, completion: { (user: User?, err) in
                  if let error = err {
                      print(error.localizedDescription)
                      return
                  }
              })
```

### PhotoLibrary User Permission
* 허용되있는지 확인
```Swift
PHPhotoLibrary.requestAuthorization { [weak self] (status) in
            guard let `self` = self else { return }

            DispatchQueue.main.async {
                guard status == .authorized else {
                    self.needPermissionAlert()
                    return
                }
```
* 설정항목으로 이동
```Swift
guard let url = URL(string:UIApplicationOpenSettingsURLString) else { return }
          UIApplication.shared.open(url)
```

---
 * [CALayer](https://developer.apple.com/documentation/quartzcore/calayer)
 * [Photos_PHPhotoLibrary](https://developer.apple.com/documentation/photos/phphotolibrary/1620736-requestauthorization)
 * [RxSwift](https://github.com/ReactiveX/RxSwift)
 * [정규표현식](https://engineering.huiseoul.com/%EC%A0%95%EA%B7%9C%ED%91%9C%ED%98%84%EC%8B%9D-%EC%A2%80-%EB%8D%94-%EA%B9%8A%EC%9D%B4-%EC%95%8C%EC%95%84%EB%B3%B4%EA%B8%B0-5bd16027e1e0)
 * [NSRegularExpression](https://developer.apple.com/documentation/foundation/nsregularexpression)

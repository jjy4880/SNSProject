import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class AuthService {
    
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
    
    //email로그인
    static func signIn(email: String,
                       password: String,
                       onSuccess: @escaping () -> Void,
                       onError: @escaping () -> Void) {
        Auth.auth().signIn(withEmail: email,
                           password: password) { (user, error) in
                            
                            dump(userList)
            if error != nil {
                onError()
                return
            }
            onSuccess()
        }
    }
    
    static func signIn(credential: AuthCredential, onSuccess: @escaping () -> Void) {
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
    
    
    static func pushUserDataToDatabase(userName: String,
                                       email: String,
                                       profileImageUrl: String,
                                       uid: String) {
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

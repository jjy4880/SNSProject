import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class AuthService {
    static var currentUserid = ""
    
    static var userList: [String] = []
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.setLocalizedDateFormatFromTemplate("MMMM d, YYYY")
        return formatter
    }()
    
    static func fetchAllArticlesDatabase(uid: String?) {
        Database.database().reference().child("articles").observe(.value) { (datasnapshot) in
            if uid == nil {
                ArticleStore.allArticles.removeAll()
                print("모든DB 가져오기")
                for child in datasnapshot.children {
                    let son = child as! DataSnapshot
                    let values = son.value as AnyObject
                    articlesInit(object: values, mode: 1)
                }
            } else if let userid = uid {
                ArticleStore.currentUserArticle.removeAll()
                for child in datasnapshot.children {
                    let son = child as! DataSnapshot
                    let values = son.value as AnyObject
                    if values["uid"] as! String == userid {
                        articlesInit(object: values, mode: 2)
                    }
                }
            }
        }
    }
    
    static func articlesInit(object: AnyObject, mode: Int) {
        ArticleStore.createArticleModel(username: object["name"] as! String,
                                        profileImageUrl: object["profileUrl"] as! String,
                                        description: object["description"] as! String,
                                        uid: object["uid"] as! String,
                                        currentDate: object["createDate"] as! String,
                                        articleImageUrl: object["imageUrl"] as! String, mode: mode
        )
    }
    static func fetchUserData(uid: String, success: @escaping (UserInfoModel) -> Void){
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (datasnapshot) in
            let data = datasnapshot as DataSnapshot
            let values = data.value as! NSDictionary
            
            success(UserInfoModel(email: values["email"] as! String,
                                  profileImageUrl: values["profileImageUrl"] as! String,
                                  nickname: values["username"] as! String))
        }
    }
    
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
            dump(userList)
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
    
    
    static func pushArticleDataToDatabase(uid: String, imageUrl: String, description: String, handler: @escaping () -> Void) {
        
        var currentUserProfileImageUrl = ""
        Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).observe(.value, with: { (datasnapshot) in
            let dic = (datasnapshot.value as! NSDictionary)
            currentUserProfileImageUrl = dic["profileImageUrl"] as! String
        })
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (datasnapshot) in
            let value = datasnapshot.value as! NSDictionary
            let ref = Database.database().reference().child("articles").childByAutoId()
            ref.setValue(["uid": uid,
                          "name" : (value["username"] as? String)!,
                          "imageUrl": imageUrl,
                          "description": description,
                          "createDate": dateFormatter.string(from: Date()),
                          "autoID": ref.key,
                          "profileUrl": currentUserProfileImageUrl
                ])
        }
        handler()
        
        
        print("Upload to Firebase Database / \(uid)")
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

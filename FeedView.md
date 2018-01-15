### FeedView

* 게시글을 작성하면 DB로 데이타 저장
* 게시글 사진은 Storage 로 저장
* 이미지는 압축하여 저장 -> 데이타 관리
```Swift
guard let userid = Auth.auth().currentUser?.uid,
            let desc = descriptionTextView.text,
            let image = imageView.image else { return }

        self.descriptionTextView.resignFirstResponder()
        guard let saveImage = UIImageJPEGRepresentation(image, 0.5)  else { return }

        Storage.storage().reference().child("articlePhotos").child("\(userid) \(desc)").putData(saveImage, metadata: nil) { (data, err) in

            let imageUrl = data?.downloadURL()?.absoluteString ?? "Has not Found"
            AuthService.pushArticleDataToDatabase(uid: userid, imageUrl: imageUrl, description: desc) {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "알림", message: "게시글이 정상적으로 등록되었습니다.", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "확인", style: .default) { action in

                    }

                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: {
                        self.imageView.image = nil
                        self.descriptionTextView.text = "게시글 작성"
                    })
                }
            }
        }
    }
```

* FeedView가 뜨기 전에 DB에서 게시글에대한 데이터를 모두 파싱.
* ref경로로 접근하여 Data를 파싱 후 데이터 모델로 생성
```swift
static func fetchAllArticlesDatabase() {

       Database.database().reference().child("articles").observe(.value) { (datasnapshot) in
           ArticleStore.allArticles.removeAll()

           for child in datasnapshot.children {
               let son = child as! DataSnapshot
               let values = son.value as AnyObject
               print(values["name"])
               articlesInit(object: values)
           }
       }
   }
```
* ArticleModel Initialize
```Swift
static func articlesInit(object: AnyObject) {

    ArticleStore.createArticleModel(username: object["name"] as! String,
                                    profileImageUrl: object["profileUrl"] as! String,
                                    description: object["description"] as! String,
                                    uid: object["uid"] as! String,
                                    currentDate: object["createDate"] as! String,
                                    articleImageUrl: object["imageUrl"] as! String
                                    )
}
```
* allArticles  게시글의 갯수와 내용을 갖는 아티클모델 배열을 갖는다.

```Swift
class ArticleStore {

    static var allArticles: [ArticleModel] = []

    static func createArticleModel(username: String, profileImageUrl: String, description: String, uid: String, currentDate: String, articleImageUrl: String) {
        let articleObject = ArticleModel.init(username: username, profileImageUrl: profileImageUrl, description: description, uid: uid, currentDate: currentDate, articleImageUrl: articleImageUrl)

        self.allArticles.append(articleObject)
    }
}
```

* Show Article Data using TableView
```Swift
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return ArticleStore.allArticles.count
   }

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FeedTableViewCell
        let object = ArticleStore.allArticles[ArticleStore.allArticles.count - 1 - indexPath.row]
        cell.dateLabel.text = object.currentDate
        cell.usernameLabel.text = object.username
        cell.usernameButton.setTitle(object.username, for: .normal)
        cell.descTextView.text = object.description

        let profileImageurl = URL(string: object.profileImageUrl)
        let articleImageurl = URL(string: object.articleImageUrl)

        cell.articleImageView.sd_setImage(with: articleImageurl, completed: nil)
        cell.profileImageView.sd_setImage(with: profileImageurl, completed: nil)
        return cell
    }
```

### ImageCaching
* DB에 저장된 Url을 통해 이미지를 생성하는데, 이때 테이블 뷰의 셀은 계속 재사용 되는 속성 때문에 스크롤 할 때마다 새로운 이미지로의 변경을 시도하게 된다.
이로써 한번 변환하고, 캐싱을 사용하여 이후에 재사용 될 때는 내부에서 저장되있는것을 찾아 사용해야한다.

그러기 위해서 sdWebImage 라는 오픈소스를 사용하였다.



* [FirebaseStorage](https://firebase.google.com/docs/storage/ios/start?authuser=0)
* [FirebaseDatabase](https://firebase.google.com/docs/database/ios/start?authuser=0)
* [SDWebImage](https://github.com/rs/SDWebImage)

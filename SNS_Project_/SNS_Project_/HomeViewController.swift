import UIKit
import FirebaseAuth
import FirebaseDatabase
import SDWebImage

class HomeViewController: UIViewController {
    
    var currentUserProfileImageUrl: String = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        print(ArticleStore.allArticles.count)
    }

    // logout
    @IBAction func logOut(_ sender: Any) {
        logoutAlert()
    }
    
    func logoutAlert() {
        let alert = UIAlertController(title: "로그아웃 하시겠습니까?", message: "", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "네", style: .destructive) { (action) in
            do {
                try Auth.auth().signOut()
            } catch let error {
                print(error)
            }
            
            self.dismiss(animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction(title: "아니요", style: .default, handler: nil)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
}
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
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
    
    
}

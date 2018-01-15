import UIKit
import FirebaseAuth
import FirebaseDatabase
class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        AuthService.fetchAllArticlesDatabase()
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
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FeedTableViewCell
        return cell
    }
    
    
}

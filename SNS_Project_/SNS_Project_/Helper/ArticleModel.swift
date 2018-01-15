

import Foundation

class ArticleStore {

    static var allArticles = [ArticleModel]()
    
    static func createArticleModel(username: String, profileImageUrl: String, description: String, uid: String, currentDate: String) {
        let articleObject = ArticleModel.init(username: username, profileImageUrl: profileImageUrl, description: description, uid: uid, currentDate: currentDate)
        
        self.allArticles.append(articleObject)
    }
}

struct ArticleModel {
    let username: String
    let profileImageUrl: String
    let description: String
    let uid: String
    let currentDate: String
}



import Foundation

class ArticleStore {
    
    static var allArticles: [ArticleModel] = []
    static var currentUserArticle: [ArticleModel] = []
    
    static func createArticleModel(username: String, profileImageUrl: String, description: String, uid: String, currentDate: String, articleImageUrl: String, mode: Int) {
        if mode == 1 {
            let articleObject = ArticleModel.init(username: username, profileImageUrl: profileImageUrl, description: description, uid: uid, currentDate: currentDate, articleImageUrl: articleImageUrl)
            self.allArticles.append(articleObject)
            
        } else if mode == 2 {
            
            let articleObject = ArticleModel.init(username: username, profileImageUrl: profileImageUrl, description: description, uid: uid, currentDate: currentDate, articleImageUrl: articleImageUrl)
            self.currentUserArticle.append(articleObject)
        }
    }
}

struct ArticleModel {
    let username: String
    let profileImageUrl: String
    let description: String
    let uid: String
    let currentDate: String
    let articleImageUrl: String
}

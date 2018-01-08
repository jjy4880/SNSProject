//
//  HomeViewController.swift
//  SNS_Project
//
//  Created by Jiyong on 2018. 1. 7..
//  Copyright © 2018년 yong. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var commentsViewController: CommentsViewController?
    var isLiked: Bool = false
    var likesCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc func pushLikesViewcontroller() {
        guard let destination = storyboard?.instantiateViewController(withIdentifier: "LikesVC") else {
            return
        }
        self.navigationController?.pushViewController(destination, animated: true)
    }
    
    @objc func pushCommentsViewcontroller() {
        print("불리나")
        guard let destination = storyboard?.instantiateViewController(withIdentifier: "commentsVC") else {
            return
        }
        
        self.navigationController?.pushViewController(destination, animated: true)
    }
    
    @objc func tapLikesButton(sender: UIButton) {
        isLiked = !isLiked
        if isLiked {
            sender.setImage(UIImage(named: "likebutton_selected"), for: .normal)
        } else {
           sender.setImage(UIImage(named: "likebutton_default"), for: .normal)
        }
        
        collectionView.reloadData()
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    //
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? HomeViewCell ?? HomeViewCell()
        cell.messagesButton.addTarget(self, action: #selector(pushCommentsViewcontroller), for: .touchUpInside)
        
        cell.likesCountButton.addTarget(self, action: #selector(pushLikesViewcontroller), for: .touchUpInside)
        
        cell.likesButton.addTarget(self, action: #selector(tapLikesButton), for: .touchUpInside)
        cell.settingUI()
        if self.isLiked {
            cell.likesCountButton.setTitle("\(likesCount + 1) Likes", for: .normal)
        } else {
            cell.likesCountButton.setTitle("\(likesCount) Likes ", for: .normal)
        }
        
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
    }
    
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {

}

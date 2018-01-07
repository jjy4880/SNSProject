//
//  HomeViewCell.swift
//  SNS_Project
//
//  Created by Jiyong on 2018. 1. 7..
//  Copyright © 2018년 yong. All rights reserved.
//

import UIKit

class HomeViewCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nickname: UILabel!
    @IBOutlet weak var gpsAddress: UILabel!
    
    @IBOutlet weak var likesButton: UIButton!
    
    
    @IBOutlet weak var likesCountButton: UIButton!
    @IBOutlet weak var messagesButton: UIButton!
    
    var isLiked: Bool = false
    
    func settingUI() {
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.layer.masksToBounds = true
    }
    
    func likesbuttonToggle() {
        isLiked = !isLiked
        if isLiked {
            self.likesCountButton.setTitle("좋아요누름", for: .normal)
            self.likesButton.setImage(UIImage(named: "likebutton_selected"), for: .normal)
        } else {
            self.likesCountButton.setTitle("좋아요", for: .normal)
            self.likesButton.setImage(UIImage(named: "likebutton_default"), for: .normal)
        }
    }
    
    
}

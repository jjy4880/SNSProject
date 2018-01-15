//
//  FeedTableViewCell.swift
//  SNS_Project_
//
//  Created by Jiyong on 2018. 1. 14..
//  Copyright © 2018년 yong. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var usernameButton: UIButton!
    
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var articleImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCountsButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
}

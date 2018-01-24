//
//  ProfileViewController.swift
//  SNS_Project_
//
//  Created by Jiyong on 2018. 1. 11..
//  Copyright © 2018년 yong. All rights reserved.
//

import UIKit
import SnapKit
import SDWebImage

class ProfileViewController: UIViewController {
    
    lazy var profileSettingView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        
        return view
    }()
    
    lazy var profileImage: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .blue
        image.contentMode = .scaleAspectFit
        image.layer.cornerRadius = 45
        return image
    }()
    
    lazy var article: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.lineBreakMode = .byCharWrapping
        lb.numberOfLines = 2
        lb.text = "132  게시물"
        return lb
    }()
    
    lazy var follower: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.lineBreakMode = .byWordWrapping
        lb.numberOfLines = 2
        lb.text = "22  팔로워"
        return lb
    }()
    
    lazy var following: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.lineBreakMode = .byWordWrapping
        lb.numberOfLines = 2
        lb.text = "45  팔로잉"
        return lb
    }()
    
    lazy var emailLabel: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.font = UIFont.systemFont(ofSize: 10)
        return lb
    }()
    
    lazy var modify: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .white
        btn.setTitleColor(.black, for: .normal)
        btn.setTitleColor(.gray, for: .highlighted)
        btn.setTitle("프로필 수정", for: .normal)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(profileSettingView)
        self.profileSettingView.addSubview(profileImage)
        self.profileSettingView.addSubview(article)
        self.profileSettingView.addSubview(follower)
        self.profileSettingView.addSubview(following)
        self.profileSettingView.addSubview(emailLabel)
        self.profileSettingView.addSubview(modify)
        
        
        profileSettingView.snp.makeConstraints { (make) in
            
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalTo(view)
            make.height.equalTo(self.view.frame.height * 0.3)
        }
        profileImage.snp.makeConstraints { (make) in
            make.top.left.equalTo(profileSettingView).offset(16)
            make.width.height.equalTo(90)
        }
        
        article.snp.makeConstraints { (make) in
            make.top.equalTo(profileImage.snp.top)
            make.left.equalTo(profileImage.snp.right).offset(30)
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
        follower.snp.makeConstraints { (make) in
            make.top.equalTo(profileImage.snp.top)
            make.left.equalTo(article.snp.right).offset(30)
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
        following.snp.makeConstraints { (make) in
            make.top.equalTo(profileImage.snp.top)
            make.left.equalTo(follower.snp.right).offset(30)
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
        emailLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(profileImage)
            make.trailing.equalTo(profileImage).offset(32)
            make.top.equalTo(profileImage.snp.bottom).offset(16)
            make.height.equalTo(40)
        }
        modify.snp.makeConstraints { (make) in
            make.bottom.equalTo(profileImage)
            make.leading.equalTo(profileImage.snp.trailing).offset(30)
            make.top.equalTo(following.snp.bottom).offset(8)
            make.trailing.equalTo(following)
        }

        AuthService.fetchUserData(uid: AuthService.currentUserid) { (data) in
            self.navigationItem.title = data.nickname
            self.profileImage.sd_setImage(with: URL(string: data.profileImageUrl), completed: nil)
            self.emailLabel.text = data.email
        }
        profileImage.layer.cornerRadius = 45
        
        modify.addTarget(self, action: #selector(modifyInfo), for: .touchUpInside)
    }
    
    @objc func modifyInfo() {
        let viewController = UIViewController()
        self.present(viewController, animated: true, completion: nil)
    }
}

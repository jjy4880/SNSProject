//
//  MainTabbarViewController.swift
//  SNS_Project_
//
//  Created by Jiyong on 2018. 1. 11..
//  Copyright © 2018년 yong. All rights reserved.
//

import UIKit

class MainTabbarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // UITabbar Height 조정
    override func viewDidLayoutSubviews() {
        var tabbarFrame = self.tabBar.frame
        tabbarFrame.size.height = 40
        tabbarFrame.origin.y = self.view.frame.size.height - 40
        self.tabBar.frame = tabbarFrame
    }
}

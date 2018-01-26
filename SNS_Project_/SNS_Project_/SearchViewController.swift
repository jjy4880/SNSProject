//
//  SearchViewController.swift
//  SNS_Project_
//
//  Created by Jiyong on 2018. 1. 11..
//  Copyright © 2018년 yong. All rights reserved.
//

import UIKit
import SnapKit
import ImagePicker

class SearchViewController: UIViewController, ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("wrapp")
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("done")
        self.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        print("cancel")
        self.dismiss(animated: true, completion: nil)
    }
    

    lazy var imagepickerButton: UIButton = {
        let btn = UIButton()
        btn.tintColor = .blue
        btn.setTitleColor(.black, for: .normal)
        btn.setTitle("업로드", for: .normal)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.view.addSubview(imagepickerButton)
        
        imagepickerButton.snp.makeConstraints { (make) in
            make.centerX.centerY.equalTo(self.view)
            make.width.height.equalTo(60)
        }
        
        imagepickerButton.addTarget(self, action: #selector(picker), for: .touchUpInside)
    }
    
    @objc func picker() {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
}

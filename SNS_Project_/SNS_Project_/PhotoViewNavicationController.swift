//
//  PhotoViewNavicationController.swift
//  SNS_Project_
//
//  Created by Jiyong on 2018. 1. 26..
//  Copyright © 2018년 yong. All rights reserved.
//

import UIKit
import ImagePicker
class PhotoViewNavigationController: UINavigationController, ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("wrqp")
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        dismiss(animated: false) {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PhotoViewController") as! PhotoViewController
            self.pushViewController(vc, animated: true)
        }
        
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        print("wrqp")
    }
    
    
    override func viewDidLoad() {
        
        print("cac")
        let imagepicker = ImagePickerController()
        imagepicker.delegate = self

        self.present(imagepicker, animated: true, completion: nil)
    }
    
}

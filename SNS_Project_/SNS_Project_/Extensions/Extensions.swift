//
//  Extensions.swift
//  SNS_Project_
//
//  Created by Jiyong on 2018. 1. 11..
//  Copyright © 2018년 yong. All rights reserved.
//


import UIKit
import RxSwift
import RxCocoa

extension UITextField {
    func beginEditingTF(isOn: Bool) {
        if isOn {
            //textfield border 스타일
            let bottomLayer = CALayer()
            bottomLayer.name = "editing"
            bottomLayer.frame = CGRect(x: 2, y: self.frame.height, width: self.frame.width - 2, height: 1)
            bottomLayer.backgroundColor = UIColor.white.cgColor
            self.layer.addSublayer(bottomLayer)
        } else {
            if let layerArray = self.layer.sublayers {
                for lay in layerArray {
                    
                    // 양식이 통과되면 파랑색 레이어를 유지.
                    if lay.backgroundColor == UIColor.blue.cgColor {
                    } else {
                        if let id = lay.name {
                            if id == "editing" {
                                lay.removeFromSuperlayer()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func checkstatus(isValid: Bool) {
        if isValid {
            if let layerArray = self.layer.sublayers {
                for lay in layerArray {
                    if let id = lay.name {
                        if id == "editing" {
                            lay.backgroundColor = UIColor.blue.cgColor
                        }
                    }
                }
            }
        } else {
            if let layerArray = self.layer.sublayers {
                for lay in layerArray {
                    if let id = lay.name {
                        if id == "editing" {
                            if self.text == "" {
                                lay.backgroundColor = UIColor.white.cgColor
                            } else {
                                lay.backgroundColor = UIColor.red.cgColor
                            }
                        }
                    }
                }
            }
        }
    }
}

extension String {
    var validEmailAddress: Bool {
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Z0-9a-z.-_]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let results = regex.matches(in: self, range: NSRange(location: 0, length: self.count))
            
            if results.count == 0 {
                returnValue = false
            }
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        return returnValue
    }
    
    func isPasswordValid() -> Bool{
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: self)
    }
}

extension Reactive where Base: UIButton {
    
    var valid: AnyObserver<Bool> {
        return Binder(base, binding: { (button: UIButton, valid: Bool) in
            button.isEnabled = valid
            button.alpha = valid ? 1.0 : 0.1
        }).asObserver()
    }
}

//
//  UIColor-Extension.swift
//  ChatAppWithFirebase
//
//  Created by 清藤凌真 on 2023/01/14.
//

import Foundation
import UIKit

extension UIColor {
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }
}
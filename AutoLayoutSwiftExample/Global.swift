//  Gihhub: https://github.com/SolaWing/AutoLayoutVisualFormatLanguage
//
//  Global.swift
//  AutoLayoutVisualFormat
//
//  Created by SolaWing on 15/12/13.
//  Copyright © 2015年 SW. All rights reserved.
//

import Foundation
import UIKit

func RGB(color: UInt32) -> UIColor {
    return UIColor(red: CGFloat((color>>16)&0xff)/255.0,
        green: CGFloat((color>>8)&0xff)/255.0,
        blue: CGFloat(color&0xff)/255.0,
        alpha: 1)
}


extension UILabel {
    convenience init(title: String, color: UIColor) {
        self.init()
        self.text = title
        self.textColor = color
        self.textAlignment = NSTextAlignment.Center
        self.numberOfLines = 0
    }
}

extension UIView {
    convenience init(color: UIColor) {
        self.init()
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.backgroundColor = color
    }

    func showBorder() {
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGrayColor().CGColor
    }
}

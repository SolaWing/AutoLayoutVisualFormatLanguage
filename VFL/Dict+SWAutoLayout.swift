//  Gihhub: https://github.com/SolaWing/AutoLayoutVisualFormatLanguage
//
//  Dict+SWAutoLayout.swift
//  AutoLayoutVisualFormat
//
//  Created by SolaWing on 15/12/13.
//  Copyright © 2015年 SW. All rights reserved.
//

import Foundation
import UIKit

public extension Dictionary where Value : AnyObject {
    func VFLConstraints(format:String) -> [NSLayoutConstraint] {
        return VFL.VFLConstraints(format, self as! AnyObject)
    }

    func VFLInstall(format:String) -> [NSLayoutConstraint] {
        let constrains = VFL.VFLConstraints(format, self as! AnyObject)
        NSLayoutConstraint.activateConstraints(constrains)
        return constrains
    }

    func VFLFullInstall(format:String) -> [NSLayoutConstraint] {
        self.translatesAutoresizingMaskIntoConstraints(false)

        let constrains = VFL.VFLConstraints(format, self as! AnyObject)
        NSLayoutConstraint.activateConstraints(constrains)
        return constrains
    }

    func translatesAutoresizingMaskIntoConstraints(trans:Bool) -> Dictionary {
        for (_, element) in self {
            if let view = element as? UIView {
                view.translatesAutoresizingMaskIntoConstraints = trans
            }
        }
        return self
    }
}

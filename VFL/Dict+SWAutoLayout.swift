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

public extension Dictionary {
    func VFLConstraints(_ format:String) -> [NSLayoutConstraint] {
        return VFL.VFLConstraints(format, self)
    }

    @discardableResult
    func VFLInstall(_ format:String) -> [NSLayoutConstraint] {
        let constrains = VFL.VFLConstraints(format, self)
        NSLayoutConstraint.activate(constrains)
        return constrains
    }

    @discardableResult
    func VFLFullInstall(_ format:String) -> [NSLayoutConstraint] {
        self.translatesAutoresizingMaskIntoConstraints(false)

        let constrains = VFL.VFLConstraints(format, self)
        NSLayoutConstraint.activate(constrains)
        return constrains
    }

    @discardableResult
    func translatesAutoresizingMaskIntoConstraints(_ trans:Bool) -> Dictionary {
        for (_, element) in self {
            if let view = element as? UIView {
                view.translatesAutoresizingMaskIntoConstraints = trans
            }
        }
        return self
    }
}

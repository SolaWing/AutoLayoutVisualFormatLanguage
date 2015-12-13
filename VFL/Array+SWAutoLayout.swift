//
//  Array+SWAutoLayout.swift
//  AutoLayoutVisualFormat
//
//  Created by SolaWing on 15/12/13.
//  Copyright © 2015年 SW. All rights reserved.
//

import Foundation
import UIKit

public extension Array where Element:AnyObject {
    func VFLConstraints(format:String) -> [NSLayoutConstraint] {
        return VFL.VFLConstraints(format, self)
    }

    func VFLInstall(format:String) -> [NSLayoutConstraint] {
        let constrains = VFL.VFLConstraints(format, self)
        NSLayoutConstraint.activateConstraints(constrains)
        return constrains
    }

    func VFLFullInstall(format:String) -> [NSLayoutConstraint] {
        self.translatesAutoresizingMaskIntoConstraints(false)

        let constrains = VFL.VFLConstraints(format, self)
        NSLayoutConstraint.activateConstraints(constrains)
        return constrains
    }

    func translatesAutoresizingMaskIntoConstraints(trans:Bool) -> Array {
        for element in self {
            if let view = element as? UIView {
                view.translatesAutoresizingMaskIntoConstraints = trans
            }
        }
        return self
    }
}

public extension Array where Element:NSLayoutConstraint {
    func activateConstraints() {
        NSLayoutConstraint.activateConstraints(self)
    }

    func deactivateConstraints() {
        NSLayoutConstraint.deactivateConstraints(self)
    }
}
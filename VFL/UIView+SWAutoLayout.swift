//
//  UIView+SWAutoLayout.swift
//  AutoLayoutVisualFormat
//
//  Created by SolaWing on 15/12/13.
//  Copyright © 2015年 SW. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {
    public func VFLConstraints(format:String, args:[AnyObject]) -> [NSLayoutConstraint] {
        var argsIncludeSelf : [AnyObject] = [self]
        argsIncludeSelf.appendContentsOf(args)
        return VFL.VFLViewConstraints(format, self, argsIncludeSelf)
    }

    public func VFLConstraints(format:String, _ args:AnyObject...) -> [NSLayoutConstraint] {
        return self.VFLConstraints(format, args: args)
    }

    func VFLInstall(format:String, _ args:AnyObject...) -> [NSLayoutConstraint] {
        let constraints = self.VFLConstraints(format, args: args)
        NSLayoutConstraint.activateConstraints(constraints)
        return constraints
    }

    func VFLFullInstall(format:String, _ args:AnyObject...) -> [NSLayoutConstraint] {
        self.translatesAutoresizingMaskIntoConstraints = false
        let constraints = self.VFLConstraints(format, args: args)
        NSLayoutConstraint.activateConstraints(constraints)
        return constraints
    }
}
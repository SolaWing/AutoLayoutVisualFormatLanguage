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
    // first type is String conflict with interpolation. so add prefix label
    func VFLConstraints(format format:String, args:[AnyObject]) -> [NSLayoutConstraint] {
        var argsIncludeSelf : [AnyObject] = [self]
        argsIncludeSelf.appendContentsOf(args)
        return VFL.VFLViewConstraints(format, self, argsIncludeSelf)
    }

    func VFLConstraints(format format:String, _ args:AnyObject...) -> [NSLayoutConstraint] {
        return self.VFLConstraints(format: format, args: args)
    }

    func VFLInstall(format format:String, _ args:AnyObject...) -> [NSLayoutConstraint] {
        let constraints = self.VFLConstraints(format: format, args: args)
        NSLayoutConstraint.activateConstraints(constraints)
        return constraints
    }

    func VFLFullInstall(format format:String, _ args:AnyObject...) -> [NSLayoutConstraint] {
        self.translatesAutoresizingMaskIntoConstraints = false
        let constraints = self.VFLConstraints(format: format, args: args)
        NSLayoutConstraint.activateConstraints(constraints)
        return constraints
    }

    // MARK: - interpolation
    func VFLConstraints(interpolation:VFLInterpolation) -> [NSLayoutConstraint] {
        let (format, env) = interpolation.result()
        return VFL.VFLViewConstraints(format, self, env)
    }

    func VFLInstall(interpolation:VFLInterpolation) -> [NSLayoutConstraint] {
        let constraints = self.VFLConstraints(interpolation)
        NSLayoutConstraint.activateConstraints(constraints)
        return constraints
    }

    func VFLFullInstall(interpolation:VFLInterpolation) -> [NSLayoutConstraint] {
        let constraints = self.VFLConstraints(interpolation)
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints(constraints)
        return constraints
    }

    func addConstraints(interpolation: VFLInterpolation) {
        let constraints = self.VFLConstraints(interpolation)
        self.addConstraints(constraints)
    }
}
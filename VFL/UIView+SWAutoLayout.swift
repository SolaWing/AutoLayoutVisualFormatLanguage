//  Gihhub: https://github.com/SolaWing/AutoLayoutVisualFormatLanguage
//
//  UIView+SWAutoLayout.swift
//  AutoLayoutVisualFormat
//
//  Created by SolaWing on 15/12/13.
//  Copyright © 2015年 SW. All rights reserved.
//

import Foundation
import UIKit
#if canImport(AutoLayoutVisualFormat)
import AutoLayoutVisualFormat
#endif

public extension UIView {
    // first type is String conflict with interpolation. so add prefix label
    @nonobjc
    func VFLConstraints(format:String, args:[Any]) -> [NSLayoutConstraint] {
        var argsIncludeSelf : [Any] = [self]
        argsIncludeSelf.append(contentsOf: args)
        return VFLViewConstraints(format, self, argsIncludeSelf)
    }

    @nonobjc
    func VFLConstraints(format:String, _ args:Any...) -> [NSLayoutConstraint] {
        return self.VFLConstraints(format: format, args: args)
    }

    @nonobjc
    @discardableResult
    func VFLInstall(format:String, _ args:Any...) -> [NSLayoutConstraint] {
        let constraints = self.VFLConstraints(format: format, args: args)
        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    @nonobjc
    @discardableResult
    func VFLFullInstall(format:String, _ args:Any...) -> [NSLayoutConstraint] {
        self.translatesAutoresizingMaskIntoConstraints = false
        let constraints = self.VFLConstraints(format: format, args: args)
        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    // MARK: - interpolation
    func VFLConstraints(_ interpolation:VFLInterpolation) -> [NSLayoutConstraint] {
        let format = NSMutableString()
        let env = NSMutableArray(object: self)
        interpolation.resultInto(format, env)
        return VFLViewConstraints(format as String, self, env)
    }

    @discardableResult
    func VFLInstall(_ interpolation:VFLInterpolation) -> [NSLayoutConstraint] {
        let constraints = self.VFLConstraints(interpolation)
        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    @discardableResult
    func VFLFullInstall(_ interpolation:VFLInterpolation) -> [NSLayoutConstraint] {
        let constraints = self.VFLConstraints(interpolation)
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints)
        return constraints
    }
}

@available(iOS 9.0, *)
public extension UILayoutGuide {
    // first type is String conflict with interpolation. so add prefix label
    @nonobjc
    func VFLConstraints(format:String, args:[Any]) -> [NSLayoutConstraint] {
        var argsIncludeSelf : [Any] = [self]
        argsIncludeSelf.append(contentsOf: args)
        return VFLViewConstraints(format, self, argsIncludeSelf)
    }

    @nonobjc
    func VFLConstraints(format:String, _ args:Any...) -> [NSLayoutConstraint] {
        return self.VFLConstraints(format: format, args: args)
    }

    @nonobjc
    @discardableResult
    func VFLInstall(format:String, _ args:Any...) -> [NSLayoutConstraint] {
        let constraints = self.VFLConstraints(format: format, args: args)
        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    @nonobjc
    @discardableResult
    func VFLFullInstall(format:String, _ args:Any...) -> [NSLayoutConstraint] {
        let constraints = self.VFLConstraints(format: format, args: args)
        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    // MARK: - interpolation
    func VFLConstraints(_ interpolation:VFLInterpolation) -> [NSLayoutConstraint] {
        let format = NSMutableString()
        let env = NSMutableArray(object: self)
        interpolation.resultInto(format, env)
        return VFLViewConstraints(format as String, self, env)
    }

    @discardableResult
    func VFLInstall(_ interpolation:VFLInterpolation) -> [NSLayoutConstraint] {
        let constraints = self.VFLConstraints(interpolation)
        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    @discardableResult
    func VFLFullInstall(_ interpolation:VFLInterpolation) -> [NSLayoutConstraint] {
        let constraints = self.VFLConstraints(interpolation)
        NSLayoutConstraint.activate(constraints)
        return constraints
    }
}

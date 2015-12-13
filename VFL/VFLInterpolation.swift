//
//  VFLInterpolation.swift
//  AutoLayoutVisualFormat
//
//  Created by SolaWing on 15/12/13.
//  Copyright © 2015年 SW. All rights reserved.
//

import Foundation
import UIKit

public func VFLConstraints(interpolation: VFLInterpolation) -> [NSLayoutConstraint] {
    let (format, env) = interpolation.result()
    return VFL.VFLConstraints(format, env)
}

public func VFLInstall(interpolation: VFLInterpolation) -> [NSLayoutConstraint] {
    let (format, env) = interpolation.result()
    return VFL.VFLInstall(format, env)
}

public func VFLFullInstall(interpolation: VFLInterpolation) -> [NSLayoutConstraint] {
    let (format, env) = interpolation.result()
    return VFL.VFLFullInstall(format, env)
}

public enum VFLInterpolation : StringInterpolationConvertible, StringLiteralConvertible {

    case Format(String)
    case Metric(CGFloat)
    case Collection([VFLInterpolation])
    case Other(AnyObject)

    // MARK: StringLiteralConvertible
    public init(stringLiteral value: StringLiteralType){
        self = .Format(value)
    }

    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterType){
        self = .Format(value)
    }

    public init(unicodeScalarLiteral value: UnicodeScalarType) {
        self = .Format(value)
    }

    // MARK: StringInterpolationConvertible
    public init(stringInterpolation strings: VFLInterpolation...) {
        self = .Collection(strings)
    }

    public init(stringInterpolationSegment str: String) {
        self = .Format(str)
    }

    public init(stringInterpolationSegment value: CGFloat) {
        self = .Metric(value)
    }

    public init<T>(stringInterpolationSegment expr: T) {
        self = .Other( expr as! AnyObject )
    }

    func result() -> (format: String, env: [AnyObject])! {
        switch self {
        case .Collection(let parts):
            let env = NSMutableArray(capacity: parts.count)
            let format = NSMutableString()
            for part in parts {
                switch part {
                case .Format(let str):
                    format.appendString(str)
                case .Metric(let value):
                    format.appendFormat("$%u", env.count)
                    env.addObject(value)
                case .Other(let obj):
                    format.appendFormat("$%u", env.count)
                    env.addObject(obj)
                default:
                    assertionFailure("invalid part to build result")
                }
            }
            return (format as String, env as [AnyObject])
        case .Format(let format):
            return (format, [])
        default:
            assertionFailure("call result on incomplete type")
            return nil
        }
    }
}

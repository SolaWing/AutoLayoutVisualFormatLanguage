//  Gihhub: https://github.com/SolaWing/AutoLayoutVisualFormatLanguage
//
//  VFLInterpolation.swift
//  AutoLayoutVisualFormat
//
//  Created by SolaWing on 15/12/13.
//  Copyright © 2015年 SW. All rights reserved.
//

import Foundation
import UIKit

public func constraints(_ interpolation: VFLInterpolation) -> [NSLayoutConstraint] {
    let (format, env) = interpolation.result()
    return VFL.VFLConstraints(format, env)
}

@discardableResult
public func install(_ interpolation: VFLInterpolation) -> [NSLayoutConstraint] {
    let (format, env) = interpolation.result()
    return VFL.VFLInstall(format, env)
}

@discardableResult
public func fullInstall(_ interpolation: VFLInterpolation) -> [NSLayoutConstraint] {
    let (format, env) = interpolation.result()
    return VFL.VFLFullInstall(format, env)
}

func buildInterpolationResult(_ parts: [VFLInterpolation]) -> (format: String, env: [AnyObject])! {
    let format = NSMutableString()
    let env = NSMutableArray()
    for part in parts {
        part.result(format, env)
        if !format.hasSuffix(";") {
            format.append("; ")
        }
    }
    return (format as String, env as [AnyObject])
}

// array of VFLInterpolation for long interpolation string

public func constraints(_ interpolation: [VFLInterpolation]) -> [NSLayoutConstraint] {
    let (format, env) = buildInterpolationResult(interpolation)
    return VFL.VFLConstraints(format, env)
}

@discardableResult
public func install(_ interpolation: [VFLInterpolation]) -> [NSLayoutConstraint] {
    let (format, env) = buildInterpolationResult(interpolation)
    return VFL.VFLInstall(format, env)
}

@discardableResult
public func fullInstall(_ interpolation: [VFLInterpolation]) -> [NSLayoutConstraint] {
    let (format, env) = buildInterpolationResult(interpolation)
    return VFL.VFLFullInstall(format, env)
}

// MARK: -
public enum VFLInterpolation : ExpressibleByStringInterpolation, ExpressibleByStringLiteral {

    case format(String)
    case metric(CGFloat)
    case collection([VFLInterpolation])
    case other(AnyObject)

    // MARK: ExpressibleByStringLiteral
    public init(stringLiteral value: StringLiteralType){
        self = .format(value)
    }

    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterType){
        self = .format(value)
    }

    public init(unicodeScalarLiteral value: UnicodeScalarType) {
        self = .format(value)
    }

    // MARK: ExpressibleByStringInterpolation
    public init(stringInterpolation strings: VFLInterpolation...) {
        self = .collection(strings)
    }

    public init(stringInterpolationSegment str: String) {
        self = .format(str)
    }

    public init(stringInterpolationSegment value: CGFloat) {
        self = .metric(value)
    }

    public init<T>(stringInterpolationSegment expr: T) {
        self = .other( expr as AnyObject )
    }

    func result() -> (format: String, env: [AnyObject])! {
        switch self {
        case .collection(let parts):
            let env = NSMutableArray(capacity: parts.count)
            let format = NSMutableString()
            for part in parts {
                part.result(format, env)
            }
            return (format as String, env as [AnyObject])
        case .format(let format):
            return (format, [])
        default:
            assertionFailure("call result on incomplete type")
            return nil
        }
    }

    /** fill format and env acording to self part */
    func result(_ format: NSMutableString, _ env: NSMutableArray) {
        switch self {
        case .format(let str):
            format.append(str)
        case .metric(let value):
            format.appendFormat("$%u", env.count)
            env.add(value)
        case .other(let obj):
            format.appendFormat("$%u", env.count)
            env.add(obj)
        case .collection(let parts): // recursive add format and env
            for part in parts {
                part.result(format, env)
            }
        }
    }
}

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
        part.resultInto(format, env)
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
public struct VFLInterpolation : ExpressibleByStringInterpolation, ExpressibleByStringLiteral {
    public struct StringInterpolation: StringInterpolationProtocol {
        public init(literalCapacity: Int, interpolationCount: Int) {
            storage.reserveCapacity(interpolationCount * 2 + 1)
        }
        public init(string: String) {
            storage.append(.format(string))
        }

        public mutating func appendLiteral(_ literal: StringLiteralType) {
            storage.append(.format(literal))
        }
        public mutating func appendInterpolation<T: BinaryFloatingPoint>(_ value: T) {
            storage.append(.metric(CGFloat(value)))
        }
        public mutating func appendInterpolation<T: BinaryInteger>(_ value: T) {
            storage.append(.metric(CGFloat(value)))
        }
        public mutating func appendInterpolation<T: AnyObject>(_ value: T) {
            storage.append(.other(value))
        }
        public enum Parts {
            /// literal string part
            case format(String)
            /// metrics part
            case metric(CGFloat)
            /// any constraint item type, like View or guide
            case other(AnyObject)
        }
        var storage = [Parts]()
    }
    var parts: StringInterpolation

    // MARK: ExpressibleByStringLiteral
    public init(stringLiteral value: StringLiteralType){
        parts = StringInterpolation(string: value)
    }

    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterType){
        parts = StringInterpolation(string: value)
    }

    public init(unicodeScalarLiteral value: UnicodeScalarType) {
        parts = StringInterpolation(string: value)
    }

    // MARK: ExpressibleByStringInterpolation
    public init(stringInterpolation: StringInterpolation) {
        parts = stringInterpolation
    }

    func fillResult(format: NSMutableString, env: NSMutableArray, part: StringInterpolation.Parts) {
        switch part {
        case .format(let str):
            format.append(str)
        case .metric(let value):
            format.appendFormat("$%u", env.count)
            env.add(value)
        case .other(let obj):
            format.appendFormat("$%u", env.count)
            env.add(obj)
        }
    }

    func result() -> (format: String, env: [AnyObject])! {
        let parts = self.parts.storage
        let env = NSMutableArray(capacity: parts.count)
        let format = NSMutableString()
        resultInto(format, env)
        return (format as String, env as [AnyObject])
    }

    /// fill format and env acording to self part
    func resultInto(_ format: NSMutableString, _ env: NSMutableArray) {
        parts.storage.forEach {
            fillResult(format: format, env: env, part: $0)
        }
    }
}

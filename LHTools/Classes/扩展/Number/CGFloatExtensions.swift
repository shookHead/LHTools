//
//  CGFloatExtensions.swift
//  LHTools
//
//  Created by 海 on 2022/11/2.
//  Copyright © 2022 CocoaPods. All rights reserved.
//


public extension CGFloat {
    
    ///返回给定数字的绝对值
    var abs: CGFloat {
        return Swift.abs(self)
    }

    #if canImport(Foundation)
    /// 向上取整
    var ceil: CGFloat {
        return Foundation.ceil(self)
    }
    #endif

    #if canImport(Foundation)
    /// 取整数   8.4 --> 8       8.8-->8
    var floor: CGFloat {
        return Foundation.floor(self)
    }
    #endif

    /// 是否为正
    var isPositive: Bool {
        return self > 0
    }

    /// 是否为负
    var isNegative: Bool {
        return self < 0
    }

    var int: Int {
        return Int(self)
    }

    var float: Float {
        return Float(self)
    }

    var double: Double {
        return Double(self)
    }

    /// SwifterSwift: Radian value of degree input.
    var degreesToRadians: CGFloat {
        return .pi * self / 180.0
    }
    
    /// SwifterSwift: Degree value of radian input.
    var radiansToDegrees: CGFloat {
        return self * 180 / CGFloat.pi
    }
}

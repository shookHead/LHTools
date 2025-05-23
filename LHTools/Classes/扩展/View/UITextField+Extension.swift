//
//  UITextField+Extension.swift
//  LHTools
//
//  Created by clh on 2021/12/13.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

extension UITextField {
    /// 设置占位文字
    /// - Parameters:
    ///   - string: 字符串
    ///   - color: 颜色
    ///   - font: 字体
    @available(*, deprecated, message: "此方法已过期，请使用新方法 setPlaceholderColor() 替代")
    public func setPlaceholder(_ string: String, color: UIColor? = nil, font: UIFont? = nil) {
        let attributedString = NSMutableAttributedString(string: string)
        if let color = color {
            attributedString.addAttributes([NSAttributedString.Key.foregroundColor: color], range: NSRange(location: 0, length: string.count))
        }
        if let font = font {
            attributedString.addAttributes([NSAttributedString.Key.font: font], range: NSRange(location: 0, length: string.count))
        }
        attributedPlaceholder = attributedString
    }
    
    public func setPlaceholderColor(color: UIColor? = nil) {
        let string = self.placeholder ?? ""
        let font = self.font
        let attributedString = NSMutableAttributedString(string: string)
        if let color = color {
            attributedString.addAttributes([NSAttributedString.Key.foregroundColor: color], range: NSRange(location: 0, length: string.count))
        }
        if let font = font {
            attributedString.addAttributes([NSAttributedString.Key.font: font], range: NSRange(location: 0, length: string.count))
        }
        attributedPlaceholder = attributedString
    }
    
}

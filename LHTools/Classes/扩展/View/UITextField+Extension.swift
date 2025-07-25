//
//  UITextField+Extension.swift
//  LHTools
//
//  Created by clh on 2021/12/13.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

extension UITextField {
    
    /// 设置占位符的文字、颜色和字体
    /// - Parameters:
    ///   - text: 占位符文字，如果不传则使用当前 placeholder
    ///   - color: 占位符颜色
    ///   - font: 占位符字体
    public func setPlaceholder(_ text: String? = nil, color: UIColor? = nil, font: UIFont? = nil) {
        let placeholderText = text ?? self.placeholder ?? ""
        let fontToUse = font ?? self.font
        let attributedString = NSMutableAttributedString(string: placeholderText)
        
        let fullRange = NSRange(location: 0, length: placeholderText.count)
        
        if let color = color {
            attributedString.addAttribute(.foregroundColor, value: color, range: fullRange)
        }
        if let fontToUse = fontToUse {
            attributedString.addAttribute(.font, value: fontToUse, range: fullRange)
        }
        self.attributedPlaceholder = attributedString
    }
    
    
    /// 已废弃：请使用 `setPlaceholder(_:color:font:)` 替代
    public func setPlaceholderColor(color: UIColor? = nil) {
        let string = self.placeholder ?? ""
        let font = self.font
        setPlaceholder(string, color: color, font: font)
    }

    
}

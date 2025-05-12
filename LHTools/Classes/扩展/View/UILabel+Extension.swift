//
//  UILabel+Extension.swift
//  LHTools_Example
//
//  Created by clh on 2021/12/28.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

extension UILabel {
    ///拿到文本宽度，默认一行
    public func getLabelWidth(maxSize: CGSize = CGSize(width: 10000, height: 0)) -> CGFloat {
        let size = stringSize(maxSize: maxSize)
        return size.width
    }
    ///拿到文本高度
    public func getLabelHeight(maxSize: CGSize) -> CGFloat {
        let size = stringSize(maxSize: maxSize)
        return size.height
    }
    ///计算UILabel宽高,可以不传maxSize
    public func stringSize(maxSize: CGSize = CGSizeZero) -> CGSize {
        guard let text = text, !text.isEmpty else {
            return CGSize.zero
        }
        // 强制使用当前有效宽度（重要！）
        let effectiveWidth = bounds.width > 0 ? bounds.width : .greatestFiniteMagnitude
        
        let font = self.font ?? UIFont.systemFont(ofSize: 17)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping // 明确换行模式
        paragraphStyle.alignment = textAlignment
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle
        ]
        var constraintSize = CGSizeZero
        if maxSize == CGSizeZero {
            constraintSize = CGSize(width: effectiveWidth, height: .greatestFiniteMagnitude)
        }else{
            constraintSize = maxSize
        }
        let size = text.boundingRect(
            with: constraintSize,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        )
        var newSize = CGSizeMake(size.width.rounded(.up), size.height.rounded(.up))
        if numberOfLines != 0 {
            let maxLinesHeight = CGFloat(numberOfLines) * font.lineHeight
            newSize.height = maxLinesHeight.rounded(.up)
            return newSize
        }
        return newSize
    }
    /// 计算UILabel所需高度，需先设置宽度
    public func stringGetHeight(minH: CGFloat? = nil) -> CGFloat {
           guard let text = text, !text.isEmpty else {
               return minH ?? 0
           }
           // 强制使用当前有效宽度（重要！）
           let effectiveWidth = bounds.width > 0 ? bounds.width : .greatestFiniteMagnitude
           let font = self.font ?? UIFont.systemFont(ofSize: 17)
           let paragraphStyle = NSMutableParagraphStyle()
           paragraphStyle.lineBreakMode = .byWordWrapping // 明确换行模式
           paragraphStyle.alignment = textAlignment
           let attributes: [NSAttributedString.Key: Any] = [
               .font: font,
               .paragraphStyle: paragraphStyle
           ]
           
           let constraintSize = CGSize(width: effectiveWidth, height: .greatestFiniteMagnitude)
           let textHeight = text.boundingRect(
               with: constraintSize,
               options: [.usesLineFragmentOrigin, .usesFontLeading],
               attributes: attributes,
               context: nil
           ).height.rounded(.up)
           
           if numberOfLines != 0 {
               let maxLinesHeight = CGFloat(numberOfLines) * font.lineHeight
               return max(min(textHeight, maxLinesHeight), minH ?? 0)
           }
           return max(textHeight, minH ?? 0)
       }
    ///计算UILabel宽高 带NSMutableParagraphStyle
    public func stringSizeParaStyle(maxSize: CGSize,paraStyle:NSMutableParagraphStyle) -> CGSize {
        guard let textTemp = text, textTemp.count > 0 else {
            return CGSize.zero
        }
        var textDict:[NSAttributedString.Key : Any] = [:]
        textDict[.font] = self.font
        textDict[.paragraphStyle] = paraStyle
        let size = textTemp.boundingRect(with: maxSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: textDict, context: nil).size
        return CGSize(width: size.width.rounded(.up), height: size.height.rounded(.up))
    }
    ///拿到最后一个文字的位置
    public func getLast(width:CGFloat) -> CGPoint{
        var lastPoint:CGPoint = CGPoint.zero
        if text == nil {
            return lastPoint
        }
        let attributes = [NSAttributedString.Key.font:self.font]
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let sz = self.text!.boundingRect(with: CGSize(width: 10000, height: 40), options: option, attributes: attributes as [NSAttributedString.Key : Any], context: nil)
        let lineSz = self.text!.boundingRect(with: CGSize(width: width, height: 10000), options: option, attributes: attributes as [NSAttributedString.Key : Any], context: nil)
        if sz.width <= lineSz.width {
            lastPoint = CGPoint(x: self.frame.origin.x + sz.width, y: self.frame.origin.y)
        }else{
            lastPoint = CGPoint(x: self.frame.origin.x + CGFloat(Int(sz.width) % Int(lineSz.width)), y:self.frame.origin.y + lineSz.height - sz.height)
        }
        return lastPoint
    }
    ///设置行间距
    public func setLabelLineSpacing(lineSpacing: CGFloat) {
        guard let labelText = self.text else { return }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        
        let attributedString = NSMutableAttributedString(string: labelText)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        self.attributedText = attributedString
    }
}

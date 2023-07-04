//
//  UILabel+Extension.swift
//  LHTools_Example
//
//  Created by clh on 2021/12/28.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

extension UILabel{
    ///拿到文本宽度，默认一行
    public func getLabelWidth(maxSize: CGSize = CGSize(width: 10000, height: 0)) -> CGFloat {
        let size = stringSize(maxSize: maxSize)
        return ceil(size.width)
    }
    ///拿到文本高度
    public func getLabelHeight(maxSize: CGSize) -> CGFloat {
        let size = stringSize(maxSize: maxSize)
        return ceil(size.height)
    }
    ///计算UILabel宽高
    public func stringSize(maxSize: CGSize) -> CGSize {
        guard let textTemp = text, textTemp.count > 0 else {
            return CGSize.zero
        }
        let size = textTemp.boundingRect(with: maxSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: self.font as Any], context: nil).size
        if numberOfLines == 0 {
            return size
        }
        let singleSize = lhGood.boundingRect(with: CGSize(width: self.w, height: 10000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: self.font as Any], context: nil).size
        let h = size.height > CGFloat(numberOfLines) * singleSize.height ? CGFloat(numberOfLines) * singleSize.height:size.height
        return CGSize(width: ceil(size.width), height: ceil(h))
    }
    ///此方法需先设置宽度
    public func stringGetHeight(minH:CGFloat? = nil) -> CGFloat {
        guard let textTemp = text, textTemp.count > 0 else {
            return minH == nil ? 0:18
        }
        let size = textTemp.boundingRect(with: CGSize(width: self.w, height: 10000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: self.font as Any], context: nil).size
        if numberOfLines == 0 {
            if let minHeight = minH {
                return size.height < minHeight ? minHeight:size.height
            }
            return ceil(size.height)
        }
        let singleSize = lhGood.boundingRect(with: CGSize(width: self.w, height: 10000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: self.font as Any], context: nil).size
        var h = size.height > CGFloat(numberOfLines) * singleSize.height ? CGFloat(numberOfLines) * singleSize.height:size.height
        h = ceil(h)
        if let minHeight = minH {
            return h < minHeight ? minHeight:h
        }
        return h
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
        return CGSize(width: ceil(size.width), height: ceil(size.height))
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
}

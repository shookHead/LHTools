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
        return size.width
    }
    ///拿到文本高度
    public func getLabelHeight(maxSize: CGSize) -> CGFloat {
        let size = stringSize(maxSize: maxSize)
        return size.height
    }
    public func stringSize(maxSize: CGSize) -> CGSize {
        guard let textTemp = text, textTemp.count > 0 else {
            return CGSize.zero
        }
        return textTemp.boundingRect(with: maxSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: self.font as Any], context: nil).size
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

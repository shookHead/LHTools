//
//  UIView+IBInspectable.swift
//  wangfuAgent
//
//  Created by  on 2018/8/8.
//  Copyright © 2018 zhuanbangTec. All rights reserved.
//

import Foundation
import UIKit
import ObjectiveC
private var gradientBorderWidthKey: UInt8 = 0

extension UIView{
    ///设置边角大小
    @IBInspectable open var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    public func showWithAnimation(_ time:Double = 0.2){
        self.alpha = 0
        UIView.animate(withDuration: time) {
            self.alpha = 1
        }
    }
    
    public func showWithAnimation(delay:Double, _ time:Double = 0.2){
        self.alpha = 0
        UIView.animate(withDuration: time, delay: delay,animations: {
            self.alpha = 1
        }) { (_) in
            
        }
    }
    
    public var x:CGFloat{
        get{
            return self.frame.origin.x
        }
        set{
            self.frame.origin.x = newValue
        }
    }
    public var y:CGFloat{
        get{
            return self.frame.origin.y
        }
        set{
            self.frame.origin.y = newValue
        }
    }
    public var w:CGFloat{
        get{
            return self.frame.width
        }
        set{
            self.frame.size.width = newValue
        }
    }
    public var h:CGFloat{
        get{
            return self.frame.height
        }
        set{
            self.frame.size.height = newValue
        }
    }
    
    public var centerX:CGFloat{
        get{
            return self.center.x
        }
        set{
            self.center.x = newValue
        }
    }
    public var centerY:CGFloat{
        get{
            return self.center.y
        }
        set{
            self.center.y = newValue
        }
    }
    public var maxY:CGFloat{
        return self.frame.maxY
    }
    public var maxX:CGFloat{
        return self.frame.maxX
    }
}

extension UIView {
    // 记录当前边框宽度
    public var gradientBorderWidth: CGFloat {
        get { (objc_getAssociatedObject(self, &gradientBorderWidthKey) as? CGFloat) ?? 0 }
        set { objc_setAssociatedObject(self, &gradientBorderWidthKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    // 设置圆角
    @discardableResult
    public func setCornerRadius(_ radius: CGFloat) -> Self {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
        return self
    }

    // 设置边框纯色
    @discardableResult
    public func setBorder(color: UIColor, width: CGFloat) -> Self {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
        self.gradientBorderWidth = width
        return self
    }

    // 设置边框渐变色
    @discardableResult
    public func setGradientBorder(colors: [UIColor], width: CGFloat, startPoint: CGPoint = CGPoint(x: 0, y: 0.5), endPoint: CGPoint = CGPoint(x: 1, y: 0.5)) -> Self {
        // 移除旧的渐变边框
        self.layer.sublayers?.removeAll(where: { $0.name == "GradientBorderLayer" })
        self.gradientBorderWidth = width

        let gradientLayer = CAGradientLayer()
        gradientLayer.name = "GradientBorderLayer"
        gradientLayer.frame = self.bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint

        let shape = CAShapeLayer()
        shape.lineWidth = width
        shape.path = UIBezierPath(roundedRect: self.bounds.insetBy(dx: width/2, dy: width/2), cornerRadius: self.layer.cornerRadius).cgPath
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = shape

        self.layer.addSublayer(gradientLayer)
        return self
    }

    // 设置背景色
    @discardableResult
    public func setBackgroundColor(_ color: UIColor) -> Self {
        self.backgroundColor = color
        return self
    }

    // 设置渐变背景色
    @discardableResult
    public func setGradientBackground(colors: [UIColor], startPoint: CGPoint = CGPoint(x: 0, y: 0.5), endPoint: CGPoint = CGPoint(x: 1, y: 0.5)) -> Self {
        // 移除旧的渐变背景
        self.layer.sublayers?.removeAll(where: { $0.name == "GradientBackgroundLayer" })

        let gradientLayer = CAGradientLayer()
        gradientLayer.name = "GradientBackgroundLayer"
        gradientLayer.frame = self.bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.cornerRadius = self.layer.cornerRadius

        // 用 mask 裁剪背景色，防止超出边框
        let maskLayer = CAShapeLayer()
        let borderWidth = self.gradientBorderWidth
        maskLayer.path = UIBezierPath(roundedRect: self.bounds.insetBy(dx: borderWidth, dy: borderWidth), cornerRadius: max(0, self.layer.cornerRadius - borderWidth)).cgPath
        maskLayer.fillColor = UIColor.black.cgColor
        gradientLayer.mask = maskLayer

        self.layer.insertSublayer(gradientLayer, at: 0)
        return self
    }
}

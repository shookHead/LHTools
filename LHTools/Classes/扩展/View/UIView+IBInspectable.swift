//
//  UIView+IBInspectable.swift
//  wangfuAgent
//
//  Created by  on 2018/8/8.
//  Copyright © 2018 zhuanbangTec. All rights reserved.
//

import Foundation
import UIKit

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


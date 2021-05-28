//
//  UIColor+Utils.swift
//  wangfuAgent
//
//  Created by lzw on 2018/9/6.
//  Copyright © 2018 zhuanbangTec. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    ///生成颜色图片
    public var image:UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(self.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

extension UIColor {
    
    open class var maskView: UIColor    { return UIColor.black.withAlphaComponent(0.45)}
    
    open class var KBlue: UIColor       { return #colorLiteral(red: 0.1274686485, green: 0.5686141059, blue: 0.9647058824, alpha: 1) }
    open class var KRed: UIColor        { return #colorLiteral(red: 0.9803921569, green: 0.333299367, blue: 0.3461571215, alpha: 1) }
    open class var KOrange: UIColor     { return #colorLiteral(red: 1, green: 0.3843137255, blue: 0.231372549, alpha: 1) }
    
    open class var KTextBlack: UIColor  { return #colorLiteral(red: 0.2588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1) }
    open class var KTextGray: UIColor   { return #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1) }
    open class var KTextLightGray: UIColor { return #colorLiteral(red: 0.7176470588, green: 0.7176470588, blue: 0.7176470588, alpha: 1) }
    open class var KBGGray: UIColor     { return #colorLiteral(red: 0.9647058824, green: 0.9764705882, blue: 0.9882352941, alpha: 1) }
    open class var KBGGrayLine: UIColor { return #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1) }
    
    /// RGB 0～255
    open class func rgb(_ red:CGFloat, _ green:CGFloat, _ blue:CGFloat) -> UIColor {
        return UIColor.init(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1)
    }
    
    
    /// 支持“#”， 三位"FFF"，六位"FFFFFF"
    open class func hex(_ hex:String) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString = cString.replacingOccurrences(of: "#", with: "")
        }
        var rString = "00"
        var gString = "00"
        var bString = "00"
        if cString.count == 3{
            rString = cString[0]+cString[0]
            gString = cString[1]+cString[1]
            bString = cString[2]+cString[2]
        }else if cString.count == 6{
            rString = cString[0]+cString[1]
            gString = cString[2]+cString[3]
            bString = cString[4]+cString[5]
        }

        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
    
    public func alpha(_ alpha:CGFloat) -> UIColor {
        return self.withAlphaComponent(alpha)
    }
}




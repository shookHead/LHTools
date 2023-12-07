//
//  UIColor+Utils.swift
//  wangfuAgent
//
//  Created by  on 2018/9/6.
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
    
    public class var maskView: UIColor    { return UIColor.black.withAlphaComponent(0.45)}
    
    public class var KBlue: UIColor       { return #colorLiteral(red: 0.1274686485, green: 0.5686141059, blue: 0.9647058824, alpha: 1) }
    public class var KRed: UIColor        { return #colorLiteral(red: 0.9803921569, green: 0.333299367, blue: 0.3461571215, alpha: 1) }
    public class var KOrange: UIColor     { return #colorLiteral(red: 1, green: 0.3843137255, blue: 0.231372549, alpha: 1) }
    
    public class var KTextBlack: UIColor  { return #colorLiteral(red: 0.2588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1) }
    public class var KTextGray: UIColor   { return #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1) }
    public class var KTextLightGray: UIColor { return #colorLiteral(red: 0.7176470588, green: 0.7176470588, blue: 0.7176470588, alpha: 1) }
    public class var KBGGray: UIColor     { return #colorLiteral(red: 0.9647058824, green: 0.9764705882, blue: 0.9882352941, alpha: 1) }
    public class var KBGGrayLine: UIColor { return #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1) }
    
    /// RGB 0～255
    public class func rgb(_ red:CGFloat, _ green:CGFloat, _ blue:CGFloat) -> UIColor {
        return UIColor.init(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1)
    }
    
    public convenience init?(hexString: String, transparency: CGFloat = 1) {
        var string = ""
        if hexString.lowercased().hasPrefix("0x") {
            string =  hexString.replacingOccurrences(of: "0x", with: "")
        } else if hexString.hasPrefix("#") {
            string = hexString.replacingOccurrences(of: "#", with: "")
        } else {
            string = hexString
        }
        
        if string.count == 3 { // convert hex to 6 digit format if in short format
            var str = ""
            string.forEach { str.append(String(repeating: String($0), count: 2)) }
            string = str
        }
        
        guard let hexValue = Int(string, radix: 16) else { return nil }
        
        var trans = transparency
        if trans < 0 { trans = 0 }
        if trans > 1 { trans = 1 }
        
        let red = (hexValue >> 16) & 0xff
        let green = (hexValue >> 8) & 0xff
        let blue = hexValue & 0xff
        self.init(red: red, green: green, blue: blue, transparency: trans)
    }
    public convenience init?(red: Int, green: Int, blue: Int, transparency: CGFloat = 1) {
        guard red >= 0 && red <= 255 else { return nil }
        guard green >= 0 && green <= 255 else { return nil }
        guard blue >= 0 && blue <= 255 else { return nil }
        
        var trans = transparency
        if trans < 0 { trans = 0 }
        if trans > 1 { trans = 1 }
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: trans)
    }
    /// 支持“#”， 三位"FFF"，六位"FFFFFF"
    public class func hex(_ hex:String,_ alpha:CGFloat = 1) -> UIColor {
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
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
    
    public func alpha(_ alpha:CGFloat) -> UIColor {
        return self.withAlphaComponent(alpha)
    }
    ///获取随机颜色
    public static var random: UIColor{
        return UIColor.init(red: CGFloat(arc4random()&255)/255, green: CGFloat(arc4random()&255)/255, blue: CGFloat(arc4random()&255)/255, alpha: 1)
    }
}




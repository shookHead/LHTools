//
//  Sting+Utils.swift
//  wangfuAgent
//
//  Created by  on 2018/7/18.
//  Copyright © 2018 zhuanbangTec. All rights reserved.
//

import UIKit
import Foundation


// MARK: -  ----------------------  ------------------------
extension Optional where Wrapped == String{
    /// if nil or "" return false
    public var notEmpty: Bool {
        if self == nil{
            return false
        }
        return !self!.isEmpty
    }
}

// MARK: -  ---------------------- 文字宽高 ------------------------
extension String{
    public func stringWidth(_ fontSize:CGFloat) -> CGFloat{
        let font:UIFont = UIFont.systemFont(ofSize: fontSize)
        let attributes = [NSAttributedString.Key.font:font]
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let rect:CGRect = self.boundingRect(with: CGSize(width: 2000.0, height: fontSize*1.4), options: option, attributes: attributes, context: nil)
        return ceil(rect.size.width)
    }
    
    public func stringHeight(_ fontSize:CGFloat, width:CGFloat) -> CGFloat{
        let font:UIFont = UIFont.systemFont(ofSize: fontSize)
        let attributes = [NSAttributedString.Key.font:font]
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        var rect:CGRect!

        if self.count != 0 {
            rect = self.boundingRect(with: CGSize(width: width, height: 2000), options: option, attributes: attributes, context: nil)
        }else{
            rect = " ".boundingRect(with: CGSize(width: width, height: 2000), options: option, attributes: attributes, context: nil)
        }
        return ceil(rect.size.height)
    }
    public func stringHeight(_ font:UIFont, width:CGFloat) -> CGFloat{
        let font:UIFont = font
        let attributes = [NSAttributedString.Key.font:font]
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        var rect:CGRect!
        if self.count != 0 {
            rect = self.boundingRect(with: CGSize(width: width, height: 2000), options: option, attributes: attributes, context: nil)
        }else{
            rect = " ".boundingRect(with: CGSize(width: width, height: 2000), options: option, attributes: attributes, context: nil)
        }
        return ceil(rect.size.height)
    }
    public func stringSize(_ text: String?, font: UIFont, maxSize: CGSize, mode: NSLineBreakMode) -> CGSize {
        guard let textTemp = text, textTemp.count > 0 else {
            return CGSize.zero
        }
        let size = textTemp.boundingRect(with: maxSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil).size
        return CGSize(width: ceil(size.width), height: ceil(size.height))
    }
    public func stringSize(font: UIFont, maxSize: CGSize) -> CGSize {
        guard self.count > 0 else {
            return CGSize.zero
        }
        let size = self.boundingRect(with: maxSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil).size
        return CGSize(width: ceil(size.width), height: ceil(size.height))
    }
    ///建议使用这个
    func boundingRect(font: UIFont, limitSize: CGSize) -> CGSize {
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byCharWrapping
        
        let att = [NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle: style]
        
        let attContent = NSMutableAttributedString(string: self, attributes: att)
        
        let size = attContent.boundingRect(with: limitSize, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).size
        
        return CGSize(width: ceil(size.width), height: ceil(size.height))
    }
}

// MARK: -  ---------------------- 文字判断处理 ------------------------
public extension String{
    /// if nil or "" return false
    var notEmpty: Bool {
        return !self.isEmpty
    }
    
    /// 用于textviewDelegate里 获得输入后的问字
    mutating func replace(nsRange:NSRange,text:String){
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return }
        let range = from ..< to
        self.replaceSubrange(range, with: text)
    }
    
    func substring(_ toIndex:Int) -> String {
        if self.count == 0 {
            return ""
        }
        let index = self.index(self.startIndex, offsetBy: toIndex)
        return String(self.prefix(upTo: index))
    }
    
    
    
    var urlEncode:String?{
        let new = self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        return new
    }

    var image:UIImage?{
        return UIImage(named: self)
    }

    
    ///去除前后空格
    func clearSpace() -> String {
        if self.count == 0 {
            return ""
        }
        let s = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return s
    }
    ///去除所有空格,指字符串中所有的
    var removeAllSapce:String {
        return self.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
    }

    
    /// NSRange转化为range
    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return nil }
        return from ..< to
    }
    ///判断是否为字母+数字
    func isLetterWithDigital() ->Bool{
        let numberRegex:NSPredicate=NSPredicate(format:"SELF MATCHES %@","^.*[0-9]+.*$")
        let letterRegex:NSPredicate=NSPredicate(format:"SELF MATCHES %@","^.*[A-Za-z]+.*$")
        if numberRegex.evaluate(with: self) && letterRegex.evaluate(with: self){
            return true
        }else{
            return false
        }
    }

    ///是否是手机号码
    var isPhone: Bool{
        if self.count == 11{
            return true
        }else{
            return false
        }
    }
    ///判断是否是邮箱地址
    func isEmailAddress() -> Bool {
        let emailRegex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest:NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: self)
    }
}


// MARK: -  ---------------------- 日期相关 ------------------------
extension String{
    ///返回固定格式字符串的日期
    public func getTimeString(formate:String) -> String {
        if self.count == 0 {
            return ""
        }
        let d = self.toDate("yyyy-MM-dd HH:mm:ss")
        let s = d?.toString(formate) ?? ""
        return s
    }
    public func toDateString(_ fromFormate:String = "yyyy-MM-dd HH:mm:ss",toFormate:String = "yyyy-MM-dd") -> String{
        if self.count == 0 {
            return ""
        }
        
        let timeZone = TimeZone.init(identifier: "Asia/Shanghai")
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = fromFormate
        let date = formatter.date(from: self)
        let s = date?.toString(toFormate)
        return s!
    }
}

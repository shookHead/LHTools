//
//  Date+String.swift
//  BaseUtilsDemo
//
//  Created by zbkj on 2020/12/25.
//  Copyright © 2020 yimi. All rights reserved.
//

import Foundation

extension String{
    /// "yyyy-MM-dd HH:mm:ss"  ->   Date()  字符串转时间
    public func toDate(_ dateFormat:String = "yyyy-MM-dd HH:mm:ss") -> Date!{
        let str:String = self
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.timeZone = TimeZone.init(identifier: "Asia/Shanghai")
        formatter.locale = Locale.init(identifier: "zh_CN")
        let date = formatter.date(from: str)
        return date!
    }
    
    /// "yyyy-MM-dd HH:mm:ss"  ->  1348747434  字符串转时间戳
    public func toTimeInterval(_ dateFormat:String? = "yyyy-MM-dd HH:mm:ss") -> TimeInterval {
        if self.isEmpty {
            return 0
        }
        let format = DateFormatter.init()
        format.dateStyle = .medium
        format.timeStyle = .short
        if dateFormat == nil {
            format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        }else{
            format.dateFormat = dateFormat
        }
        let date = format.date(from: self)
        let d = date!.timeIntervalSince1970
        return d
    }
    
    
    /// 转变日期字符串的样式
    public func changeDateStrFormate(fromFormate:String = "yyyy-MM-dd HH:mm:ss",toFormate:String = "yyyy-MM-dd") -> String{
        if self.count == 0 {
            return ""
        }
        let date = self.toDate(fromFormate)
        let s = date?.toString(toFormate)
        return s!
    }
    
    
}




//
//  Date+Utils.swift
//  wangfuAgent
//
//  Created by lzw on 2018/8/6.
//  Copyright © 2018 zhuanbangTec. All rights reserved.
//

import Foundation

extension Optional where Wrapped == Date{
    public var isToday: Bool{
        if self == nil {
            return false
        }else{
            return self!.isToday
        }
    }
}


extension Date {
    public func toString(_ dateFormat:String="yyyy-MM-dd HH:mm") -> String {
        let timeZone = TimeZone(identifier: "Asia/Shanghai")
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = dateFormat
        let date = formatter.string(from: self)
        return date
    }
    
    public func toTimeInterval() -> TimeInterval {
        return self.timeIntervalSince1970
    }

    public var yearString:String{
        return toString("yyyy")
    }
    
    public var monthString:String{
        return toString("MM")
    }
    
    public var dayString:String{
        return toString("dd")
    }
    
    public var hourString:String{
        return toString("HH")
    }
    
    public var minuteString:String{
        return toString("mm")
    }
    
    public var secendString:String{
        return toString("ss")
    }
    
    public var weekend:Int{
        let interval = Int(self.timeIntervalSince1970) + NSTimeZone.local.secondsFromGMT()
        let days = Int(interval/86400) // 24*60*60
        let weekday = ((days + 4)%7+7)%7
        return weekday == 0 ? 7 : weekday
    }
    
    // 是否是今天
    public var isToday: Bool{
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        return format.string(from: self) == format.string(from: Date())
    }

    public static func date(from string:String, formate:String) -> Date?{
        let timeZone = TimeZone.init(identifier: "Asia/Shanghai")
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = formate
        let date = formatter.date(from: string)
        return date
    }
    
    public func addTime(_ time:TimeInterval) -> Date {
        let t = self.timeIntervalSince1970 + time
        return Date.init(timeIntervalSince1970: t)
    }
    ///返回星期几
    public func getweekDay() ->String{
        let interval = Int(self.timeIntervalSince1970) + NSTimeZone.local.secondsFromGMT()
        let days = Int(interval/86400) // 24*60*60
        let weekday = ((days + 4)%7+7)%7
        let comps = weekday == 0 ? 7 : weekday
        var str = ""
        if comps == 1 {
            str = "周一"
        }else if comps == 2 {
            str = "周二"
        }else if comps == 3 {
            str =  "周三"
        }else if comps == 4 {
            str =  "周四"
        }else if comps == 5 {
            str =  "周五"
        }else if comps == 6 {
            str =  "周六"
        }else if comps == 7 {
            str =  "周日"
        }
        return str
    }
    ///返回第几周
    public func getWeek() -> Int{
        guard let calendar = NSCalendar(identifier: NSCalendar.Identifier.gregorian) else {
            return 1
        }
        let components = calendar.components([.weekOfYear,.weekOfMonth,.weekday,.weekdayOrdinal], from: self)
        //今年的第几周
        var weekOfYear = components.weekOfYear!
        
        //这个月第几周
        let weekOfMonth = components.weekOfMonth!
        //周几
        let weekday = components.weekday!
        //这个月第几周
        let weekdayOrdinal = components.weekdayOrdinal!
        print(weekOfYear)
        print(weekOfMonth)
        print(weekday)
        print(weekdayOrdinal)
        if weekOfYear == 1 && weekOfMonth != 1 {
            weekOfYear = 53
        }
        return weekOfYear
    }
    
}

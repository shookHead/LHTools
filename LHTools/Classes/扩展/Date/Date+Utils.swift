//
//  Date+Utils.swift
//  wangfuAgent
//
//  Created by  on 2018/8/6.
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


prefix operator >
prefix operator +
prefix operator -
prefix operator ==
extension Date {
    @available(*, deprecated, message: "此方法已过期，请使用新方法 dateToString() 替代")
    public func toString(_ dateFormat:String="yyyy-MM-dd HH:mm") -> String {
        let timeZone = TimeZone(identifier: "Asia/Shanghai")
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = dateFormat
        let date = formatter.string(from: self)
        return date
    }
    public func dateToString(_ dateFormat:String="yyyy-MM-dd HH:mm:ss") -> String {
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
        return dateToString("yyyy")
    }
    
    public var monthString:String{
        return dateToString("MM")
    }
    
    public var dayString:String{
        return dateToString("dd")
    }
    
    public var hourString:String{
        return dateToString("HH")
    }
    
    public var minuteString:String{
        return dateToString("mm")
    }
    
    public var secendString:String{
        return dateToString("ss")
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
            str = lhMonday
        }else if comps == 2 {
            str = lhTuesday
        }else if comps == 3 {
            str =  lhWednesday
        }else if comps == 4 {
            str =  lhThursday
        }else if comps == 5 {
            str =  lhFriday
        }else if comps == 6 {
            str =  lhSaturday
        }else if comps == 7 {
            str =  lhSunday
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

    ///开始时间到结束时间的一个倒计时
    public func dateDiff(startDate:Date?,endDate:Date?) -> String {
        if startDate == nil || endDate == nil {
            return "00:00:00"
        }
        let formatter = DateFormatter()
        let calendar = Calendar.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let diff:DateComponents = calendar.dateComponents([.year,.month,.day,.hour,.minute,.second], from: startDate!, to: endDate!)
        var hour = "00"
        if let h = diff.hour{
            if h >= 10{
                hour = String(h)
            }else{
                hour = "0" + String(h)
            }
        }
        var minute = "00"
        if let h = diff.minute{
            if h >= 10{
                minute = String(h)
            }else{
                minute = "0" + String(h)
            }
        }
        var second = "00"
        if let h = diff.second{
            if h >= 10{
                second = String(h)
            }else{
                second = "0" + String(h)
            }
        }
        return hour + ":" + minute + ":" + second
    }
}

//
//  Any+Utils.swift
//  wangfuAgent
//
//  Created by  on 2018/7/30.
//  Copyright © 2018 zhuanbangTec. All rights reserved.
//

import UIKit


extension Int{
    public func toString() -> String?{
        return String(self)
    }
    //转时间格式
    public func convertTimeIntervalToHHMMSS() -> String {
        if self == 0{
            return "00:00:00"
        }
        let timeInterval = TimeInterval(self)
        let date = Date(timeIntervalSince1970: timeInterval)
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
}

// MARK: -  ---------------------- 转换 ------------------------
extension String{
    ///判断 是否 是 数字
    public var isPurnInt:Bool {
        if let _ = Double(self){
            return true
        }
        return false
//        let scan: Scanner = Scanner(string: self)
//        var val:Int = 0
//        return scan.scanInt(&val) && scan.isAtEnd
    }
    
    public func toInt() -> Int{
        if let i = Int(self){
            return i
        }else{
            return 0
        }
    }
    
    public func toFloat() -> Float{
        if let i = Float(self){
            return i
        }else{
            return 0
        }
    }
    
    public func toDouble() -> Double{
        if let i = Double(self){
            return i
        }else{
            return 0
        }
    }
}

// MARK: -  ----------------------  ------------------------
extension Optional where Wrapped == String{
    /// if nil return 0
    public var bm_count:Int{
        if self == nil{
            return 0
        }else{
            return self!.count
        }
    }
    
    public func toInt() -> Int{
        if self == nil{
            return 0
        }else{
            if let i = Int(self!){
                return i
            }else{
                return 0
            }
        }
    }
    
    public func toFloat() -> Float{
        if self == nil{
            return 0
        }else{
            if let i = Float(self!){
                return i
            }else{
                return 0
            }
        }
    }
    
    public func toDouble() -> Double{
        if self == nil{
            return 0
        }else{
            if let i = Double(self!){
                return i
            }else{
                return 0
            }
        }
    }
}







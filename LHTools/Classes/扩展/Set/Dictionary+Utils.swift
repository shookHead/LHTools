//
//  Dictionary+Utils.swift
//  wangfu2
//
//  Created by yimi on 2019/5/23.
//  Copyright © 2019 zbkj. All rights reserved.
//

import Foundation

extension Dictionary {
    
    public func int(_ key: Key) -> Int?{
        let result = self[key] as? Int
        return result
    }
    
    public func string(_ key:Key) -> String?{
        let result = self[key] as? String
        return result
    }
    
    public func double(_ key:Key) -> Double?{
        let result = self[key] as? Double
        return result
    }
    
    public func dic(_ key:Key) -> Dictionary<String,Any>?{
        let result = self[key] as? Dictionary<String,Any>
        return result
    }
    
    public func getJsonStr() -> String?{
        let data = try? JSONSerialization.data(withJSONObject: self, options: [])
        if data != nil{
            let strJson = String(data: data!, encoding: String.Encoding.utf8)
            return strJson
        }
        return nil
    }
    
    public func pretyLog() -> String{
        var log = "{\n"
        for key in self.keys{
            let val = self[key]
            let valStr = String(describing: val!)
            log = "\(log)\t\(key):\(valStr)\n"
        }
        log = log + "}\n"
        return log
    }
    
}





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
        if let jsonData = try? JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions()) {
            let jsonStr = String(data: jsonData, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
            return String(jsonStr ?? "")
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



extension Dictionary {
    /// 检查是否存在在字典里
    ///
    ///        let dict: [String: Any] = ["testKey": "testValue", "testArrayKey": [1, 2, 3, 4, 5]]
    ///        dict.has(key: "testKey") -> true
    ///        dict.has(key: "anotherKey") -> false
    func has(key: Key) -> Bool {
        return index(forKey: key) != nil
    }
    
    /// 字典的key或者value组成的数组
    /// - Parameter map: map
    /// - Returns: 数组
    func toArray<V>(_ map: (Key, Value) -> V) -> [V] {
        return self.map(map)
    }
}

public extension Dictionary where Key: StringProtocol {
    /// 所有的字典里面，字母进行排序
    ///
    ///        var dict = ["tEstKeY": "value"]
    ///        dict.lowercaseAllKeys()
    ///        print(dict) // prints "["testkey": "value"]"
    ///
    mutating func lowercaseAllKeys() {
        for key in keys {
            if let lowercaseKey = String(describing: key).lowercased() as? Key {
                self[lowercaseKey] = removeValue(forKey: key)
            }
        }
    }
}

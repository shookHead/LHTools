//
//  Defaults_test.swift
//  BaseUtilsDemo
//
//  Created by yimi on 2019/5/24.
//  Copyright © 2019 yimi. All rights reserved.
//

import Foundation

///     示例：
///     // 支持基础数据类型，自定义模型<:HandyJSON>,数组，字典
///
///
///     extension BMDefaultsKeys{
///         // userId 和 sessionId 已封装进 请求库
///         static let userId = BMCacheKey<String?>("userId")
///         static let sessionId = BMCacheKey<String?>("sessionId")
///
///         static let p = BMCacheKey<Person?>("sessionId2")
///     }
///
///     Cache[.userId] = "123"
///

public let cache = BMCache()

public class BMDefaultsKeys {
    fileprivate init() {}
}

public class BMCacheKey<ValueType>: BMDefaultsKeys {
    public let _key: String
    public init(_ key: String) {
        self._key = key
        super.init()
    }
}

public class BMCache{
    
    let Defaults = UserDefaults.standard
    
    // String?
    public subscript(key: BMCacheKey<String?>) -> String? {
        get { return Defaults.string(forKey: key._key) }
        set { Defaults.set(newValue, forKey: key._key) }
    }
    // Int?
    public subscript(key: BMCacheKey<Int?>) -> Int? {
        get { return Defaults.integer(forKey: key._key) }
        set { Defaults.set(newValue, forKey: key._key) }
    }
    // Float?
    public subscript(key: BMCacheKey<Float?>) -> Float? {
        get { return Defaults.float(forKey: key._key) }
        set { Defaults.set(newValue, forKey: key._key) }
    }
    // Bool?
    public subscript(key: BMCacheKey<Bool?>) -> Bool? {
        get { return Defaults.bool(forKey: key._key) }
        set { Defaults.set(newValue, forKey: key._key) }
    }
    // Double?
    public subscript(key: BMCacheKey<Double?>) -> Double? {
        get { return Defaults.double(forKey: key._key) }
        set { Defaults.set(newValue, forKey: key._key) }
    }
    // 字典 Dictionary<String ,Any>?
    public subscript(key: BMCacheKey<Dictionary<String ,Any>?>) -> Dictionary<String ,Any>? {
        get { return Defaults.dictionary(forKey: key._key) }
        set { Defaults.set(newValue, forKey: key._key) }
    }
    // 模型 HandyJSON?
    public subscript<T:HandyJSON>(key: BMCacheKey<T?>) -> T? {
        get {
            let value = Defaults.string(forKey: key._key)
            let model = JSONDeserializer<T>.deserializeFrom(json: value)
            return model
        }
        set {
            if let newValueReal = newValue{
                let jsonCache = newValueReal.toJSONString()
                Defaults.set(jsonCache, forKey: key._key)
            }else{
                let temp:String? = nil
                Defaults.set(temp, forKey: key._key)
            }
        }
    }
    // 模型数组 Array<HandyJSON>
    public subscript<T:HandyJSON>(key: BMCacheKey<Array<T>?>) -> Array<T>? {
        get {
            let value = Defaults.string(forKey: key._key)
            let modelArr = JSONDeserializer<T>.deserializeModelArrayFrom(json: value) as? Array<T>
            return modelArr
        }
        set {
            if let newValueReal = newValue{
                let jsonCache = newValueReal.toJSONString()
                Defaults.set(jsonCache, forKey: key._key)
            }else{
                let temp:String? = nil
                Defaults.set(temp, forKey: key._key)
            }
        }
    }
    // 基础类型数组 Array<String>    Array<Int>   ...
    public subscript<T:BMOrignType>(key: BMCacheKey<Array<T>?>) -> Array<T>? {
        get { return Defaults.array(forKey: key._key) as? Array<T> }
        set { Defaults.set(newValue, forKey: key._key) }
    }
    
//    func dictionary(forKey key: String) -> Dictionary<String ,Any>?{
//        return Defaults.dictionary(forKey: key)
//    }
    
    //包含save的字段退出后不会被清除
    public func clearCache(_ needSaveAccount:Bool = false)  {
        let dic = Defaults.dictionaryRepresentation()
        for key in dic{
            if needSaveAccount {
                if (key.key == "userId" || key.key == "sessionId") {continue}
            }
            if !(key.key.contains("save")) {
                Defaults.removeObject(forKey: key.key)
            }
        }
        Defaults.synchronize()
    }
    
    public func allCache() -> Dictionary<String,Any> {
        let dic = Defaults.dictionaryRepresentation()
        return dic
    }
    
}

public protocol BMOrignType {}
extension Int   :BMOrignType{}
extension Float :BMOrignType{}
extension Double:BMOrignType{}
extension String:BMOrignType{}
extension Bool  :BMOrignType{}





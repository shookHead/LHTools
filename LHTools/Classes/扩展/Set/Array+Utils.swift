//
//  Sting+Utils.swift
//  wangfuAgent
//
//  Created by lzw on 2018/7/18.
//  Copyright © 2018 zhuanbangTec. All rights reserved.
//

import Foundation

extension Array{
    
    // 防止越界崩溃
    public func bm_object(_ at:Int) -> Element? {
        if at >= self.count || at < 0{
            return nil
        }else{
            return self[at]
        }
    }
    
    public func getJsonStr() -> String?{
        let data = try? JSONSerialization.data(withJSONObject: self, options: [])
        if data != nil{
            let strJson = String(data: data!, encoding: String.Encoding.utf8)
            return strJson
        }
        return nil
    }
    /**
     let arr = [1,1,2,2,3,3,4,4]
     let arr2 = arr.id_filterDuplicates({$0})
     print(arr2)
     */
    /// 模型去重需继承Equatable
    public func lh_filterDuplicates<E: Equatable>(_ filter: (Element) -> E) -> [Element] {
        var result = [Element]()
        for value in self {
            let key = filter(value)
            if !result.map({filter($0)}).contains(key) {
                result.append(value)
            }
        }
        return result
    }
    ///将数组分解为具有第一个元素和其余元素的元组
    public func decompose() -> (head: Iterator.Element, tail: SubSequence)? {
        return (count > 0) ? (self[0], self[1..<count]) : nil
    }
    ///使用索引对其数组的每个元素进行迭代
    public func forEachEnumerated(_ body: @escaping (_ offset: Int, _ element: Element) -> Void) {
        enumerated().forEach(body)
    }
    ///获取指定索引处的对象（如果存在）
    public func get(at index: Int) -> Element? {
        guard index >= 0 && index < count else { return nil }
        return self[index]
    }
    ///从数组中返回一个随机元素。
    public func random() -> Element? {
        guard count > 0 else { return nil }
        let index = Int(arc4random_uniform(UInt32(count)))
        return self[index]
    }
    ///使用Fisher-Yates-Durstenfeld算法在原位随机排列数组
    public mutating func shuffle() {
        guard count > 1 else { return }
        var j: Int
        for i in 0..<(count-2) {
            j = Int(arc4random_uniform(UInt32(count - i)))
            if i != i+j { self.swapAt(i, i+j) }
        }
    }
    ///使用Fisher-Yates-Durstenfeld算法对复制的数组进行混洗，返回混洗的数组
    public func shuffled() -> Array {
        var result = self
        result.shuffle()
        return result
    }
    ///返回从第一个到指定数量的数组
    public func takeMax(_ n: Int) -> Array {
        return Array(self[0..<Swift.max(0, Swift.min(n, count))])
    }
    public func testAll(_ body: @escaping (Element) -> Bool) -> Bool {
        return !contains { !body($0) }
    }
    public func testAll(is condition: Bool) -> Bool {
        return testAll { ($0 as? Bool) ?? !condition == condition }
    }
    ///获取json字符串
    func getJsonString() -> String {
        if self.count == 0 {
            return ""
        }
        if (!JSONSerialization.isValidJSONObject(self)) {
            print("无法解析出JSONString")
            return ""
        }
        
        let data : NSData! = try! JSONSerialization.data(withJSONObject: self, options: []) as NSData?
        let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue)
        return JSONString! as String
        
    }

//    /// 过滤重复元素
//    /// - Parameter path: KeyPath条件
//    public func filtered<E: Equatable>(duplication path: KeyPath<Element, E>) -> [Element] {
//        return reduce(into: [Element]()) { (result, e) in
//            let contains = result.contains { $0[keyPath: path] == e[keyPath: path] }
//            result += contains ? [] : [e]
//        }
//    }
//
//    /// 过滤重复元素
//    /// - Parameter closure: 过滤条件
//    public func filtered<E: Equatable>(duplication closure: (Element) throws -> E) rethrows -> [Element] {
//        return try reduce(into: [Element]()) { (result, e) in
//            let contains = try result.contains { try closure($0) == closure(e) }
//            result += contains ? [] : [e]
//        }
//    }
//
//    /// 过滤重复元素
//    /// - Parameter path: KeyPath条件
//    @discardableResult
//    public mutating func filter<E: Equatable>(duplication path: KeyPath<Element, E>) -> [Element] {
//        self = filtered(duplication: path)
//        return self
//    }
//
//    /// 过滤重复元素
//    /// - Parameter closure: 过滤条件
//    @discardableResult
//    public mutating func filter<E: Equatable>(duplication closure: (Element) throws -> E) rethrows -> [Element] {
//        self = try filtered(duplication: closure)
//        return self
//    }
}

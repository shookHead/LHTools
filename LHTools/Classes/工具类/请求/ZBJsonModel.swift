//
//  ZBJsonModel.swift
//  wenzhuan
//
//  Created by zbkj on 2020/5/21.
//  Copyright © 2020 baymax. All rights reserved.
//

import Foundation



// MARK: -  ---------------------- 专帮Json外层格式 ------------------------

/// data = 模型
public class ZBJsonModel<T:SmartCodable>: SmartCodable {
    public var code: Int!
    public var msg: String!
    public var data: T?
    required public init() { }
}

/// data = 模型数组
public class ZBJsonArrayModel<T:SmartCodable>: SmartCodable {
    public var code: Int!
    public var msg: String!
    public var data: Array<T>?
    required public init() { }
}

/// data = 数字
public class ZBJsonInt: SmartCodable {
    public var code: Int!
    public var msg: String!
    public var data: Int!
    required public init() { }
}

/// data = 字符串
public class ZBJsonString: SmartCodable {
    public var code: Int!
    public var msg: String!
    public var data: String!
    required public init() { }
}

/// data = 字符串
public class ZBJsonDic: SmartCodable {
    public var code: Int!
    public var msg: String!
    @SmartAny
    public var data: [String: Any]?
    required public init() { }
}

/// 其他float等古怪的接口返回类型就懒得写了  直接让后台改类型吧   哈哈


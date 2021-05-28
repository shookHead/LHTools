//
//  ZBJsonModel.swift
//  wenzhuan
//
//  Created by zbkj on 2020/5/21.
//  Copyright © 2020 baymax. All rights reserved.
//

import Foundation

public class BaseModel:  HandyJSON{
    required public init() { }
}


// MARK: -  ---------------------- 专帮Json外层格式 ------------------------

/// data = 模型
public class ZBJsonModel<T:HandyJSON>: BaseModel {
    public var code: Int!
    public var msg: String!
    public var data: T?
}

/// data = 模型数组
public class ZBJsonArrayModel<T:HandyJSON>: BaseModel {
    public var code: Int!
    public var msg: String!
    public var data: Array<T>?
}

/// data = 数字
public class ZBJsonInt: BaseModel {
    public var code: Int!
    public var msg: String!
    public var data: Int!
}

/// data = 字符串
public class ZBJsonString: BaseModel {
    public var code: Int!
    public var msg: String!
    public var data: String!
}

/// data = 字符串
public class ZBJsonDic: BaseModel {
    public var code: Int!
    public var msg: String!
    public var data:Dictionary<String,Any>?
}

/// 其他float等古怪的接口返回类型就懒得写了  直接让后台改类型吧   哈哈


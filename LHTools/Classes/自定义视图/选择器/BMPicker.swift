//
//  BMPicker.swift
//  wangfuAgent
//
//  Created by lzw on 2018/7/26.
//  Copyright © 2018 zhuanbangTec. All rights reserved.
//

import UIKit
public class BMPicker: NSObject {

    /// 简单的选择器
    ///
    /// - Parameters:
    ///   - dataArray   : 用于显示的字符串数组
    ///   - index       : 初始选择的值
    ///   - selected    : 点击确认后 回调 返回索引
    ///   - changed     : 数据改变 回调 返回索引
    /// - Returns: 返回选择器对象   调用show方法之前 可用于修改参数
    public static func singlePicker(_ data:Array<String>,_ index:Int, _ selected:@escaping(_:Int)->(), _ changed:((_:Int)->())? = nil) -> BMSinglePicker{
        var newIndex = index
        if index < 0 || index >= data.count{
            newIndex = 0
        }
        let picker = BMSinglePicker(data, newIndex, selected, changed)
        return picker
    }
    
    /// 简单的模型选择器
    /// - Parameters:
    ///  - dataArray   : 用于显示的模型数组
    ///  - index       : 初始选择的值
    ///  - key       : 显示哪个
    ///  - selected    : 点击确认后 回调 返回模型
    ///  - changed     : 数据改变 回调 返回模型
    /// - Returns: 返回选择器对象   调用show方法之前 可用于修改参数
    public static func singleModelPicker<T:HandyJSON>(_ data:Array<T>,_ index:Int,_ key:String, _ selected:@escaping(_:T)->(), _ changed:((_:T)->())? = nil) -> LHSinglePicker<T>{
        var newIndex = index
        if index < 0 || index >= data.count{
            newIndex = 0
        }
        let picker = LHSinglePicker(data,newIndex,key,selected,changed)
        return picker
    }

    /// 时间选择器
    ///
    /// - Parameters:
    ///   - currentTime: 当前时间 可为空
    ///   - startTime: 起始时间 可为空
    ///   - endTime: 截止时间 可为空
    ///   - finish: 确认点击后回调
    /// - Returns: 返回选择器对象   调用show方法之前 可用于修改参数
    public static func datePicker(currentTime:Date?=nil,startTime:Date?=nil,endTime:Date?=nil,selected:@escaping (_ time:Date?) -> () ) -> BMDatePicker{
        let picker = BMDatePicker(selected)
        picker.datePickMode = .ymd
        if currentTime != nil {
            picker.date = currentTime!
        }else{
            picker.date = Date(timeIntervalSinceNow: 0)
        }
        return picker
    }
    
    /// 带长期 按钮（营业执照中使用）
    public static func datePickerWithInfinit(currentTime:Date?=nil,startTime:Date?=nil,endTime:Date?=nil,selected:@escaping (_ time:Date?) -> () ) -> BMDatePicker{
        let picker = BMDatePicker(selected)
        picker.datePickMode = .ymd
        picker.showInfinit = true
        picker.infinitText = "永 久"
        if currentTime != nil {
            picker.date = currentTime!
        }else{
            picker.date = Date(timeIntervalSinceNow: 0)
        }
        return picker
    }

    /// 位置选择器
    ///
    /// - Parameter selected: 点击确认后 回调 [province, city, district]
    /// - Returns: 返回选择器对象
    public static func cityPicker(selected:@escaping(_:Array<Address>)->()) -> BMCityPicker{
        let picker = BMCityPicker(nil, nil, nil, selected, nil)
        return picker
    }

    /// 带初始位置的 选择器
    ///
    /// - Parameters:
    ///   - provinceId  : 省份ID
    ///   - cityId      : 省份城市ID
    ///   - districtId  : 地区ID
    ///   - selected    : 点击确认后 回调 [province, city, district]
    ///   - changed     : 数据发生修改时 回调 [province, city, district]
    /// - Returns: 返回选择器对象
    public static func cityPicker(_ provinceId:Int64?,_ cityId:Int64?,_ districtId:Int64?, selected:@escaping(_:Array<Address>)->(), _ changed:((_:Array<Address>)->())? = nil) -> BMCityPicker{
        let picker = BMCityPicker(provinceId, cityId, districtId, selected, changed)
        return picker
    }
    
    /// 只选择 省份  城市
    public static func cityPicker(_ provinceId:Int64?,_ cityId:Int64?, selected:@escaping(_:Array<Address>)->(), _ changed:((_:Array<Address>)->())? = nil) -> BMCityPicker{
        let picker = BMCityPicker(provinceId, cityId, selected, changed)
        return picker
    }

}













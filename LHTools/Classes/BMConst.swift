//
//  Const.swift
//  wangfuAgent
//
//  Created by lzw on 2018/7/11.
//  Copyright © 2018 zhuanbangTec. All rights reserved.
//


import UIKit

public let YES = true
public let NO = false

public let KPageSize:Int = 10
public let KReloadIntervalTime:Double = 600

public var oemInstitutionNo:String? = nil

public func judgeScream() -> Bool {
    if #available(iOS 11.0, *) {
        // 有时候会莫名其妙 keyWindow = nil
        if let a = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.safeAreaInsets.bottom{
            return a != 0 ? true:false
        }else{
            return true
        }
    } else {
        return false
    }
}

/// 屏幕的宽度
public let KScreenWidth    = UIScreen.main.bounds.width
/// 屏幕的高度
public let KScreenHeight   = UIScreen.main.bounds.height
/// 是否是IphoneX
public let KIsIphoneX      = judgeScream()
/// 导航栏下内容高度
public let KHeightInNav    = KScreenHeight - KNaviBarH
/// 导航栏顶部的高度
public let KNaviStatusBar       = CGFloat(KIsIphoneX ? 44.0:20.0)
/// 导航栏高度
public let KNaviBarH       = CGFloat(KIsIphoneX ? 88.0:64.0)
/// tabbar高度
public let KTabBarH        = CGFloat(KIsIphoneX ? 83.0:49.0)
/// 底部多余的高度
public let KBottomH        = CGFloat(KIsIphoneX ? 34:0)
/// 375下的尺寸  size*KRatio375
public let KRatio375       = UIScreen.main.bounds.width / 375.0

// 支持基础数据类型，自定义模型<:HandyJSON>,数组，字典
public extension BMDefaultsKeys{
    // userId 和 sessionId 已封装进 请求库
    static let userId = BMCacheKey<String?>("userId")
    static let sessionId = BMCacheKey<String?>("sessionId")
    ///版本更新
    static let saveVersionInfo = BMCacheKey<Dictionary<String, Any>?>("saveVersionInfo")
    ///最后更新时间
    static let saveLastUpdateTime = BMCacheKey<String?>("saveLastUpdateTime")
    
}

public let noti = NotificationCenter.default

public var window:UIWindow! {
    return UIApplication.shared.windows.first {$0.isKeyWindow}
}
public extension NSNotification.Name {
    static let needRelogin = NSNotification.Name("needRelogin")
}




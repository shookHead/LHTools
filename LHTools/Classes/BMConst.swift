//
//  Const.swift
//  wangfuAgent
//
//  Created by  on 2018/7/11.
//  Copyright © 2018 zhuanbangTec. All rights reserved.
//


import UIKit

public let YES = true
public let NO = false

public let KPageSize:Int = 10
public let KReloadIntervalTime:Double = 600

public var oemInstitutionNo:String? = nil

public func judgeScream() -> Bool {
    if #available(iOS 13.0, *) {
        let scene = UIApplication.shared.connectedScenes.first
        guard let windowScene = scene as? UIWindowScene else { return false }
        guard let window = windowScene.windows.first else { return false }
        return window.safeAreaInsets.top > 20 ? true:false
    } else if #available(iOS 11.0, *) {
        guard let window = UIApplication.shared.windows.first else { return false }
        return window.safeAreaInsets.top > 20 ? true:false
    }
    return false
}
public enum SafeDirect{
    case top
    case left
    case bottom
    case right
}
func safeArea(_ direct:SafeDirect) -> CGFloat{
    if #available(iOS 13.0, *) {
        if let inset = UIApplication.shared.connectedScenes.first{
            guard let windowScene = inset as? UIWindowScene else { return 0 }
            guard let window = windowScene.windows.first else { return 0 }
            if direct == .top{ return window.safeAreaInsets.top }
            if direct == .left{ return window.safeAreaInsets.left }
            if direct == .bottom{ return window.safeAreaInsets.bottom }
            if direct == .right{ return window.safeAreaInsets.right }
        }
        return 0
    }
    if #available(iOS 11.0, *) {
        if let inset = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.safeAreaInsets{
            if direct == .top{ return inset.top }
            if direct == .left{ return inset.left }
            if direct == .bottom{ return inset.bottom }
            if direct == .right{ return inset.right }
        }
        return 0
    }
    return 0
}
/// safeArea
public let safeArea_Top    = safeArea(.top)
/// safeArea
public let safeArea_Bottom = safeArea(.bottom)

/// 屏幕的宽度
public let KScreenWidth    = UIScreen.main.bounds.width
/// 屏幕的高度
public let KScreenHeight   = UIScreen.main.bounds.height
/// 是否是IphoneX
public let KIsIphoneX      = judgeScream()
/// 导航栏下内容高度
public let KHeightInNav    = KScreenHeight - KNaviBarH
/// 导航栏顶部状态栏高度
public let KNaviStatusBar  = safeArea_Top
/// 导航栏高度
public let KNaviBarH       = safeArea(.top) + 44
/// tabbar高度
public let KTabBarH        = safeArea(.bottom) + 49
/// 底部多余的高度 34
public let KBottomH        = safeArea(.bottom)
/// 375下的尺寸  size*KRatio375
public let KRatio375       = UIScreen.main.bounds.width / 375.0

///全局返回按钮颜色
public var globalBackColor:UIColor = #colorLiteral(red: 0.2588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1)

// 支持基础数据类型，自定义模型<:HandyJSON>,数组，字典
public extension BMDefaultsKeys{
    // userId 和 sessionId 已封装进 请求库
    static let userId = BMCacheKey<String?>("userId")
    static let sessionId = BMCacheKey<String?>("sessionId")
    ///版本更新
    static let saveVersionInfo = BMCacheKey<Dictionary<String, Any>?>("saveVersionInfo")
    ///最后更新时间
    static let saveLastUpdateTime = BMCacheKey<String?>("saveLastUpdateTime")
    
    ///是否需要刷新
    static let reload = BMCacheKey<Bool?>("reload")
}

public let noti = NotificationCenter.default

public extension NSNotification.Name {
    static let needRelogin = NSNotification.Name("needRelogin")
    static let outLogin = NSNotification.Name("outLogin")
}
///打印
public func lhPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG // 判断是否在测试环境下
    print(items, separator, terminator)
    #else
    #endif
}





//
//  LHSwiftFunctions.swift
//  aaaa
//
//  Created by 蔡林海 on 2020/6/24.
//  Copyright © 2020 蔡林海. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
public struct lh{
    /// app的名字
    public static var appDisplayName: String? {
        if let bundleDisplayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
            return bundleDisplayName
        } else if let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String {
            return bundleName
        }
        return nil
    }
    
    /// app的版本1.1.0
    public static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    ///UUID
    public static var deviceUUID: String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
    /// 获取设备的名字
    public static var deviceName: String? {
        return UIDevice.current.name
    }

    /// bundle ID
    public static var appBundleID: String? {
        return Bundle.main.bundleIdentifier
    }
    ///device version ""
    public static var deviceVersion: String {
        var size: Int = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: Int(size))
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String(cString: machine)
    }
    ///设备系统版本
    public static func deviceSysVersion() -> String {
        let s = UIDevice.current.systemVersion
        return s
    }
    ///设备系统版本（返回系统前面的数字）
    public static func deviceSysVersion() -> Int {
        let s = UIDevice.current.systemVersion
        var version = 0
        if s.count > 0{
            let arr = s.components(separatedBy: ".")
            if arr.count > 0 {
                version = arr[0].toInt()
            }
        }
        return version
    }
    public static func getWindow() -> UIWindow? {
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        return window
    }
    ///异步在几秒之后运行方法
    public static func dispatchDelay(_ second: Double, closure:@escaping () -> Void) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(second * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    ///主线程在几秒之后运行方法
    public static func runThisAfterDelay(seconds: Double, after: @escaping () -> Void) {
        runThisAfterDelay(seconds: seconds, queue: DispatchQueue.main, after: after)
        
    }
    public static func runThisAfterDelay(seconds: Double, queue: DispatchQueue, after: @escaping () -> Void) {
        let time = DispatchTime.now() + Double(Int64(seconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        queue.asyncAfter(deadline: time, execute: after)
    }
    ///在主线程运行
    public static func runThisInMainThread(_ block: @escaping () -> Void) {
        DispatchQueue.main.async(execute: block)
    }
    ///seconds :每隔几秒运行一次  startAfterSeconds:几秒之后运行 取消timer.invalidate()
    @discardableResult public static func runThisEvery(
        seconds: TimeInterval,
        startAfterSeconds: TimeInterval,
        handler: @escaping (CFRunLoopTimer?) -> Void) -> Timer {
        let fireDate = startAfterSeconds + CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, seconds, 0, 0, handler)
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, CFRunLoopMode.commonModes)
        return timer!
    }

    ///检查新版本
    public static func checkNewVersion() {
        let dic = cache[.saveVersionInfo] ?? Dictionary<String,Any>()
        let requestTime = dic["lastRequestTime"] as? String ?? ""
        let d = requestTime.toDate("yyyy-MM-dd")
        if d.isToday {
            self.showUpdateView(data: dic)
            self.requestVersionInfo(show: false)
            return
        }else{
            self.requestVersionInfo(show: true)
        }
    }
    public static func requestVersionInfo(show:Bool)  {
        var params = Dictionary<String,Any>()
        params["device"] = "iOS"
//        params["deviceSysVersion"] = lh.deviceSysVersion()
        let fullVersion = self.appVersion ?? ""
        params["fullVersion"] = fullVersion
        params["appType"] = 81
        if fullVersion.count > 0 {
            params["isUserCheck"] = self.appVersion?.subString(toFrom: fullVersion.count-1)
        }
//        Network.requestDic(YiChengShi.Complex_appUpgrade, params: params) { (resp) in
//            if resp.code == 1{
//                var dic = resp.data!
//                let d = Date().toString("yyyy-MM-dd")
//                dic["lastRequestTime"] = d
//                if show {
//                    self.checkNewVersion()
//                }
//                Cache[.versionInfo] = dic
//            }
//        }
    }
    ///弹出提示更新框 强制更新的就弹出  非强制的  每天只弹出一次
    public static func showUpdateView(data:Dictionary<String,Any>){
        let version2 = data["fullVersion"] as? String ?? ""
        if version2.compare(self.appVersion ?? "").rawValue <= 0 {
            return
        }
        let upgradeUrl = data["upgradeUrl"] as? String
        if upgradeUrl == nil{//没有更新链接直接返回
            return
        }
        let msg = data["upgradeContent"] as? String ?? ""
        let isMustUpgrade = data["isMustUpgrade"] as? NSNumber ?? 0//是否强制 0 非强制  1.强制升级
        if isMustUpgrade == 0 {//非强制 判断是否是今天第一次
            let time = cache[.saveLastUpdateTime] ?? ""
            let nowDate = Date().toString("yyyy-MM-dd")
            if time == nowDate {
                return
            }
            cache[.saveLastUpdateTime] = nowDate
        }
        let str = String(format: "发现新版本 %@", version2)
        let alert = UIAlertController.init(title: str, message: msg, preferredStyle: .alert)
        let action = UIAlertAction.init(title: "马上更新", style: .default) { (action) in
            let url = URL.init(string: upgradeUrl!)
            if UIApplication.shared.canOpenURL(url!){
                UIApplication.shared.open(url!, options: [:]) { (_) in
                }
            }
            if isMustUpgrade == 1{
                exit(1)
            }
        }
        alert.addAction(action)
        //如果非强制 就弹出取消
        if isMustUpgrade == 0 {
            let cancel = UIAlertAction.init(title: "稍后提醒", style: .cancel) { (action) in
                
            }
            alert.addAction(cancel)
        }
        lh.getWindow()?.rootViewController?.present(alert, animated: false, completion: nil)
    }
    /// 取最顶层的ViewController
    public static func topMost(of viewController: UIViewController? = lh.getWindow()?.rootViewController) -> UIViewController? {
        // presented view controller
        if let presentedViewController = viewController?.presentedViewController {
            return self.topMost(of: presentedViewController)
        }
        
        // UITabBarController
        if let tabBarController = viewController as? UITabBarController,
            let selectedViewController = tabBarController.selectedViewController {
            return self.topMost(of: selectedViewController)
        }
        
        // UINavigationController
        if let navigationController = viewController as? UINavigationController,
            let visibleViewController = navigationController.visibleViewController {
            return self.topMost(of: visibleViewController)
        }
        
        // UIPageController
        if let pageViewController = viewController as? UIPageViewController,
            pageViewController.viewControllers?.count == 1 {
            return self.topMost(of: pageViewController.viewControllers?.first)
        }
        
        // child view controller
        for subview in viewController?.view?.subviews ?? [] {
            if let childViewController = subview.next as? UIViewController {
                return self.topMost(of: childViewController)
            }
        }
        
        return viewController
    }
    ///跳往app设置
    public static func judgeAppSetting(){
        UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!, options: [:],
                                  completionHandler: {
                                    (success) in
        })
    }
    //MARK:- 权限判断
    ///判断相机权限
    public static func judgeCameraPower()  {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == AVAuthorizationStatus.restricted || status == AVAuthorizationStatus.denied {
            lh.topMost()?.showComfirm("访问相机", "您还没有打开相机权限", okStr: "去打开", cancle: "取消", cancel: {

            }, complish: {
                self.judgeAppSetting()
            })
        }else{

        }
    }
    ///判断相册权限
    public static func judgeAlbumPower(){
        let authStatus = PHPhotoLibrary.authorizationStatus()
        if authStatus != .restricted && authStatus != .denied {
            //            print("有权限")
        }else{
            //            print("没有权限")
            lh.topMost()?.showComfirm("访问相册", "您还没有打开相册权限", okStr: "去打开", cancle: "取消", cancel: {

            }, complish: {
                self.judgeAppSetting()
            })
        }
    }
    ///判断定位权限
    public static func judgeLocationPower(){
        if CLLocationManager.locationServicesEnabled() || CLLocationManager.authorizationStatus() != .denied {
            //权限打开
        }else{
            //权限没有打开
            lh.topMost()?.showComfirm("访问定位", "您还没有打开定位权限", okStr: "去打开", cancle: "取消", cancel: {

            }, complish: {
                lh.judgeAppSetting()
            })
        }
    }

    
    
}

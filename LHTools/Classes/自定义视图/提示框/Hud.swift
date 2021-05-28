//
//  Hud.swift
//  wangfuAgent
//
//  Created by yimi on 2019/3/22.
//  Copyright © 2019 zhuanbangTec. All rights reserved.
//

import UIKit

public class Hud: NSObject {

    //    static var shared = Hud()
    static var hud :MBProgressHUD!
    /// 自动隐藏时间
    public static var dismissTime = 1.5
    
    /// 显示文字
    public static func showText(_ text:String?,in view:UIView! = UIApplication.shared.windows.first {$0.isKeyWindow}){
        if text == nil{
            return
        }
        if view == nil{
            return
        }
        
        if Thread.isMainThread {
            self.showHudInView(view: view)
            hud.mode = MBProgressHUDMode.text
            hud.labelText = text
            hud.hide(YES, afterDelay: dismissTime)
        }else{
            DispatchQueue.main.async {
                self.showHudInView(view: view)
                hud.mode = MBProgressHUDMode.text
                hud.labelText = text
                hud.hide(YES, afterDelay: dismissTime)
            }
        }
    }
    public static func showDetailText(_ text:String?,_ detailText:String?,in view:UIView! = UIApplication.shared.windows.first {$0.isKeyWindow})  {
        if text == nil && detailText == nil{
            return
        }
        if view == nil{
            return
        }
        if Thread.isMainThread {
            self.showHudInView(view: view)
            hud.mode = MBProgressHUDMode.text
            hud.labelText = text
            hud.detailsLabelText = detailText
            var time:TimeInterval = 1.5
            if detailText!.count > 0 {
                ///每7个文字加一秒
                time = TimeInterval(detailText!.count/7 + 1)
            }
            hud.hide(YES, afterDelay: TimeInterval(time))
        }else{
            DispatchQueue.main.async {
                self.showHudInView(view: view)
                hud.mode = MBProgressHUDMode.text
                hud.labelText = text
                hud.hide(YES, afterDelay: dismissTime)
            }
        }
    }
    /// 显示等待
    public static func showWait(in view:UIView! = UIApplication.shared.windows.first {$0.isKeyWindow}){
        if view == nil{
            return
        }
        if Thread.isMainThread {
            self.showHudInView(view: view)
        }else{
            DispatchQueue.main.async {
                self.showHudInView(view: view)
            }
        }
    }

    /// 隐藏
    @objc public static func hide(_ animation:Bool = false){
        if hud != nil{
            if Thread.isMainThread {
                hud.hide(animation)
            }else{
                DispatchQueue.main.async {
                    hud.hide(animation)
                }
            }
        }
    }
    
    //hud 自动消失回调
    public static func runAfterHud(_  block: @escaping ()->() ){
        // 延迟调用
        let deadline = DispatchTime.now() + dismissTime
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            block()
        }
    }
    
    public static func showHudInView(view:UIView! = UIApplication.shared.windows.first {$0.isKeyWindow}) {
        if view == nil{
            return
        }
        if hud != nil{
            hide()
            hud.removeFromSuperview()
        }
        hud = MBProgressHUD(view: view)
        hud.removeFromSuperViewOnHide = true
        view!.addSubview(Hud.hud)
        hud.show(false)
        hud.isOpaque = false
        hud.opacity = 0.8
    }
}

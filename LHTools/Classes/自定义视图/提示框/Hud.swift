//
//  Hud.swift
//  wangfuAgent
//
//  Created by yimi on 2019/3/22.
//  Copyright © 2019 zhuanbangTec. All rights reserved.
//

import UIKit
import MBProgressHUD

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
            hud.label.text = text
            hud.hide(animated: true, afterDelay: dismissTime)
        }else{
            DispatchQueue.main.async {
                self.showHudInView(view: view)
                hud.mode = MBProgressHUDMode.text
                hud.label.text = text
                hud.hide(animated: true, afterDelay: dismissTime)
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
            hud.label.text = text
            hud.detailsLabel.text = detailText
            var time:TimeInterval = 1.5
            if detailText!.count > 0 {
                ///每7个文字加一秒
                time = TimeInterval(detailText!.count/7 + 1)
            }
            hud.hide(animated: true, afterDelay: TimeInterval(time))
        }else{
            DispatchQueue.main.async {
                self.showHudInView(view: view)
                hud.mode = MBProgressHUDMode.text
                hud.label.text = text
                hud.hide(animated: true, afterDelay: dismissTime)
            }
        }
    }
    /// 显示等待
    public static func showWait(in view:UIView! = UIApplication.shared.windows.first {$0.isKeyWindow},_ text:String = ""){
        if view == nil{
            return
        }
        if Thread.isMainThread {
            self.showHudInView(view: view)
            hud.label.text = text
        }else{
            DispatchQueue.main.async {
                self.showHudInView(view: view)
                hud.label.text = text
            }
        }
    }

    /// 隐藏
    @objc public static func hide(_ animation:Bool = false){
        if hud != nil{
            if Thread.isMainThread {
                hud.hide(animated: animation)
            }else{
                DispatchQueue.main.async {
                    hud.hide(animated: animation)
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
        hud.label.numberOfLines = 0
        hud.isOpaque = true//半透明
        hud.contentColor = UIColor.white
        hud.bezelView.color = UIColor(red: 60/255.0, green: 60/255.0, blue: 60/255.0, alpha: 1)
        hud.bezelView.style = .solidColor
        hud.removeFromSuperViewOnHide = true
        view.addSubview(Hud.hud)
        hud.show(animated: false)
    }
    public static func showProgress(text:String?) {
        let view = UIApplication.shared.windows.first {$0.isKeyWindow}
        self.showHudInView(view: view)
        hud.mode = .annularDeterminate
        hud.label.text = text
    }
    public static func setPrograss(progress:CGFloat){
        if hud == nil {
            return
        }
        DispatchQueue.main.async {
            if let view = UIApplication.shared.windows.first(where: {$0.isKeyWindow}){
                MBProgressHUD.forView(view)?.progress = Float(progress)
            }
        }
    }
}
// MARK:使用进度条
/**
 func userProgress() {
     Hud.showProgress(text: "下载中...")
     DispatchQueue.global().async {
         var progress:CGFloat = 0.0
         while progress < 1.0{
             progress += 0.01
             print(progress)
             Hud.setPrograss(progress: progress)
             usleep(5000)
         }
         Hud.hide(true)
     }
 }
 */


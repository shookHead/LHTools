//
//  BaseVC.swift
//  wangfuAgent
//
//  Created by YiMi on 2018/7/11.
//  Copyright © 2018 . All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import IQKeyboardManagerSwift

// 页面离开的方式
public enum BMVCDismissType {
    case pop    //返回上一级 页面注销
    case push   //跳转新页面
    case none   //空
}

open class BaseVC: UIViewController {
    
    // MARK:  ----------- UI样式 -----------
    /// 全局navi内容主题色（默认nil，与系统默认保持一致）
    public static var global_hideNavBottonLine:Bool! = nil
    /// 隐藏导航栏下面的黑线
    public var hideNavBottonLine:Bool! = global_hideNavBottonLine

    /// 隐藏导航栏
    public var hideNav = false
    /// 是否可以侧划返回
    public var popGestureEnable = BaseVC.global_popGestureEnable
    public static var global_popGestureEnable = true
    /// 状态栏颜色  需要指定的  重写该属性
    open override var preferredStatusBarStyle: UIStatusBarStyle{
        get{ return hideNav ? .lightContent : .default }}
    /// 是否自动适配键盘与输入框位置
    public var autoHideKeyboard:Bool = true
    /// 是否使用自动工具条
    public var autoToolbar:Bool = true
    
    /// 全局navi内容主题色（默认nil，与系统默认保持一致）
    public static var global_navTintColor:UIColor! = nil
    /// 全局navi背景色（默认nil，与系统默认保持一致）
    public static var global_navBarTintColor:UIColor! = nil
    /// 全局背景背景色默认白色
    public static var global_bgColor:UIColor! = .white
    
    /// 当前页面 navi 内容主题色
    public var barContenColor:UIColor! = BaseVC.global_navTintColor
    /// 当前页面 navi 背景色
    public var barBGColor:UIColor! = BaseVC.global_navBarTintColor
    
    
    // MARK:  ----------- 功能View -----------
    // 遮照背景视图
    public var maskView = UIView()
    // 弹出框使用的 灰色背景遮照
    public var blurMask: UIButton = {
        let btn = UIButton(frame: .init(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight))
        btn.backgroundColor = UIColor.maskView
        return btn
    }()

    public var window:UIWindow! {
        return UIApplication.shared.windows.filter{$0.isKeyWindow}.first
    }
    
    
    // MARK:  ----------- 变量存储 -----------
    /// viewwillappear 调用次数
    public var appearTimes:Int = 0
    /// BaseVC.currentVC 或的当前展示的页面，判断用
    public static var currentVC_Str:String?
    /// 当前的VC，全局可通过BaseVC.currentVC拿到，跳转用
    public static var currentVC:BaseVC?
    
    /// 页面离开的方式
    public var dismissType:BMVCDismissType = .none
    
    /// 页面传参回调
    public var backClosure: ((Dictionary<String, Any>) -> ())?
    public func setBackClosure(_ closure : @escaping (Dictionary<String, Any>) -> ()){ backClosure = closure}
    
    /// 记录上次请求的时间戳
    public var lastLoadTime:Date = Date(timeIntervalSince1970: 0)
    public var reloadIntervalTime:Double = 600
    /// 判断距离上次请求的时间 决定是否刷新
    public var needLoadWhenAppear:Bool{
        return Date().timeIntervalSince(lastLoadTime) > (reloadIntervalTime)}
    
    /// 上次动画时间，用于cell列表刷新等 有先后顺序的动画
    private var lastCellDisplayTimeInterval: TimeInterval = Date.timeIntervalSinceReferenceDate
    
    //MARK: ----------- vc生命周期 -----------
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = BaseVC.global_bgColor
        navigationController?.navigationBar.isTranslucent = false
        edgesForExtendedLayout = []
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 这里设置backgroundColor 会导致子类的xib中设置的背景色失效
//        self.view.backgroundColor = .white
        appearTimes = appearTimes + 1
        BaseVC.currentVC_Str = String(describing: self.classForCoder)
        BaseVC.currentVC = self
        
        navigationController?.setNavigationBarHidden(hideNav, animated: true)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = popGestureEnable
        if !hideNav {
            let att = [NSAttributedString.Key.foregroundColor : barContenColor!,
                       NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18)]
            if #available(iOS 15.0, *){
                let app = UINavigationBarAppearance()
                app.configureWithOpaqueBackground()  // 重置背景和阴影颜色
                app.titleTextAttributes = att
                app.backgroundColor = barBGColor == nil ? .white:barBGColor  // 设置导航栏背景色
                if let b = self.hideNavBottonLine, b == true{
                    app.backgroundEffect = nil
                    app.shadowColor = .clear
                    app.shadowImage = UIColor.clear.image  // 设置导航栏下边界分割线透明
                }
                navigationController?.navigationBar.scrollEdgeAppearance = app  // 带scroll滑动的页面
                navigationController?.navigationBar.standardAppearance = app // 常规页面
            }else{
                navigationController?.navigationBar.barTintColor = barBGColor
                if let _ = barContenColor {//设置中间文字大小和颜色
                    navigationController?.navigationBar.titleTextAttributes = att
                }
                if let b = self.hideNavBottonLine, b == true{
                    self.findHairlineImageViewUnder(sView: self.navigationController?.navigationBar)?.isHidden = true
                }
            }
        }
        
        IQKeyboardManager.shared.resignOnTouchOutside = self.autoHideKeyboard
        IQKeyboardManager.shared.enableAutoToolbar = self.autoToolbar
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.dismissType == .pop{
            backClosure = nil
        }
        if let b = self.hideNavBottonLine, b == true{
            self.findHairlineImageViewUnder(sView: self.navigationController?.navigationBar)?.isHidden = false
        }
    }
    
    
    //MARK: ----------- Action -----------
    
    /// 返回事件
    @objc open func back() {
        if let _ = self.navigationController {
            self.pop()
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }

    public func addTapCloseKeyBoard(_ view:UIView) {
        let tag = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(tag)
    }
    
    @objc public func closeKeyboard() {
        self.view.endEditing(true)
    }
    
    //MARK: ----------- Utils -----------
    
    /// 忽略自适应内边距
    public func ignoreAutoAdjustScrollViewInsets(_ sc:UIScrollView?) {
        if #available(iOS 11.0, *) {
            sc?.contentInsetAdjustmentBehavior = .never
        }else{
            self.automaticallyAdjustsScrollViewInsets = NO
        }
    }
    
    public func findHairlineImageViewUnder(sView: UIView?) -> UIImageView?{
        if sView == nil{
            return nil
        }
        if sView! is UIImageView && sView!.bounds.height <= 1 {
            return sView as? UIImageView
        }
        for sview in sView!.subviews {
            let imgs = self.findHairlineImageViewUnder(sView: sview)
            if imgs != nil && imgs!.bounds.height <= 1 {
                return imgs
            }
        }
        return nil
    }
    
    /// 自动判断运行延迟时间, 执行work
    /// interval:间隔时间
    public func linerAnimation(interval:TimeInterval=0.08, work: @escaping() -> Void) {
        let now = Date.timeIntervalSinceReferenceDate
        // 计算延迟时间，距离前一次执行动画
        var delay = interval
        delay = max(0, delay - (now - lastCellDisplayTimeInterval))
        if delay == 0 {
            work()
        } else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(Int(delay*1000))) {
                work()
            }
        }
        lastCellDisplayTimeInterval = now + delay
    }
}


// MARK:  提示框
extension BaseVC {
    public func showMask(){
        if maskView.superview == nil{
            self.window.addSubview(maskView)
            maskView.bm.addConstraints([.fill])
        }
    }
    
    /// 居中显示View
    public func showMaskWithViewInCenter(_ content:UIView){
        maskView.removeFromSuperview()
        self.window.addSubview(maskView)
        maskView.bm.addConstraints([.fill])

        blurMask.removeFromSuperview()
        maskView.addSubview(blurMask)
        blurMask.bm.addConstraints([.fill])

        blurMask.tag = 0
        blurMask.addTarget(self, action: #selector(hideMaskView), for: .touchUpInside)

        content.removeFromSuperview()
        maskView.addSubview(content)//把view的宽高布局转为约束
        content.bm.addConstraints([.w(content.w), .h(content.h), .center])
        
        //animation
        blurMask.alpha = 0;
        content.alpha = 0.5 //透明度渐变不带弹性
        UIView.animate(withDuration: 0.2, animations: {
            content.alpha = 1
            self.blurMask.alpha = 1
        })
        
        content.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5) //缩放带弹性
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
            content.transform = CGAffineTransform.identity
        }) { (_) in}
    }
    
    /// 居下显示View
    public func showMaskWithViewAtBottom(_ content:UIView){
        maskView.removeFromSuperview()
        self.window.addSubview(maskView)
        maskView.bm.addConstraints([.fill])

        blurMask.removeFromSuperview()
        maskView.addSubview(blurMask)
        blurMask.bm.addConstraints([.fill])
        
        blurMask.tag = 1;
        blurMask.addTarget(self, action: #selector(hideMaskView), for: .touchUpInside)

        content.removeFromSuperview()
        maskView.addSubview(content)//把view的宽高布局转为约束
        content.bm.addConstraints([.w(content.w), .h(content.h), .center_X(0), .bottom(40)])
        
        //animation
        blurMask.alpha = 0;
        content.alpha = 0.5 //透明度渐变不带弹性
        UIView.animate(withDuration: 0.2, animations: {
            content.alpha = 1
            self.blurMask.alpha = 1
        })
        
        content.transform = CGAffineTransform.init(translationX: 0, y: 50) //缩放带弹性
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
            content.transform = CGAffineTransform.identity
        }) { (_) in}
    }
    
    /// 隐藏
    @objc public func hideMaskView() -> Void {
        let views = maskView.subviews
        let content = views.last//提示框
        
        UIView.animate(withDuration: 0.3) {
            self.blurMask.alpha = 0
        } completion: { (_) in
            self.maskView.removeFromSuperview()
        }

        UIView.animate(withDuration: 0.15, animations: {
            content?.alpha = 0
            if self.maskView.tag == 1{
                content?.transform = CGAffineTransform.init(translationX: 0, y: 50)
            }else{
                content?.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
            }
        }) { (_) in
            content?.removeFromSuperview()
            content?.transform = CGAffineTransform.identity
        }
    }
}


// MARK:  页面导航
extension BaseVC {
    public class func fromStoryboard(_ identify: String? = nil) -> BaseVC {
        let id = identify ?? String(describing: type(of:self.init()))
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: id) as! BaseVC
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
    
    public func pushViewController(_ vc:UIViewController, _ animation:Bool = true) {
        if let n = self.navigationController{
            n.pushViewController(vc, animated: animation)
            self.dismissType = .push
        }
    }
    
    public func pushViewControllerWithHero(_ vc:BaseVC) {
        if let n = self.navigationController{
            n.hero.isEnabled = true
            n.pushViewController(vc, animated: true)
            vc.hero.isEnabled = true
            self.dismissType = .push
        }
    }
    
    public func pop(_ animation:Bool = true) -> Void{
        if let n = self.navigationController{
            n.popViewController(animated: animation)
            self.dismissType = .pop
        }
    }
    
    /// -1 = 前一个，
    public func pop(index:Int) -> Void{
        if let arr = self.navigationController?.children {
            let newIndex = arr.count - 1 + index
            let vc = arr[newIndex]
            self.navigationController?.popToViewController(vc, animated: YES)
            self.dismissType = .pop
        }
    }
}


// MARK:  自定义UI Create方法
extension UIViewController {
    public func barItem(_ target:(Any), title:String, imgName:String?, action:Selector , color:UIColor = #colorLiteral(red: 0.2588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1),isOriginal:Bool = false) -> UIBarButtonItem {
        let btn = self.barBtn(target, title: title, imgName: imgName, action: action, color: color,isOriginal: isOriginal)
        let item = UIBarButtonItem(customView: btn)
        return item
    }
    
    public func barBtn(_ target:(Any), title:String, imgName:String?, action:Selector , color:UIColor = #colorLiteral(red: 0.2588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1),isOriginal:Bool = false) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.tintColor = color
        btn.addTarget(target, action: action, for: .touchUpInside)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        var margin = 10
        if #available(iOS 10.0, *) {
            margin = 2
        }
        var w = 18 * title.count + margin
        w = w > 30 ? w : 30
        
        btn.frame = CGRect(x: 0, y: 0, width: w, height: 44)
        if imgName != nil {
            var img:UIImage?
            if isOriginal{
                img = UIImage(named:imgName!)
            }else{
                img = UIImage(named:imgName!)?.withRenderingMode(.alwaysTemplate)
            }
            btn.setImage(img, for: .normal)
        }
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(color, for: .normal)
        return btn
    }
}


//
//  BaseNavigationVC.swift
//  BaseUtilsDemo
//
//  Created by yimi on 2019/10/11.
//  Copyright © 2019 yimi. All rights reserved.
//

import UIKit

public var backImageStr = "BMback_Icon"
open class BaseNavigationVC: UINavigationController {

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.interactivePopGestureRecognizer?.delegate = self
//        //导航条上UIBarButtonItem的颜色
//        let tinColor = BaseVC.global_navTintColor ?? UIColor.black
//        let barBGColor = BaseVC.global_navBarTintColor ?? UIColor.white
//        navigationBar.tintColor = tinColor
//        if #available(iOS 14.0, *) {
//            //导航条的中间title的颜色字体大小
//            let appearance = UINavigationBarAppearance()
//            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: tinColor,NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18.0)]
//            appearance.configureWithOpaqueBackground()
//            //导航条的背景色
//            appearance.backgroundColor = barBGColor
//            UINavigationBar.appearance().standardAppearance = appearance
//            UINavigationBar.appearance().scrollEdgeAppearance = appearance
//            //状态栏的样式（.dark时，🔋电池栏为白色）
//            UINavigationBar.appearance().overrideUserInterfaceStyle = .dark
//            
//            
//        } else {
//            //导航条的中间title的颜色字体大小
//            navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:tinColor,NSAttributedString.Key.font:UIFont.systemFont(ofSize: 18.0)]
//            //导航条的背景色
//            navigationBar.barTintColor = barBGColor
//            //状态栏的样式（.black时，🔋电池栏为白色）
//            //UINavigationBar.appearance().barStyle = .black
//            navigationBar.barStyle = .black
//            
//        }
    }
    
    // 拦截 push 操作
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count > 0 {
            if let vc = viewController as? BaseVC {
                viewController.navigationItem.leftBarButtonItem = self.barItem(vc, title: "", imgName: backImageStr, action: #selector(vc.back),color: globalBackColor)
            }
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }
}

extension BaseNavigationVC:UIGestureRecognizerDelegate{
    //侧滑返回
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.viewControllers.count<2{
            return false
        }
        return true
    }
}


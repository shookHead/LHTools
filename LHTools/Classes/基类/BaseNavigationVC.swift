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


//
//  BaseTabbarVC.swift
//  BaseUtilsDemo
//
//  Created by yimi on 2019/10/11.
//  Copyright © 2019 yimi. All rights reserved.
//

import UIKit

open class BaseTabbarVC: UITabBarController,UITabBarControllerDelegate{

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self

        self.tabBar.isTranslucent = NO
        self.tabBar.tintColor = .KBlue
        self.tabBar.barTintColor = .white
    }

    
    /// 初始化子控制器
    public func setChildViewController(_ childController: UIViewController, title: String, imageName: String) {
        // 设置 tabbar 文字和图片
        childController.title = title
        childController.tabBarItem.image = UIImage(named: imageName + "-dark")
        childController.tabBarItem.selectedImage = UIImage(named: imageName)
        
        // 添加导航控制器为 TabBarController 的子控制器
        addChild(BaseNavigationVC(rootViewController: childController))
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let navi = self.children[tabBarController.selectedIndex] as? BaseNavigationVC{
            navi.popToRootViewController(animated: false)
        }
    }
    
}

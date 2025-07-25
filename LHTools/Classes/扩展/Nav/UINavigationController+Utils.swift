//
//  UINavigationController+Utils.swift
//  aaaaaa
//
//  Created by 蔡林海 on 2021/2/8.
//

import UIKit

extension UINavigationController{
    
    /// Pop 到指定类型的 ViewController（从栈顶向下查找）
    /// - Parameters:
    ///   - aClass: 要 pop 到的控制器类型
    ///   - animated: 是否使用动画
    /// - Returns: 是否成功 pop 到目标控制器
    @discardableResult
    public func popToViewController(as aClass: AnyClass, animated: Bool) -> Bool {
        for vc in viewControllers.reversed() {
            if vc.isKind(of: aClass) {
                popToViewController(vc, animated: animated)
                return true
            }
        }
        return false
    }
    // MARK:移除一部分vcs
    /// 移除想要移除的控制器
    /// - Parameters:
    ///   - arr: 需要移除的控制器
    public func removeVC(arr:[String]) {
        var childrens = children
        for i in (0..<(childrens.count-1)).reversed(){
            let vc = childrens[i]
            let name = String(describing: vc.classForCoder)
            for s in arr {
                if name == s  {
                    childrens.remove(at: i)
                }
            }
        }
        viewControllers = childrens
    }
    
    /// 移除导航栈中指定类名的控制器
    /// - Parameter classNames: 要移除的控制器类名数组（例如：["LoginViewController", "IntroVC"]）
    public func removeViewControllers(classNames: [String]) {
        viewControllers = viewControllers.filter { vc in
            !classNames.contains(vc.className)
        }
    }
}
extension UIViewController{
    /// dismiss 回根控制器（最早被 present 的控制器）
    public func dismissToRootViewController(animated: Bool = true) {
        var root = self
        while let presenter = root.presentingViewController {
            root = presenter
        }
        root.dismiss(animated: animated, completion: nil)
    }
    /// dismiss 回指定类型的控制器
    /// - Parameter aClass: 要 dismiss 回的控制器类型
    public func dismissToViewController(ofClass aClass: AnyClass, animated: Bool = true) {
        let targetName = String(describing: aClass)
        var current = self
        while let presenter = current.presentingViewController {
            if presenter.className == targetName {
                presenter.dismiss(animated: animated, completion: nil)
                return
            }
            current = presenter
        }
        // 如果未找到目标 VC，也 dismiss 到最上层
        current.dismiss(animated: animated, completion: nil)
    }
    public var classNameStr: String {
//        return NSStringFromClass(self.classForCoder).components(separatedBy: ".").last!
        return String(describing: type(of: self))
    }
    /// 获取控制器的类名（不带模块名）
    public var className: String {
        return String(describing: type(of: self))
    }
}

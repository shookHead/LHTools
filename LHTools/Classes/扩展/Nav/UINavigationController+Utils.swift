//
//  UINavigationController+Utils.swift
//  aaaaaa
//
//  Created by 蔡林海 on 2021/2/8.
//

import UIKit

extension UINavigationController{
    // MARK:pop 到某个vc，以传入的vc类型为准，从栈顶逐个便利，直到找到这个vc，如果遍历完成后没找到，则返回false
    /// pop 到某个vc，以传入的vc类型为准，从栈顶逐个便利，直到找到这个vc，如果遍历完成后没找到，则返回false
    /// - Parameters:
    ///   - aClass: 要pop到的vc的类型
    ///   - animated: 是否有动画
    /// - Returns: 成功找到vc并pop 返回true  否则 false
    @discardableResult
    public func popToViewController(as aClass: AnyClass, animated: Bool) -> Bool {
        for vc in viewControllers.reversed() {
            if vc.isMember(of: aClass) {
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
                if name.contains(s)  {
                    childrens.remove(at: i)
                }
            }
        }
        viewControllers = childrens
    }
}
extension UIViewController{
    public func dismissToRootViewController() {
        var vc = self
        while vc.presentingViewController != nil {
            vc = vc.presentingViewController!
        }
        vc.dismiss(animated: true, completion: nil)
    }
    public func dismissViewControllerClass(as aClass: AnyClass) {
        let disvc = String(describing: aClass)
        var vc = self
        while let oldvc = vc.presentingViewController{
            let name = String(describing: oldvc.classForCoder)
            vc = oldvc
            if name == disvc {
                break
            }
        }
        vc.dismiss(animated: true, completion: nil)
    }
}

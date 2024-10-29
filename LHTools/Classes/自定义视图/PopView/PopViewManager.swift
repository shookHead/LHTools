//
//  PopViewManager.swift
//  ciao
//
//  Created by 蔡林海 on 2020/9/7.
//  Copyright © 2020 蔡林海. All rights reserved.
//

import UIKit

public enum PopViewType:Int {
    ///渐变
    case fade      = 0
    ///缩放
    case zoom      = 1
    ///下往上
    case up        = 2
    ///上往下
    case down      = 3
    ///右往左
    case left      = 4
    ///左往右
    case right     = 5
    ///弹性动画
    case spring    = 6
    ///从左上角到中间，再到右下角
    case custom    = 7
}
public class PopViewManager: NSObject {
    public var backgroundStyle = JXPopupViewBackgroundStyle.solidColor
    public var backgroundColor = UIColor.black.withAlphaComponent(0.3)
    public var backgroundEffectStyle = UIBlurEffect.Style.light
    public static var isDismissible = true
    public static var isInteractive = true
    public static var isPenetrable = false
    /// 弹出框
    /// - Parameters:
    ///   - contentView: 弹出框的内容
    ///   - containerView: 弹出框的背景
    ///   - animatorType: 弹出框的类型
    ///   - layout: 弹出框的位置
    @discardableResult
    public static func show(contentView:UIView,containerView:UIView = UIApplication.shared.windows.first {$0.isKeyWindow}!,animatorType:PopViewType = .fade) -> JXPopupView {
        display(contentView: contentView, containerView: containerView, animatorType: animatorType)
    }
    /// 弹出框
    /// - Parameters:
    ///   - contentView: 弹出框的内容
    ///   - containerView: 弹出框的背景
    ///   - animatorType: 弹出框的类型
    ///   - style: 是否是毛玻璃效果
    @discardableResult
    public static func display(contentView:UIView,containerView:UIView = UIApplication.shared.windows.first {$0.isKeyWindow}!,animatorType:PopViewType = .fade,style:JXPopupViewBackgroundStyle = .solidColor) -> JXPopupView{
        var animator: JXPopupViewAnimationProtocol?
        switch animatorType {
        case .fade:
            animator = JXPopupViewFadeInOutAnimator()
        case .zoom:
            animator = JXPopupViewZoomInOutAnimator()
        case .up:
            animator = JXPopupViewUpwardAnimator()
        case .down:
            animator = JXPopupViewDownwardAnimator()
        case .left:
            animator = JXPopupViewLeftwardAnimator()
        case .right:
            animator = JXPopupViewRightwardAnimator()
        case .spring:
            animator = JXPopupViewSpringDownwardAnimator()
        case .custom:
            animator = JXPopupViewCustomAnimator()
        }
        let popupView = JXPopupView(containerView: containerView, contentView: contentView, animator: animator!)
        //配置交互
        popupView.isDismissible = isDismissible
        popupView.isInteractive = isInteractive
        //可以设置为false，再点击弹框中的button试试？
        //        popupView.isInteractive = false
        popupView.isPenetrable = isPenetrable
        if style == .blur {
            popupView.backgroundView.style = style
            popupView.backgroundView.blurEffectStyle = UIBlurEffect.Style.light
        }
        popupView.display(animated: true, completion: nil)
        return popupView
    }
}

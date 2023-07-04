//
//  ViewController.swift
//  LHTools
//
//  Created by shookHead on 05/26/2021.
//  Copyright (c) 2021 shookHead. All rights reserved.
//

import UIKit
@_exported import LHTools
import LHTools
import Alamofire
import Foundation
import ZLPhotoBrowser
import SwiftUI
import WebKit

class GroupActivityModel: HandyJSON {
    var name:String! = ""{
        didSet{
            pick_name = name
        }
    }
    ///
    var userActivityId  : Int! = 0
    ///活动id
    var activityId  : Int!
    var pick_name:String! = ""
    
    required init() {}
}

class ViewController: UIViewController {
    var camer = CamerView()
    var stackView:UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let uuid = Utils.keychainDeviceUUID
        print("uuid:\(uuid ?? "")")
        let m1 = WorkModel()
        m1.userId = "1"
        m1.drawWorkId = 2
        let m2 = WorkModel()
        m2.userId = "1"
        m2.drawWorkId = 2
        if m1 == m2{
            print("相同")
        }else{
            print("不相同")
        }
        stackView = UIStackView(frame: CGRect.init(x: 15, y: 40, width: 350, height: 30))
        stackView.axis = .horizontal///水平方向
        stackView.spacing = 10.0///每个view间距
        stackView.distribution = .fillEqually///等宽
        stackView.backgroundColor = .red
        view.addSubview(stackView)
        let label1 = UILabel()
        label1.backgroundColor = .random
        label1.text = "label1"
        let label2 = UILabel()
        label2.backgroundColor = .random
        label2.text = "label2"
        let label3 = UILabel()
        label3.backgroundColor = .random
        label3.text = "label3"
        
        stackView.addArrangedSubview(label1)
        stackView.addArrangedSubview(label2)
        stackView.addArrangedSubview(label3)
        let AppScreenWidth = UIScreen.main.bounds.width
        let AppScreenHeight = UIScreen.main.bounds.height
        print("\(AppScreenWidth),--\(AppScreenHeight)")
    }
    func safeArea(_ direct:SafeDirect) -> CGFloat{
        if #available(iOS 13.0, *) {
            if let inset = UIApplication.shared.connectedScenes.first{
                guard let windowScene = inset as? UIWindowScene else { return 0 }
                guard let window = windowScene.windows.first else { return 0 }
                if direct == .top{ return window.safeAreaInsets.top }
                if direct == .left{ return window.safeAreaInsets.left }
                if direct == .bottom{ return window.safeAreaInsets.bottom }
                if direct == .right{ return window.safeAreaInsets.right }
            }
            return 0
        }
        if #available(iOS 11.0, *) {
            if let inset = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.safeAreaInsets{
                if direct == .top{ return inset.top }
                if direct == .left{ return inset.left }
                if direct == .bottom{ return inset.bottom }
                if direct == .right{ return inset.right }
            }
            return 0
        }
        return 0
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.25) {
            let label3 = UILabel()
            label3.backgroundColor = .random
            label3.text = "label3"
            self.stackView.addArrangedSubview(label3)
        }
    }
    @objc func buttonAction(_ sender:DOFavoriteButton) {
        if sender.isSelected {
            // deselect
            sender.deselect()
        } else {
            // select with animation
            sender.select()
        }
    }
    func useSnp() {
        var arr: Array<UIView> = []
        for i in 0..<5 {
            let subview = UIView()
            subview.backgroundColor = UIColor.random
            view.addSubview(subview)
            subview.tag = i
            arr.append(subview)
        }
//        sc.contentSize = CGSize(width: CGFloat(arr.count * 50), height: sc.h)
//        //MARK: - 数组布局
//        arr.snp.makeConstraints{
//            $0.width.height.equalTo(100)
//        }
//
//        for (i, v) in arr.enumerated() {
//            v.snp.makeConstraints{
//                $0.left.equalTo(80 * i)
//                $0.top.equalTo(100 * i)
//            }
//        }
//        //MARK: - 等间距布局
//        arr.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 4, leadSpacing: 20, tailSpacing: 30)
//        arr.snp.makeConstraints{
//            $0.top.equalTo(100)
//            $0.height.equalTo(CGFloat(arc4random_uniform(100) + 50))
//        }
//
//        //MARK: - 等大小布局
//        arr.snp.distributeViewsAlong(axisType: .horizontal,fixedItemLength: 100,leadSpacing: 10,tailSpacing: 0)
//        arr.snp.makeConstraints { make in
//            make.top.equalTo(100)
//            make.height.equalTo(CGFloat(arc4random_uniform(100) + 50))
//        }
        
        //MARK: - 九宫格 固定间距
        arr.snp.distributeSudokuViews(fixedLineSpacing: 10, fixedInteritemSpacing: 10, warpCount: 3)
//
//        //MARK: - 九宫格 固定间距
//        arr.snp.distributeSudokuViews(fixedLineSpacing: 10, fixedInteritemSpacing: 20, warpCount: 3)
    }
}

// 易城市接口基类
class YiChengShi<ValueType> : BMApiTemplete<ValueType> {
    override var host: String{
//        return HostConfig.getHost("http://192.168.1.134:8084/", index: 0)
        return HostConfig.getHost("https://api.yichengshi.cn/", index: 0)
    }
    
    override var defaultParam: Dictionary<String, Any>{
        return [:]
    }
    
}
extension BMApiSet {
    static let login = YiChengShi<String?>("edcmanageapi/Login_login")
    
}


extension UIDevice {
    
    /// 顶部安全区高度
    static func vg_safeDistanceTop() -> CGFloat {
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes.first
            guard let windowScene = scene as? UIWindowScene else { return 0 }
            guard let window = windowScene.windows.first else { return 0 }
            return window.safeAreaInsets.top
        } else if #available(iOS 11.0, *) {
            guard let window = UIApplication.shared.windows.first else { return 0 }
            return window.safeAreaInsets.top
        }
        return 0
    }
    
    /// 底部安全区高度
    static func vg_safeDistanceBottom() -> CGFloat {
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes.first
            guard let windowScene = scene as? UIWindowScene else { return 0 }
            guard let window = windowScene.windows.first else { return 0 }
            return window.safeAreaInsets.bottom
        } else if #available(iOS 11.0, *) {
            guard let window = UIApplication.shared.windows.first else { return 0 }
            return window.safeAreaInsets.bottom
        }
        return 0
    }
    
    /// 顶部状态栏高度（包括安全区）
    static func vg_statusBarHeight() -> CGFloat {
        var statusBarHeight: CGFloat = 0
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes.first
            guard let windowScene = scene as? UIWindowScene else { return 0 }
            guard let statusBarManager = windowScene.statusBarManager else { return 0 }
            statusBarHeight = statusBarManager.statusBarFrame.height
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
        }
        return statusBarHeight
    }
    
    /// 导航栏高度
    static func vg_navigationBarHeight() -> CGFloat {
        return 44.0
    }
    
    /// 状态栏+导航栏的高度
    static func vg_navigationFullHeight() -> CGFloat {
        return UIDevice.vg_statusBarHeight() + UIDevice.vg_navigationBarHeight()
    }
    
    /// 底部导航栏高度
    static func vg_tabBarHeight() -> CGFloat {
        return 49.0
    }
    
    /// 底部导航栏高度（包括安全区）
    static func vg_tabBarFullHeight() -> CGFloat {
        return UIDevice.vg_tabBarHeight() + UIDevice.vg_safeDistanceBottom()
    }
}


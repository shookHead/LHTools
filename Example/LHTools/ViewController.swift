//
//  ViewController.swift
//  LHTools
//
//  Created by shookHead on 05/26/2021.
//  Copyright (c) 2021 shookHead. All rights reserved.
//

import UIKit
//@_exported import LHTools
import LHTools
import Alamofire
class ViewController: UIViewController {
    var camer = CamerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        camer.frame = CGRect(x: 0, y: 100, width: KScreenWidth, height: 120)
        camer.canMove = true
        camer.maxCount = 20
        camer.setViewHeightClosure { (h) in
            print("高度\(h)")
//            camer.h = h
        }
        view.addSubview(camer)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        Hud.showWait()
        print(camer.selectedPhotosStr)
    }
}

// 易城市接口基类
class YiChengShi<ValueType> : BMApiTemplete<ValueType> {
    override var host: String{
//        return HostConfig.getHost("http://192.168.1.134:8084/", index: 0)
        return HostConfig.getHost("https://api.yichengshi.cn/", index: 0)
    }
}
extension BMApiSet {
    static let login = YiChengShi<String?>("edcmanageapi/Login_login")
    
}

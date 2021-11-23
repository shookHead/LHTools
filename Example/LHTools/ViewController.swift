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
import Foundation
import ZLPhotoBrowser

class GroupActivityModel: HandyJSON {
    ///
    var userActivityId  : Int! = 0
    ///活动id
    var activityId  : Int!

    required init() {}
    func didFinishMapping() {

    }
}

class ViewController: UIViewController {
    var camer = CamerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let mod = GroupActivityModel()
        mod.userActivityId = 1
        mod.activityId = 33
        var arr:[GroupActivityModel] = []
        arr.append(mod)
        let dic = arr.toJSON()[0]!
        
        print(dic["activityId"])
        
    }
    @objc func btnAction() {

    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        LHSinglePicker.in
        let daa = Array<String>()
//        let picker = BMSinglePicker(data, 0)
        
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



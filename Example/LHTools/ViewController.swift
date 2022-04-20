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
import SwiftUI

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let s = ""
        view.backgroundColor = .red
        s.callPhone()
    }
    @objc func btnAction() {
        let imageView = UIImageView()
        imageView.setImage("")
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        BMPicker.lh_datePicker(currentTime: nil, startTime: nil, endTime: nil) { time in
            print(time?.toString("yyyy-MM-dd HH:mm"))
        }.show()
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



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
        defer {
            print(mod.activityId ?? "11")
        }
//        mod.activityId = 1
    }
    @objc func btnAction() {

    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let ps = ZLPhotoPreviewSheet()
        ps.selectImageBlock = { (images,assets,isoriginal) in
            
        }
        ps.showPreview(sender: self)
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


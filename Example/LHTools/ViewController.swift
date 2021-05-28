//
//  ViewController.swift
//  LHTools
//
//  Created by shookHead on 05/26/2021.
//  Copyright (c) 2021 shookHead. All rights reserved.
//

import UIKit
@_exported import LHTools
class ViewController: UIViewController {
    @IBOutlet weak var tf: LHLimitWordTF!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertShow.maxP = 1
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {


    }
}

// 易城市接口基类
public class YiChengShi<ValueType> : BMApiTemplete<ValueType> {
    public override var host: String{
//        return HostConfig.getHost("http://192.168.1.134:8084/", index: 0)
        return HostConfig.getHost("https://api.yichengshi.cn/", index: 0)
    }
}
extension BMApiSet {
    static let login = YiChengShi<String?>("edcmanageapi/Login_login")
    
}

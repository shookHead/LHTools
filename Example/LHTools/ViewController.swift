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
//        let path = Bundle.main.path(forResource: "city_db", ofType: "LHTools/sqlite")
//        print(path)
//        let path = Bundle(for: LHTools.self).resourcePath?.appending("/city_db.sqlite")
//        print(path)
//        let cityArr = CityDBManager.share.getAddressModel(1, 1, model?.districtId ?? 0)
        let city = CityDBManager.share.getAddressModel(1, 1, 1)
        print(city)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {


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

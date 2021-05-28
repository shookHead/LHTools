//
//  ViewController.swift
//  LHTools
//
//  Created by shookHead on 05/26/2021.
//  Copyright (c) 2021 shookHead. All rights reserved.
//

import UIKit
import LHTools
class ViewController: UIViewController {
    @IBOutlet weak var tf: LHLimitWordTF!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        var str = "442"
        tf.maxNum = 5
        let lab = UILabel()
        lab.backgroundColor = .KRed
        Hud.showText("dd")

    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let v = UIView()
        v.frame = CGRect(x: 100, y: 100, width: 200, height: 200)
        v.backgroundColor = .white
        PopViewManager.show(contentView: v)

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

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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let button = DOFavoriteButton.init(frame: CGRect(x: 0, y: 100, width: 44, height: 44),image: UIImage(named: "sh-collection-gray"))
        button.setImage(UIImage.init(named: "sh-collection-red"), for: .selected)
        button.addTarget(self, action: #selector(buttonAction(_ :)), for: .touchUpInside)
//        button.imageColorOff = UIColor.hex("#B1B5C3")
//        button.imageColorOn = #colorLiteral(red: 0.8901960784, green: 0.2352941176, blue: 0.3921568627, alpha: 1)
//        button.circleColor = UIColor.green
//        button.lineColor = UIColor.blue
        self.view.addSubview(button)
    }
    
    func downLoadImage(str:String){
//        if let url = NSURL(string: str) {
//            if let data = NSData(contentsOfURL: url){
//                let img = UIImage(data: data)
//                let home = NSHomeDirectory() as NSString
////打印沙盒路径,可以前往文件夹看到你下载好的图片
//                print(home)
//                let docPath = home.stringByAppendingPathComponent("Documents") as NSString
//                let filePath = docPath.stringByAppendingPathComponent("666.png")
////不得补多少一句在这里卡主了,搜了很多地方都不知道这里怎么写,后来查文档看着需要抛出(try)
//                do {
//                     try UIImagePNGRepresentation(img!)?.writeToFile(filePath, options: NSDataWritingOptions.DataWritingAtomic)
//                }catch _{
//
//                }
//          }
//
//       }
        if let url = URL.init(string: str) {
//            = try? Data.init(contentsOf: url)
            if let data = try?  Data.init(contentsOf: url) {
//                let img = UIImage.init(data: data)
                let filePath = NSHomeDirectory() + "/Documents/" + "tupian.png"
                print(filePath)
                try? data.write(to: URL.init(fileURLWithPath: filePath), options: .atomic)
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
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



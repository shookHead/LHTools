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

struct GroupActivityModel: SmartCodable {
    var name:String! = ""
    ///
    var userActivityId  : Int! = 0
    ///活动id
    var activityId  : Int!
    var pick_name:String! = ""
    
}

public class ZBJsonM<T: SmartCodable>: SmartCodable {
    public var code: Int?
    public var msg: String?
    public var data: T?
    
    required public init() { }
    
//    // 如果需要自定义解码逻辑可以重写映射方法
//    public func mapping(mapper: SmartMapper) {
//        // 示例：自定义字段映射（如果字段名不一致）
//        // mapper <<< self.data <-- "result"
//    }
}

class ViewController: BaseStackVC {
    var camer = CamerView()
    var camerV:CamerView! = {
        let v = CamerView()
        //        v.maxCount = 8
        v.backgroundColor = .clear
        v.canMove = true
        v.canShowBigImage = true
        v.frame = CGRect(x: 0, y: 100, width: KScreenWidth, height: 300)
        v.edg = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return v
    }()
    override var stackContentInsets: UIEdgeInsets {
        .init(top: 24, left: 0, bottom: 40, right: 0)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let btn = UIButton()
        btn.backgroundColor = .red
//        btn.snp.makeConstraints { make in
//            make.height.equalTo(100)
//        }
        btn.frame.size.height = 100
        stackView.addArrangedSubview(btn)
        let lab = UILabel()
        lab.text = "等哈科技护肤科技大厦"
        lab.backgroundColor = .yellow
        lab.h = 200
        lab.snp.makeConstraints { make in
            make.height.equalTo(200)
        }
        stackView.addArrangedSubview(lab)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       let p = CityDBManager.share.getAddressModel(1, 1, 1)
        print(p)
        
      
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

extension Array where Element: Hashable {
    var unique: Self {
        var seen: Set<Element> = []
        return filter { seen.insert($0).inserted }
    }
}

extension BMApiSet {
    static let AgenterOemInstitution_getSzrOemInstitution = Huitun<OemInstitutionAuthModel?>("api/AgenterOemInstitution_getSzrOemInstitution")
    
}

public class Huitun<ValueType> : BMApiTemplete<ValueType> {
    public override var host: String{
        return HostConfig.getHost("https://www.huitunai.com/", index: 0)
    }
    public override var defaultParam: Dictionary<String, Any>{
        var params = Dictionary<String,Any>()
       
//        params = ["platform":"2","appid":"10","inapp":"false","liveid":"1"]
//        params["yodaReady"] = "h5"
//        params["csecplatform"] = 4
//        params["csecversion"] = "2.3.1"

        return params
    }
}
class OemInstitutionAuthModel :SmartCodable{
    
    var szrAppName:String!
    ///机构号
    var oemInstitutionNo  : Int! = 0
    ///是否可用 视频剪辑
    var openAliVideoEdit  : Int! = 0
    ///是否可用 声音人直播
    var openSoundLive  : Int! = 0
    ///数字人直播
    var openAvatarLive  : Int! = 0
    ///数字人直播(v2) 场景化
    var openAvatarV2Live  : Int! = 0
    ///AI语音互动
    var openSoundInteract  : Int! = 0
    ///声音克隆
    var openSoundClone  : Int! = 0
    ///开启自托管生成数字人
    var openAiGenAvatarSelf  : Int! = 0
    ///数字人名片
    var openAvatarCard  : Int! = 0
    ///数字人克隆自审核
    var openAvatarVerifySelf  : Int! = 0
    ///是否开通矩阵（总）
    var openJzBdm  : Int! = 0
    ///是否开通矩阵（快手）
    var openKsJzBdm  : Int! = 0
    ///是否开通矩阵 （抖音）
    var openDyJzBdm  : Int! = 0
    ///AI聊天数字人
    var openAiChatAvatar  : Int! = 0
    ///系统公告
    var openSystemNotice  : Int! = 0
    ///文生视频
    var openAiTextVideo  : Int! = 0
    var szrAppShopServiceProtocolUrl :String! = ""
    var szrAppShopPrivacyProtocolUrl:String! = ""
    var masterWebUrl:String! = ""
    
    
    required init() {}
}

extension BMDefaultsKeys{
    //MARK:- 包含save的字段退出后不会被清除
    static let saveGroupActivityModelArr = BMCacheKey<Array<GroupActivityModel>?>("saveGroupActivityModelArr")
    static let saveGroupActivityModel = BMCacheKey<GroupActivityModel?>("saveGroupActivityModel")
}

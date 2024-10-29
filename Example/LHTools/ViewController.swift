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
    override func viewDidLoad() {
        super.viewDidLoad()
//        let array: [Int] = [1, 1, 3, 3, 2, 2]
//        let arr = array.unique
//        print(arr)
//        view.addSubview(camerV)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        UIView.animate(withDuration: 0.25) {
//            let label3 = UILabel()
//            label3.backgroundColor = .random
//            label3.text = "label3"
//            self.stackView.addArrangedSubview(label3)
//        }
//        Hud.showText("大叔控房后开始发挥开始发低烧后开始发挥开始发低烧房贷首付")
        print("111")
        BMPicker.datePicker(mode: .ymd_hms) { time in
            
        }.show()
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

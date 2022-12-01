//
//  LH_Use.swift
//  LHTools_Example
//
//  Created by clh on 2022/1/7.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

//CoreAnimation---CATransform3DExtensions

//MARK: - 控制器的过渡动画
/*
 @objc func push() {
     guard let navigationController = navigationController else {
         return
     }
     if isPush {
         let controller = CLTransitionViewController()
         controller.isPush = false
         controller.view.backgroundColor = UIColor.yellow
         let transition = CATransition()
         transition.duration = 0.5
         transition.type = .push
         transition.subtype = .fromBottom
         transition.timingFunction = CAMediaTimingFunction.init(name: .easeIn)
         navigationController.view.layer.add(transition, forKey: kCATransition)
         navigationController.pushViewController(controller, animated: false)
     }else {
         let transition = CATransition()
         transition.duration = 0.5
         transition.type = .reveal
         transition.subtype = .fromTop
         transition.timingFunction = CAMediaTimingFunction.init(name: .easeIn)
         navigationController.view.layer.add(transition, forKey: kCATransition)
         navigationController.popViewController(animated: false)
     }
 }
*/   

/**
    let colors1:[UIColor] = []
    let arr = colors1.map(\.cgColor)
 */


/**
    let locations: [CGFloat] = []
    let arr = locations.map { NSNumber(value: Double($0)) }
 */




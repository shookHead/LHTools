//
//  UIStackView+Extension.swift
//  LHTools_Example
//
//  Created by 海 on 2024/2/27.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit


extension UIStackView{
    func addBackground(color: UIColor) {
        if #available(iOS 14.0, *) {
            backgroundColor = color
        } else {
            let subView = UIView(frame: bounds)
            subView.backgroundColor = color
            subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            insertSubview(subView, at: 0)
        }
    }
}

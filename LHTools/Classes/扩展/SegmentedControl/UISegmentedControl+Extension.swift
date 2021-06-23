//
//  UISegmentedControl+Extension.swift
//  fjksfjlksdfew
//
//  Created by 蔡林海 on 2021/1/7.
//

import UIKit

extension UISegmentedControl{
    func segmentedIOS13Style() {
        if #available(iOS 13.0, *) {
            let tintColorImage = tintColor.image
            let backImg = backgroundColor != nil ? backgroundColor!.image:UIColor.clear.image
            setBackgroundImage(backImg, for: .normal, barMetrics: .default)
            setBackgroundImage(tintColor.withAlphaComponent(0.2).image, for: .highlighted, barMetrics: .default)
            setBackgroundImage(tintColorImage, for: .selected, barMetrics: .default)
            setBackgroundImage(tintColorImage, for: .disabled, barMetrics: .default)
            setTitleTextAttributes([NSAttributedString.Key.foregroundColor : tintColor ?? .white,NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 16)], for: .normal)
            setDividerImage(tintColorImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
            layer.borderWidth = 1
            layer.borderColor = tintColor.cgColor
            selectedSegmentTintColor = tintColor
        }
    }
}

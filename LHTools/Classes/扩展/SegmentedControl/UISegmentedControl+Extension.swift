//
//  UISegmentedControl+Extension.swift
//  fjksfjlksdfew
//
//  Created by 蔡林海 on 2021/1/7.
//

import UIKit

extension UISegmentedControl{
    public func segmentedIOS13Style() {
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

class LHSegmentedControl: UISegmentedControl {
    public var canChangeTintColor = false
    func stylize() {
        if #available(iOS 13.0, *) {
            selectedSegmentTintColor = tintColor
            let tintColorImage = UIImage(color: tintColor)
            setBackgroundImage(UIImage(color: backgroundColor ?? .clear), for: .normal, barMetrics: .default)
            setBackgroundImage(tintColorImage, for: .selected, barMetrics: .default)
            setBackgroundImage(UIImage(color: tintColor.withAlphaComponent(1)), for: .highlighted, barMetrics: .default)
            setBackgroundImage(tintColorImage, for: [.highlighted, .selected], barMetrics: .default)
            setTitleTextAttributes([.foregroundColor: tintColor!, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .regular)], for: .normal)
            
            setDividerImage(tintColorImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
            layer.borderWidth = 1
            layer.borderColor = tintColor.cgColor
            
            // Detect underlying backgroundColor so the text color will be properly matched
            
            if let background = backgroundColor {
                self.setTitleTextAttributes([.foregroundColor: background, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .regular)], for: .selected)
            } else {
                func detectBackgroundColor(of view: UIView?) -> UIColor? {
                    guard let view = view else {
                        return nil
                    }
                    if let color = view.backgroundColor, color != .clear {
                        return color
                    }
                    return detectBackgroundColor(of: view.superview)
                }
                let textColor = detectBackgroundColor(of: self) ?? .black
                
                self.setTitleTextAttributes([.foregroundColor: textColor, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .regular)], for: .selected)
            }
        }
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        if !canChangeTintColor {
            stylize()
        }
    }
}

fileprivate extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

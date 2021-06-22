////
////  Bundle+Extensions.swift
////  CLTools_Example
////
////  Created by CainLuo on 2020/12/14.
////  Copyright © 2020 CocoaPods. All rights reserved.
////
//
import UIKit
import Foundation
//
//enum MyStoryboard: String {
//    case About
//        
//    func instantiate<VC: UIViewController>(_ viewController: VC.Type) -> VC {
//        guard let vc = UIStoryboard(name: self.rawValue, bundle: Bundle(for: VC.self))
//            .instantiateViewController(withIdentifier: VC.storyboardIdentifier) as? VC else {
//            fatalError("Couldn't instantiate \(VC.storyboardIdentifier) from \(self.rawValue)")
//        }
//        
//        return vc
//    }
//}
//
//extension UIViewController {
//    static var defultNib: String {
//        return self.description().components(separatedBy: ".").dropFirst().joined(separator: ".")
//    }
//    
//    static var storyboardIdentifier: String {
//        return self.description().components(separatedBy: ".").dropFirst().joined(separator: ".")
//    }
//}
//
extension Bundle {
    public static func current() -> Bundle? {
        guard let path = Bundle(for: LHTools.self).resourcePath?.appending("/LHTools.bundle") else { return nil }
        return Bundle(path: path)
    }
}
//
//extension UIImage {
//    public static func image(_ named: String) -> UIImage? {
//        return UIImage(named: named, in: Bundle.current(), compatibleWith: nil)
//    }
//}
//
//extension String {
//    public func cc_localized() -> String {
//        return localized(using: nil, in: Bundle.current())
//    }
//}
//
//extension UIView {
//    public static func loadNib(_ name: String) -> UIView? {
//        return UIView.loadFromNib(named: name, bundle: Bundle(for: CLTools.self))
//    }
//}

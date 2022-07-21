//
//  Utils.swift
//  wangfuAgent
//
//  Created by lzw on 2018/7/17.
//  Copyright © 2018 zhuanbangTec. All rights reserved.
//

import UIKit
import Foundation

import SwiftyUserDefaults

public class Utils: NSObject {

    public static let appCurVersion:String = {
        let s = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let arr = s.components(separatedBy: ".")
        let result = "\(arr[0]).\(arr[1])"
        return result
    }()
    
    public static let appCurVersionInt:Int = {
        let ver = Utils.appCurVersion
        let arr = ver.components(separatedBy: ".")
        let a = arr[0].toInt()
        let b = arr[1].toInt()
        let result = a * 1000 + b
        return result
    }()

    public static let deviceSysVersion:String = {
        return UIDevice.current.systemVersion
    }()

    public static let deviceUUID:String? = {
        return UIDevice.current.identifierForVendor?.uuidString
    }()
    ///此方法需要开启keychain 保证UUID不变
    public static let keychainDeviceUUID:String? = {
        let keychain = KeychainSwift()
        if let uuid = keychain.get("keychainDeviceUUID") {
            return uuid
        }
        if let uuid = UIDevice.current.identifierForVendor?.uuidString{
            keychain.set(uuid, forKey: "keychainDeviceUUID")
        }
        return nil
    }()

}




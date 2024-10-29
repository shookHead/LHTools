//
//  Utils.swift
//  wangfuAgent
//
//  Created by  on 2018/7/17.
//  Copyright © 2018 zhuanbangTec. All rights reserved.
//

import UIKit
import Foundation

import SwiftyUserDefaults

public class Utils: NSObject {
    
    typealias AppInfoCompletion = (_ version: String?, _ downloadUrl: String?) -> Void
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
        if let uuid = keychain.get("keychainDeviceUUID"){
            return uuid
        }
        if let uuid = UIDevice.current.identifierForVendor?.uuidString{
            keychain.set(uuid, forKey: "keychainDeviceUUID")
            return uuid
        }
        return nil
    }()

    // 创建一个函数来执行异步请求
    func fetchAppInfo(completion: @escaping AppInfoCompletion) {
        let identifier = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") ?? ""
        // 定义 URL
        guard let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
            completion(nil, nil)
            return
        }
        // 创建 URLSession
        let session = URLSession.shared

        // 创建数据任务
        let task = session.dataTask(with: url) { data, response, error in
            // 处理错误
            if let error = error {
                print("错误: \(error.localizedDescription)")
                completion(nil, nil)
                return
            }

            guard let data = data else {
                print("没有收到数据")
                completion(nil, nil)
                return
            }

            // 解析 JSON 数据
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   results.count > 0,
                   let version = results[0]["version"] as? String,
                   let downloadUrl = results[0]["trackViewUrl"] as? String {
                    // 通过闭包返回解析后的结果
                    completion(version, downloadUrl)
                } else {
                    // 返回空值，表示没有找到需要的数据
                    completion(nil, nil)
                }
            } catch {
                print("解析 JSON 错误: \(error.localizedDescription)")
                completion(nil, nil)
            }
        }

        // 启动任务
        task.resume()
    }

}




//
//  LHClearCache.swift
//  LHTools
//
//  Created by 蔡林海 on 2021/8/27.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
public enum LHClearCacheType:String{
    case size_B     //B
    case size_KB    //KB
    case size_MB    //MB
    case size_GB    //GB
}
public class LHClearCache: NSObject {
    ///清除缓存 Library/Caches
    public static func clearCaches(_ arr:[String] = [] , _ complete: @escaping (() -> ())){
        do {
            try deleteLibraryFolderContents(folder: "Caches")
            cache.clearCache(true, arr)
            DispatchQueue.global().async {
                complete()
                //print("clear done")
            }
        } catch {
            //print("clear Caches Error")
        }
    }
     
    static func deleteLibraryFolderContents(folder: String) throws {
         let manager = FileManager.default
         let library = manager.urls(for: FileManager.SearchPathDirectory.libraryDirectory, in: .userDomainMask)[0]
         let dir = library.appendingPathComponent(folder)
         let contents = try manager.contentsOfDirectory(atPath: dir.path)
         for content in contents {
             //如果是快照就结束
             if(content == "Snapshots"){continue}
             do {
                 try manager.removeItem(at: dir.appendingPathComponent(content))
                 //print("remove cache success:"+content)
             } catch where ((error as NSError).userInfo[NSUnderlyingErrorKey] as? NSError)?.code == Int(EPERM) {
                 //print("remove cache error:"+content)
                 // "EPERM: operation is not permitted". We ignore this.
                 #if DEBUG
                     //print("Couldn't delete some library contents.")
                 #endif
             }
         }
     }
    
    ///获取缓存大小
    public static func getFileSizeOfCache(_ type:LHClearCacheType = .size_B) -> String {
        let size = getAllCache(type)
        return size.getFormateString([.hideDot])
    }
    ///返回缓存大小(带单位)
    public static func getFileSizeOfCacheWithUnit() -> String {
        var convertedValue: Double = getAllCache()
        var multiplyFactor = 0
        let tokens = ["B","KB","MB","GB","TB","PB","EB","ZB", "YB"]
        while convertedValue > 1024 {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        return String(format: "%4.2f%@", convertedValue, tokens[multiplyFactor])
    }
    static func getAllCache(_ type:LHClearCacheType = .size_B) -> Double {
        let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
        print(cachePath!)
        let fileArr = FileManager.default.subpaths(atPath: cachePath!)
        var size:Double = 0
        for file in fileArr! {
            let path = cachePath?.appending("/\(file)")
            let floder = try! FileManager.default.attributesOfItem(atPath: path!)
            for (abc,bcd) in floder {
                if abc == FileAttributeKey.size {
                    size += (bcd as AnyObject).doubleValue
                }
            }
        }
        if type == .size_KB{
            size = size / 1024.0
        }else if type == .size_MB{
            size = size / 1024.0 / 1024.0
        }else if type == .size_GB{
            size = size / 1024.0 / 1024.0 / 1024.0
        }
        return size
    }
}

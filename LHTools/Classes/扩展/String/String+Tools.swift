//
//  String+Tools.swift
//  LHTools
//
//  Created by clh on 2021/12/8.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Photos

public extension String{
    //中文转拼音
    func transToPinYin(str:String)->String{
        //转化为可变字符串
        let mString = NSMutableString(string: str)
        //转化为带声调的拼音
        CFStringTransform(mString, nil, kCFStringTransformToLatin, false)
        //转化为不带声调
        CFStringTransform(mString, nil, kCFStringTransformStripDiacritics, false)
        //转化为不可变字符串
        let string = NSString(string: mString)
        //去除字符串之间的空格
        return string.replacingOccurrences(of: " ", with: "")
    }
    
    ///此方法弃用请使用jsonToDictionary
    func getJsonDic() -> Any?{
        if self.count == 0{
            return nil
        }
        let data = self.data(using: .utf8)
        let result = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
        return result
    }
    //JSON字符串 -> 字典
    func jsonToDictionary() -> Dictionary<String, Any>? {
        if let data = (try? JSONSerialization.jsonObject(
            with: self.data(using: String.Encoding.utf8,allowLossyConversion: true)!,
            options: JSONSerialization.ReadingOptions.mutableContainers)) as? Dictionary<String, Any> {
            return data
        } else {
            return nil
        }
    }
    ///隐藏中间部分电话号码
    func hideFourPhoneNum() -> String{
        if self.count < 11{
            return self
        }
        guard let s1 = self[0...2] else { return  ""}
        guard let s2 = self[7...10] else { return "" }
        let result:String = String(format:"%@****%@",String(s1),String(s2))
        return result
    }

    
    /// 拨打电话
    func callPhone() {
        let phone = self
        if !phone.isEmpty {
            var tel = "tel://"+phone
            //去掉空格-不然有些电话号码会使 URL 报 nil
            tel = tel.replacingOccurrences(of: " ", with: "", options: .literal, range: nil);
            if let urls = URL(string: tel){
                DispatchQueue.main.async {
                    UIApplication.shared.open(urls, options: [:], completionHandler: nil)
                }
            }
        }
    }
    ///将字符串倒叙
    @discardableResult
    mutating func reverse() -> String {
        let chars: [Character] = reversed()
        self = String(chars)
        return self
    }
    ///将字符串转HTML 用法htmlLabel.attributedText = htmlString.htmlAttributedString()
    func htmlAttributedString() -> NSAttributedString? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        return try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil
        )
    }
    
    func downloadVideoAndSaveToAlbum(finish: @escaping (_ mod:ZBJsonString?)->()) {
        let mod = ZBJsonString()
        mod.code = 0
//        defer {
//            finish(mod)
//        }
        guard let url = URL.init(string: self) else {
            mod.msg = lhInvalidUrl
            finish(mod)
            return
        }
        Hud.showWait()
        let downloadTask = URLSession.shared.downloadTask(with: url) { (location, response, error) in

            guard let location = location, error == nil else {
                let msg = error?.localizedDescription ?? lhUnknownError
                print("下载视频失败：\(msg)")
//                Hud.showText(msg)
                mod.msg = msg
                finish(mod)
                return
            }
            let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationURL = documentsDirectoryURL.appendingPathComponent(url.lastPathComponent)
            
            do {
                try FileManager.default.moveItem(at: location, to: destinationURL)
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: destinationURL)
                }) { (s, error) in
                    lh.runThisInMainThread {
                        if s {
//                            Hud.showText("视频已保存到相册")
//                            success("视频已保存到相册")
                            mod.code = 1
                            mod.msg = lhSaveToAlbum
                            finish(mod)
                        } else {
                            let msg = error?.localizedDescription ?? lhUnknownError
//                            Hud.showText(msg)
                            mod.msg = msg
                            finish(mod)
                        }
                    }
                }
            } catch {
                lh.runThisInMainThread {
//                    Hud.showText("移动视频文件失败")
                    mod.msg = lhMoveVideoFail
                    finish(mod)
                }
            }
        }
        downloadTask.resume()
    }
}

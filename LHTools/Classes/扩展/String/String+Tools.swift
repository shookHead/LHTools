//
//  String+Tools.swift
//  LHTools
//
//  Created by clh on 2021/12/8.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

extension String{
    //中文转拼音
    public func transToPinYin(str:String)->String{
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

    public func getJsonDic() -> Any?{
        if self.count == 0{
            return nil
        }
        let data = self.data(using: .utf8)
        let result = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
        return result
    }
    ///隐藏中间部分电话号码
    public func hideFourPhoneNum() -> String{
        if self.count < 11{
            return self
        }
        guard let s1 = self[0...2] else { return  ""}
        guard let s2 = self[7...10] else { return "" }
        let result:String = String(format:"%@****%@",String(s1),String(s2))
        return result
    }

    
    /// 拨打电话
    public func callPhone() {
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

    
}

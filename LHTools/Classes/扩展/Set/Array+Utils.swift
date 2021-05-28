//
//  Sting+Utils.swift
//  wangfuAgent
//
//  Created by lzw on 2018/7/18.
//  Copyright © 2018 zhuanbangTec. All rights reserved.
//

import Foundation

extension Array{
    
    // 防止越界崩溃
    public func bm_object(_ at:Int) -> Element? {
        if at >= self.count || at < 0{
            return nil
        }else{
            return self[at]
        }
    }
    
    public func getJsonStr() -> String?{
        let data = try? JSONSerialization.data(withJSONObject: self, options: [])
        if data != nil{
            let strJson = String(data: data!, encoding: String.Encoding.utf8)
            return strJson
        }
        return nil
    }

}


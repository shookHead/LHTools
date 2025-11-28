//
//  HostConfig.swift
//  wenzhuan
//
//  Created by yimi on 2020/5/25.
//  Copyright © 2020 baymax. All rights reserved.
//

import Foundation
import UIKit

/// 使用
//let conf = HostConfig(["wangfu：","合伙人："])
//conf.showConfigView()



// 管理测试服和正式服的工具

public extension BMDefaultsKeys{
    // 是否开启测试服
    static let isTestHost = BMCacheKey<Bool?>("isHost")
    static let savedHosts = BMCacheKey<Array<String>?>("savedHosts")
}

open class HostConfig{
    var isTestHost:Bool!{
        didSet{
            cache[.isTestHost] = isTestHost
        }
    }
    //遮罩
    let mask = UIButton()
    
    let contentView = UIView()
    let isTestSwitch = UISwitch()
    
    var names:[String] = []
    var tfArray:[UITextField] = []
    open var apiTF = UITextField()
    public init(_ names:[String]) {
        if cache[.isTestHost] == true{
            self.isTestHost = true
        }else{
            self.isTestHost = false
        }
        
        mask.frame = CGRect(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight)
        mask.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5478685462)
        mask.addTarget(self, action: #selector(closeConfigView(_:)), for: .touchUpInside)
        
        self.names = names
        self.initUI()
    }
    
    public func showConfigView(){
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        mask.alpha = 0
        contentView.alpha = 0
        window?.addSubview(mask)
        window?.addSubview(contentView)
        UIView.animate(withDuration: 0.2) {
            self.mask.alpha = 1
            self.contentView.alpha = 1
        }
    }
    
    func initUI() {
        let contentW = UIScreen.main.bounds.width - 40
        
        let lab1 = UILabel(frame: CGRect(x: 15, y: 20, width: 80, height: 31))
        lab1.text = lhUsingTest
        lab1.font = UIFont.systemFont(ofSize: 15)
        lab1.textColor = UIColor.lightGray
        contentView.addSubview(lab1)
        
        isTestSwitch.frame = CGRect(x: contentW - 49-20, y: lab1.y, width: 0, height: 0)
        contentView.addSubview(isTestSwitch)
        var y:CGFloat = 65
        var i = 0
        for name in names{
            let view = UIView(frame: CGRect(x: 15, y: y, width: contentW-30, height: 75))
            
            let line = UIView(frame: CGRect(x: 0, y: 0, width: contentW-30, height: 1))
            line.backgroundColor = #colorLiteral(red: 0.9014675021, green: 0.9016187787, blue: 0.9014475942, alpha: 1)
            view.addSubview(line)
            
            
            let lab = UILabel(frame: CGRect(x: 0, y: 12, width: 80, height: 24))
            lab.text = name
            lab.font = UIFont.systemFont(ofSize: 15)
            lab.textColor = UIColor.gray
            view.addSubview(lab)
            
            let lab2 = UILabel(frame: CGRect(x: 0, y: 30, width: 45, height: 34))
            lab2.text = "http://"
            lab2.font = UIFont.systemFont(ofSize: 15)
            lab2.textColor = UIColor.lightGray
            view.addSubview(lab2)
            
            apiTF = UITextField(frame: CGRect(x: 46, y: 30, width: 200, height: 34))
            apiTF.placeholder = "api.163.gg"
            apiTF.font = UIFont.systemFont(ofSize: 15)
            apiTF.textColor = UIColor.lightGray
            view.addSubview(apiTF)
            tfArray.append(apiTF)
            
            apiTF.text = cache[.savedHosts]?.bm_object(i)

            contentView.addSubview(view)
            y += 75
            i += 1
        }
        contentView.frame = CGRect(x: 20, y: 100, width: contentW, height: y)
        contentView.layer.cornerRadius = 15
        contentView.backgroundColor = .white

    }
    
    @objc func closeConfigView( _ btn:UIButton) -> Void {
        for tf in tfArray{
            tf.resignFirstResponder()
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.mask.alpha = 0
            self.contentView.alpha = 0
        }) { (_) in
            self.contentView.removeFromSuperview()
            self.mask.removeFromSuperview()
        }
        var arr : Array<String> = []
        for tf in tfArray{
            var text = tf.text ?? ""
            if !text.notEmpty {
                text = tf.placeholder ?? ""
            }
            arr.append(text)
        }
        
        // 存档
        cache[.savedHosts] = arr
        cache[.isTestHost] = isTestSwitch.isOn
    }
    
    public static func getHost(_ publishHost:String, index:Int) -> String{
        if cache[.isTestHost] == false{
            return publishHost
        }else{
            if let arr = cache[.savedHosts]{
                if arr.count == 0 || arr.count <= index{
                    print("测试服地址为空，使用正式地址")
                    return publishHost
                }else{
                    let url = arr[index]
                    if url.contains("http"){
                        return url
                    }else{
                        return "http://\(url)"
                    }
                }
            }else{
                print("测试服地址为空，使用正式地址")
                return publishHost
            }
        }
    }
}




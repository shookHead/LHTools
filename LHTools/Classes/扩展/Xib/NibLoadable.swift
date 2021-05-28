//
//  NibLoadable.swift
//  wenzhuanMerchants
//
//  Created by 蔡林海 on 2020/8/20.
//  Copyright © 2020 baymax. All rights reserved.
//

import UIKit

public protocol NibLoadable {
}
extension NibLoadable where Self : UIView {
    //在协议里面不允许定义class 只能定义static
    public static func loadFromNib(_ nibname: String? = nil) -> Self {//Self (大写) 当前类对象
        //self(小写) 当前对象
        let loadName = nibname == nil ? "\(self)" : nibname!
        return Bundle.main.loadNibNamed(loadName, owner: nil, options: nil)?.first as! Self
    }
}


public class XibView: UIView {
    @discardableResult
    public static func creatView()  -> Self {
        let loadName = "\(self)"
        return Bundle.main.loadNibNamed(loadName, owner: nil, options: nil)?.first as! Self
    }
}

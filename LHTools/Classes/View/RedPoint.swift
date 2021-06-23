//
//  RedPoint.swift
//  MaDianCanBusiness
//
//  Created by 蔡林海 on 2020/12/3.
//

import UIKit

class RedPoint: NSObject {
    static var RedPointTag = 1267562
    
    public static func show(view:UIView ,x:CGFloat,y:CGFloat) {
        var redPoint = view.viewWithTag(RedPointTag)
        if redPoint == nil {
            redPoint = UIView.init(frame: CGRect(x: view.w-8, y: 0, width: 8, height: 8))
            redPoint?.backgroundColor = .KRed
            redPoint?.layer.cornerRadius = redPoint!.w/2
            redPoint?.layer.masksToBounds = true
            redPoint?.tag = RedPointTag
            view.addSubview(redPoint!)
        }
        redPoint?.x = x
        redPoint?.y = y
        redPoint?.isHidden = false
    }
    public static func showIn(view:UIView,str:String,x:CGFloat,y:CGFloat,textColor:UIColor = .white){
        var redPoint = view.viewWithTag(RedPointTag) as? UILabel
        if redPoint == nil {
            redPoint = UILabel.init(frame: CGRect(x: view.w-16, y: 0, width: 16, height: 16))
            redPoint?.backgroundColor = .KRed
            redPoint?.layer.cornerRadius = redPoint!.w/2
            redPoint?.layer.masksToBounds = true
            redPoint?.tag = RedPointTag
            redPoint?.font = UIFont.systemFont(ofSize: 12)
            redPoint?.textAlignment = .center
            redPoint?.textColor = textColor
            view.addSubview(redPoint!)
        }
        if str.notEmpty {
            redPoint?.text = str
            redPoint?.x = x
            redPoint?.y = y
            redPoint?.w = CGFloat(str.count*9+7)
            redPoint?.isHidden = false
        }else{
            redPoint?.isHidden = true
        }
    }
    public static func hide(view:UIView){
        let redPoint = view.viewWithTag(RedPointTag)
        if redPoint != nil {
            redPoint?.isHidden = true
        }
    }
}

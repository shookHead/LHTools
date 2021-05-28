//
//  AlertView.swift
//  wangfuAgent
//
//  Created by lzw on 2018/7/23.
//  Copyright © 2018 zhuanbangTec. All rights reserved.
//

import UIKit

extension UIViewController{
    // baseView
    public func showAlertView(_ title:String, _ msg:String, complish: (() -> ())? = nil, cancel: (() -> ())? = nil){
        UIView.animate(withDuration: 0.1) {
            let alertVC = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "确认", style: .default, handler: { (action) in
                complish?()
            })
            let cancelAction = UIAlertAction(title: "取消", style: .cancel , handler:{ (action) in
                cancel?()
            })
            alertVC.addAction(cancelAction)
            alertVC.addAction(okAction)
            self.present(alertVC, animated: YES, completion: nil)
        }
    }
    
    public func showComfirm(_ title:String, _ msg:String, cancel:(()->())? = nil, complish:(()->())? = nil){
        self.showAlertView(title, msg, complish: complish, cancel: cancel)
        
    }
    
}




public var alertShow = AlertViewShow()
public class AlertViewShow: NSObject,UITextFieldDelegate {
    var _pointLength = 0
    var _vc = UIViewController()
    open var maxP:Double = 10000000
    var canZero = false
    //pointLength设置小数点数
    /// 输入框
    /// - Parameters:
    ///   - title: 标题
    ///   - msg: 提示
    ///   - placeholder: 占位文字
    ///   - text: 文字
    ///   - keyBoard: 类型
    ///   - pointLength: 小数点
    ///   - complish: 完成
    ///   - cancel: 取消
    public func showAlertTextFieldView(vc:UIViewController,_ title:String, _ msg:String,placeholder:String = "",text:String = "" ,keyBoard:UIKeyboardType = .default,pointLength:Int = 0, complish: ((String) -> ())? = nil, cancel: (() -> ())? = nil){
        UIView.animate(withDuration: 0.1) {
            self._vc = vc
            self._pointLength = pointLength
            let alertVC = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "确认", style: .default, handler: { (action) in
                let tf = alertVC.textFields!.first
                self.initData()
                complish?(tf!.text!)
            })
            let cancelAction = UIAlertAction(title: "取消", style: .cancel , handler:{ (action) in
                self.initData()
                cancel?()
            })
            alertVC.addTextField(configurationHandler: { (textField) in
                textField.placeholder = placeholder
                textField.keyboardType = keyBoard
                textField.text = text
                textField.delegate = self
            })
            
            alertVC.addAction(cancelAction)
            alertVC.addAction(okAction)
            okAction.isEnabled = false
            vc.present(alertVC, animated: true, completion: nil)
        }
    }
    ///初始化数据
    func initData()  {
        self.maxP = 10000000
        canZero = false
    }
    func textDidChange(text:String){
        var enable = true//true 允许点击 false 不允许点击
        let p = text.toDouble()
        if text.count == 0 || p <= 0{
//            enable = false
            if text == "0" {
                enable = canZero
            }else{
                enable = false
            }
        }

        
        let alertController = self._vc.presentedViewController as? UIAlertController
        if alertController != nil {
            let okAction = alertController!.actions.last! as UIAlertAction
            okAction.isEnabled = enable
        }
    }
    // MARK: - UITextFieldDelegate
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let oldStr = textField.text ?? ""
        var newStr = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        print("\(oldStr)----\(newStr)----\(self._pointLength)")
        
        var contain = false
        //过滤非数字.
        for i in newStr {
            if "0123456789.".contains(i)==false{
                let index = newStr.firstIndex(of: i)
                if index != nil{
                    newStr.remove(at: index!)
                    contain = true
                }
            }
        }
        if contain{
            textField.text = newStr
            return false
        }

        if oldStr.contains(".") && string == "." {//出现第2个点的时候不返回
            textDidChange(text: oldStr)
            return false
        }
        if (oldStr.count == 0 || oldStr == "0") && string == "."{
            textField.text = "0."
            textDidChange(text: textField.text!)
            return false
        }
        if oldStr == "0" && range.location > 0{
            if string == "0" {
                textDidChange(text: oldStr)
                return false
            }else if string == "."{
                textDidChange(text: newStr)
                return true
            }else{
                if string.toDouble() > maxP {//如果比最大值大就不返回
                    return false
                }
                textField.text = string
                textDidChange(text: textField.text!)
                return false
            }
        }
        //已经有数字。前面还输入0就不返回
        if oldStr.count > 0 && string == "0" && range.location == 0 {
            textDidChange(text: oldStr)
            return false
        }
        if newStr.contains(".") {
            let arr = newStr.components(separatedBy: ".")
            if arr.count == 2 {
                let subStr = arr[1]
                if subStr.count > self._pointLength {
                    textDidChange(text: oldStr)
                    return false
                }
            }
        }
        
        //超过千万的不返回
        if newStr.count > 0 {
            let p = newStr.toDouble()
            if p > maxP {
                textDidChange(text: oldStr)
                return false
            }
        }
        textDidChange(text: newStr)
        return true
    }
    public func showTextFieldComfirm(vc:UIViewController, _ title:String, _ msg:String,  placeholder:String,text:String = "",keyBoard:UIKeyboardType = .default,pointLength:Int = 0, cancel:(()->())? = nil, complish:((String)->())? = nil){
        self.showAlertTextFieldView(vc:vc, title, msg, placeholder: placeholder,text:text, keyBoard: keyBoard,pointLength: pointLength, complish: complish, cancel: cancel)
    }
}

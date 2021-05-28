//
//  LHTextField.swift
//  QianRuChao
//
//  Created by 蔡林海 on 2020/5/29.
//  Copyright © 2020 蔡林海. All rights reserved.
//

import UIKit

open class LHTextField: UITextField,UITextFieldDelegate {
    ///小数点后面保留的数字。默认是2
    public var pointLength = 2
    public var maxP = 1000000.0
    
    public var textChangeBlock:((_ text:String)->())?
    @objc public dynamic var newText = ""{
        didSet{
//            print("newText:\(newText)")
            if textChangeBlock != nil {
                textChangeBlock!(newText)
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.common()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.common()
    }
  
    func common() {
        newText = self.text ?? ""
        self.delegate = self
    }
    func textChangeBlock(_ closure : @escaping (_ text:String) -> ())  {
        textChangeBlock = closure
    }
    // MARK: - UITextFieldDelegate
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldStr = textField.text ?? ""
        var newStr = (textField.text! as NSString).replacingCharacters(in: range, with: string)
//        print("\(oldStr)----\(newStr)----\(self.pointLength)---\(string)")
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
            newText = textField.text!
            return false
        }
        
        if oldStr.contains(".") && string == "." {//出现第2个点的时候不返回
            newText = textField.text!
            return false
        }
        if (oldStr.count == 0 || oldStr == "0") && string == "."{
            textField.text = "0."
            newText = textField.text!
            return false
        }
        if oldStr == "0" && range.location > 0{
            if string == "0" {
                newText = textField.text!
                return false
            }else if string == "."{
                newText = newStr
                return true
            }else{
                if string.toDouble() > maxP {//如果比最大值大就不返回
                    newText = textField.text!
                    return false
                }
                textField.text = string
                newText = textField.text!
                return false
            }
        }
        //已经有数字。前面还输入0就不返回
        if oldStr.count > 0 && string == "0" && range.location == 0 {
            newText = textField.text!
            return false
        }
        if newStr.contains(".") {
            let arr = newStr.components(separatedBy: ".")
            if arr.count == 2 {
                let subStr = arr[1]
                if subStr.count > self.pointLength {
                    newText = textField.text!
                    return false
                }
            }
        }
     
        //超过最大限制的数字不返回
        if newStr.count > 0 {
            let p = newStr.toDouble()
            if p > maxP {
                newText = textField.text!
                return false
            }
        }
        newText = newStr
        return true
    
    }
    override open func layoutSubviews() {
        super.layoutSubviews()
    }
}

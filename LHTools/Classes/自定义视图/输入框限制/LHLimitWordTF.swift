//
//  LHLimitWordTF.swift
//  QianRuChao
//
//  Created by 蔡林海 on 2020/7/24.
//  Copyright © 2020 蔡林海. All rights reserved.
//

import UIKit

open class LHLimitWordTF: UITextField, UITextFieldDelegate {
    ///最大输入字数
    public var maxNum = 1000000
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.common()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.common()
    }
    func common() {
        self.delegate = self
    }
    // MARK: - UITextFieldDelegate
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {        
        let newStr = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if string.count == 0 {
            return true
        }
        if newStr.count > maxNum {
            return false
        }
        return true
    }
}

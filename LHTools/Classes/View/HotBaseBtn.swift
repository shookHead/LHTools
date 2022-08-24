//
//  HotBaseBtn.swift
//  fjksfjlksdfew
//
//  Created by 蔡林海 on 2021/7/30.
//

import UIKit

open class HotBaseBtn: UIButton {
    ///扩大点击范围
    var margin: CGFloat = 20
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let area = self.bounds.insetBy(dx: -margin, dy: -margin)
        return area.contains(point)
    }
    
}

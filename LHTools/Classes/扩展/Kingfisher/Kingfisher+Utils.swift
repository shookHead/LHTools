//
//  Kingfisher+Utils.swift
//  BaseUtils
//
//  Created by yimi on 2019/5/24.
//  Copyright © 2019 yimi. All rights reserved.
//

import Foundation
import UIKit

extension Optional where Wrapped == String{
    public var resource:ImageResource?{
        if self == nil{
            return nil
        }else{
            return self!.resource
        }
    }
}

extension String{
    public var resource:ImageResource! {
        if self.count == 0{
            return nil
        }
        guard self.contains("http") else {
            return nil
        }
        if let url = URL(string: self) {
            return ImageResource(downloadURL: url)
        }else{
            return nil
        }
    }
}

extension UIImageView {
    public func setUrlImage(_ url:String) {
        self.kf.setImage(with: url.resource)
    }
}


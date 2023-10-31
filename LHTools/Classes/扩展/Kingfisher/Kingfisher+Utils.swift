//
//  Kingfisher+Utils.swift
//  BaseUtils
//
//  Created by yimi on 2019/5/24.
//  Copyright © 2019 yimi. All rights reserved.
//

import Foundation
import UIKit
public typealias ImageResource = Kingfisher.ImageResource
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
    public func setImage(_ url:String,placeholder: Placeholder? = nil,options: KingfisherOptionsInfo? = [.transition(.fade(0.2))],completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil) {
        self.kf.setImage(with: url.resource, placeholder: placeholder, options: options,completionHandler: completionHandler)
    }
}


//
//  UIView+uploadImg.swift
//  wangfuAgent
//
//  Created by  on 2018/7/25.
//  Copyright © 2018 zhuanbangTec. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

let progressTag = 98362

extension UIButton{
    public enum ButtonEdgeInsetsStyle {
        ///图片在上,文字在下
        case top
        ///图片在左,文字在右
        case left
        ///图片在下,文字在上
        case bottom
        ///图片在右,文字在左
        case right
    }
    
    
    public var isUploading:Bool{
        if let v = self.viewWithTag(progressTag){
            if v.alpha == 0{
                return false
            }else{
                return true
            }
        }
        return false
    }
    
    public func upload(img:UIImage,showPrograss:Bool,complish:@escaping (_ btn:UIButton?,_ success:Bool,_ url:String?) -> ()){
        network.upload(img, uploading: {[weak self] (progress) in
            if showPrograss == true{
                self?.setPrograss(showPrograss, progress)
            }
        }) {[weak self]  (url) in
            if showPrograss == true{
                self?.setPrograss(showPrograss,100)
            }
            if url != nil{
                complish(self ,true,url)
            }else{
                self?.setFaild()
                complish(self,false,url)
            }
        }
    }
    
    public func setPrograss(_ show:Bool, _ prograss:Double){
        if !show {
            return
        }
        var progressView = self.viewWithTag(progressTag)
        if progressView == nil {
            progressView = UIView.init(frame: CGRect(x: 0, y: self.frame.size.height-5, width: 15, height: 5))
            progressView!.backgroundColor = .KBlue
            progressView!.tag = progressTag
            self.addSubview(progressView!)
        }
        
        if prograss == 100{
            UIView.animate(withDuration: 0.15, animations: {
                progressView!.alpha = 0
            })
        }else{
            progressView!.alpha = 1
            UIView.animate(withDuration: 0.15, animations: {
                progressView!.frame.size.width = 15.0 + (self.frame.size.width - 15) * CGFloat(prograss)
            })
        }
    }
    
    public func setFaild(){
        var progressView = self.viewWithTag(progressTag)
        if progressView == nil {
            progressView = UIView.init(frame: CGRect(x: 0, y: self.frame.size.height-5, width: 15, height: 5))
            progressView!.backgroundColor = .KRed
            progressView!.tag = progressTag
            self.addSubview(progressView!)
        }
        progressView!.backgroundColor = .KRed
        
        progressView!.alpha = 1
        UIView.animate(withDuration: 0.15, animations: {
            progressView!.frame.size.width = self.frame.size.width
        })
    }
    
    // 是否已显示加载器
    public var isShowIndicator:Bool{
        if let view = self.viewWithTag(93339) as? NVActivityIndicatorView {
            return view.isAnimating
        }
        return false
    }
    
    // 显示等待 加载器
    public func showIndicator() -> Void {
        let lab = UILabel()
        lab.text = self.titleLabel?.text
        lab.isHidden = true
        lab.tag = 93338
        self.isUserInteractionEnabled = false
        self.addSubview(lab)
        self.setTitle("", for: .normal)
        
        
        let rect = CGRect(x: (self.frame.size.width-30) / 2, y: 7, width: 30, height: 30)
        let activityIndicatorView = NVActivityIndicatorView(frame: rect,
                                                            type: NVActivityIndicatorType.circleStrokeSpin)
        activityIndicatorView.tag = 93339
        activityIndicatorView.color = .white
        activityIndicatorView.startAnimating()
        self.addSubview(activityIndicatorView)
    }
    
    // 显示等待 加载器
    public func hideIndicator() -> Void {
        if let lab = self.viewWithTag(93338) as? UILabel{
            lab.removeFromSuperview()
            self.setTitle(lab.text, for: .normal)
        }
        if let view = self.viewWithTag(93339) as? NVActivityIndicatorView {
            view.removeFromSuperview()
            view.stopAnimating()
        }
        self.isUserInteractionEnabled = true
    }
    
    /// 在按钮布局完之后调用，设置图片和文字的位置
    /// - Parameters:
    ///   - style: 设置图片和文字位置
    ///   - space: 间距
    public func buttonWithEdgeInsetsStyle(style:ButtonEdgeInsetsStyle,space:CGFloat = 4.0)  {
        let imageWith = self.imageView?.frame.size.width
        let imageHeight = self.imageView?.frame.size.height
        let labelWidth = self.titleLabel?.intrinsicContentSize.width
        let labelHeight = self.titleLabel?.intrinsicContentSize.height
        var imageEdgeInsets=UIEdgeInsets.zero
        var labelEdgeInsets=UIEdgeInsets.zero
        switch style {
        case .top:
            imageEdgeInsets = UIEdgeInsets(top: -labelHeight!-space/2.0, left: 0, bottom: 0, right: -labelWidth!)
            labelEdgeInsets = UIEdgeInsets(top: 0, left: -imageWith!, bottom: -imageHeight!-space/2.0, right: 0)
        case .left:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -space/2.0, bottom: 0, right: space/2.0)
            labelEdgeInsets = UIEdgeInsets(top: 0, left: space/2.0, bottom: 0, right: -space/2.0)
        case .bottom:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: -labelHeight!-space/2.0, right: -labelWidth!)
            labelEdgeInsets = UIEdgeInsets(top: -imageHeight!-space/2.0, left: -imageWith!, bottom: 0, right: 0)
        case .right:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: labelWidth!+space/2.0, bottom: 0, right: -labelWidth!-space/2.0)
            labelEdgeInsets = UIEdgeInsets(top: 0, left: -imageWith!-space/2.0, bottom: 0, right: imageWith!+space/2.0)
        }
        self.titleEdgeInsets = labelEdgeInsets
        self.imageEdgeInsets = imageEdgeInsets
    }
    
    
    
}





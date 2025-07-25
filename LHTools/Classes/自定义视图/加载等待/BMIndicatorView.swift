//
//  BMIndicatorView.swift
//  BaseUtilsDemo
//
//  Created by yimi on 2019/8/9.
//  Copyright © 2019 yimi. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
// 指示器状态
public enum IndicatorViewState {
    case none    //
    case loading //加载中
    case noData  //没有数据
    case request //重新请求
    case hide    //隐藏
}
public class BMIndicatorView: UIView {
    public var state = IndicatorViewState.none

    var myMaskView:UIView!
    
    var activityIndicatorView:NVActivityIndicatorView!
    var activityIndicatorLab:UILabel!
    
    var contentBG:UIView!
    
    public var contentImgView:UIImageView!
    public var contentLab:UILabel!
    public static var noDataImageName:String?
    
    public var requestImageName:String!
    public var requestBtn:UIButton!
    
    public var color:UIColor?{
        didSet{ activityIndicatorView.color = color!
            activityIndicatorLab.textColor = color!}
    }
    
    public class func showInView(_ view:UIView,frame:CGRect) -> BMIndicatorView {
        let v = BMIndicatorView(frame: frame)
        view.addSubview(v)
        v.initUI()
        v.alpha = 0
        return v
    }
    
    
    func initUI() {
        
        myMaskView = UIView()
        self.addSubview(myMaskView)
        myMaskView.isHidden = true
        myMaskView.bm.addConstraints([.margin(0, 0, 0, 0)])

        
        var w:CGFloat = 35
        var h:CGFloat = w

        activityIndicatorView = NVActivityIndicatorView(frame: .init(x: 0, y: 0, width: w, height: h),
                                                        type: NVActivityIndicatorType.ballBeat)
        activityIndicatorView!.color = .KTextLightGray
        self.addSubview(activityIndicatorView!)
        activityIndicatorView.bm.addConstraints([.w(w), .h(w), .center])
        
        w = 70
        h = 20
        activityIndicatorLab = UILabel(frame: .zero)
        activityIndicatorLab.text = lhLoading
        activityIndicatorLab.textAlignment = .center
        activityIndicatorLab.font = UIFont.systemFont(ofSize: 15)
        activityIndicatorLab.textColor = .KTextLightGray
        activityIndicatorLab.isHidden = YES
        self.addSubview(activityIndicatorLab)
        activityIndicatorLab.bm.addConstraints([.top((self.h-w)/2+4), .center_X(0), .w(w), .h(h)])
        
        
        w = 160
        h = 200
        self.contentBG = UIView()
        self.addSubview(self.contentBG)
        self.contentBG.bm.addConstraints([.w(w), .h(h), .center_X(0), .center_Y(-15)])
        
        let imgH = CGFloat(150)
        self.contentImgView = UIImageView()
        self.contentImgView.contentMode = .bottom
        self.contentBG.addSubview(self.contentImgView)
        contentImgView.bm.addConstraints([.left(0), .top(0), .w(w), .h(imgH)])
        
        requestBtn = UIButton(type: .system)
        requestBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        requestBtn.setTitle(lhClickRefresh, for: .normal)
        requestBtn.setTitleColor(.KTextLightGray, for: .normal)
        requestBtn.layer.cornerRadius = 10
        requestBtn.layer.borderWidth = 1
        requestBtn.layer.masksToBounds = true
        requestBtn.layer.borderColor = UIColor.KTextLightGray.cgColor
        self.contentBG.addSubview(requestBtn)
        var requestBtnW:CGFloat = 85
        if lhClickRefresh == "Click Refresh" {
            requestBtnW = 95
        }
        requestBtn.bm.addConstraints([.center_X(0), .under(contentImgView, 10), .w(requestBtnW), .h(34)])
        
        self.contentLab = UILabel()
        self.contentLab.text = lhNoData + "\n"
        self.contentLab.numberOfLines = 0
        self.contentLab.textAlignment = .center
        self.contentLab.font = UIFont.systemFont(ofSize: 16)
        self.contentLab.textColor = .KTextLightGray
        self.contentBG.addSubview(self.contentLab)
        contentLab.bm.addConstraints([.left(0), .under(contentImgView, 10), .w(w), .h(48)])

        
        requestImageName = "wuwangluo"
        self.activityIndicatorView.alpha = 1
        self.activityIndicatorLab.alpha = 0
        self.contentBG.alpha = 0
        self.requestBtn.alpha = 0
        self.contentLab.alpha = 0
        self.contentImgView.alpha = 0
    }
    
//    // 可以在初始化的时候链式调用
//    @discardableResult
//    func setBackgroundColor(_ color:UIColor = #colorLiteral(red: 0.9612547589, green: 0.9591583015, blue: 0.8952967111, alpha: 1)) -> BMIndicatorView{
//        self.myMaskView.isHidden = false
//        self.myMaskView.backgroundColor = color
//        return self
//    }
    
    /// 显示等待
    public func showWait(){
        self.alpha = 1
        state = .loading
        self.activityIndicatorView.startAnimating()
        UIView.animate(withDuration: 0.15, animations: {
            self.activityIndicatorView.alpha = 1
            self.activityIndicatorLab.alpha = 1
            self.contentImgView.alpha = 0
            self.contentBG.alpha = 0
            self.requestBtn.alpha = 0
            self.contentLab.alpha = 0
        }) { (_) in
        }
    }
    
    /// 显示无数据
    public func showNoData(){
        self.alpha = 1
        state = .noData
        var imageAlpha:CGFloat = 0
        if BMIndicatorView.noDataImageName != nil{
            self.contentImgView?.image = UIImage(named: BMIndicatorView.noDataImageName!)
            contentLab.y = self.contentImgView.maxY + 10
            imageAlpha = 1
        }else{
            imageAlpha = 0
            contentLab.y = self.contentBG.h / 2 - contentLab.h/2
        }
        
        self.activityIndicatorView.stopAnimating()
        
        UIView.animate(withDuration: 0.15, animations: {
            self.contentImgView.alpha = imageAlpha
            self.activityIndicatorView.alpha = 0
            self.activityIndicatorLab.alpha = 0
            self.contentBG.alpha = 1
            self.requestBtn.alpha = 0
            self.contentLab.alpha = 1
        }) { (_) in
        }
    }
    
    /// 显示重新请求
    public func showRequest(){
        self.alpha = 1
        state = .request
        var imageAlpha:CGFloat = 0
        if requestImageName != nil  && self.h > 240{
            self.contentImgView?.image = UIImage(named: self.requestImageName!)
            imageAlpha = 1
            requestBtn.y = self.contentImgView.maxY + 10
        }else{
            imageAlpha = 0
            requestBtn.y = self.contentBG.h / 2 - requestBtn.h/2
        }
        
        self.activityIndicatorView.stopAnimating()
        UIView.animate(withDuration: 0.15, animations: {
            self.contentImgView.alpha = imageAlpha
            self.activityIndicatorView.alpha = 0
            self.activityIndicatorLab.alpha = 0
            self.contentBG.alpha = 1
            self.requestBtn.alpha = 1
            self.contentLab.alpha = 0
        }) { (_) in
        }
    }
    
    /// 隐藏
    public func hide(){
        state = .hide
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }) { (_) in
            self.activityIndicatorView?.stopAnimating()
            self.activityIndicatorLab?.alpha = 0
            self.contentBG!.alpha = 0
//            self.removeFromSuperview()
        }
    }
    override init(frame: CGRect) { super.init(frame: frame) }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

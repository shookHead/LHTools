//
//  WebVC.swift
//  wangfuAgent
//
//  Created by  on 2018/9/19.
//  Copyright © 2018 zhuanbangTec. All rights reserved.
//

import UIKit
import WebKit

open class WebVC: BaseVC ,WKNavigationDelegate{

    public var urlString :String? = nil
    
    public var htmlContent:String? = nil
    
    public var barItemColor:UIColor?

    var webView:WKWebView = {
        let web = WKWebView( frame: CGRect(x:0, y:0, width:KScreenWidth, height:KHeightInNav))
        web.backgroundColor = .KBGGray
        return web
    }()

    var progressView:UIProgressView = {
        let progress = UIProgressView(frame: CGRect(x:0, y:0, width:KScreenWidth, height:2))
        progress.progressTintColor = .green
        progress.trackTintColor = .KBGGray
        progress.alpha = 1
        return progress
    }()

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.hideNav = false
        
        self.view.addSubview(webView)
        
        self.initUI()
        
        webView.navigationDelegate = self
//        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        if urlString != nil{
            var newStr = urlString!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
            if !urlString!.contains(".html"){
                if cache[.sessionId] != nil{
                    let userId = cache[.userId]!
                    let sessionId = cache[.sessionId]!
                    if newStr.contains("?"){
                        newStr = newStr + "&" + "userId=" + userId + "&sessionId=" + sessionId
                    }else{
                        newStr = newStr + "?" + "userId=" + userId + "&sessionId=" + sessionId
                    }
                    if oemInstitutionNo != nil{
                        newStr = newStr + "&oemInstitutionNo=" + oemInstitutionNo!
                    }
                }else{
                    if oemInstitutionNo != nil{
                        if newStr.contains("?"){
                            newStr = newStr + "&oemInstitutionNo=" + oemInstitutionNo!
                        }else{
                            newStr = newStr + "?oemInstitutionNo=" + oemInstitutionNo!
                        }
                    }
                }
            }
            if let url = URL(string: newStr){
                webView.load(URLRequest(url: url))
            }
        }else{
            self.requestHtml()
        }
        
    }
    
    // 子类里实现
    open func requestHtml(){
        // 模版
//        let userId = cache[.userId]!
//        let sessionId = cache[.sessionId]!
//        var param = [String : Any]()
//        param["userId"] = userId
//        param["sessionId"] = sessionId
//        param["oemInstitutionNo"] = oemInstitutionNo
//
//        let url = BMApiSet.help_Web.urlWithHost
//        network[.help_Web].requestJson(params: param) { (html) in
//            if html != nil{
//                self.webView.loadHTMLString(html!, baseURL: URL(string: url))
//            }
//        }
    }
    
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        if self.htmlContent != nil{
//            self.webView.loadHTMLString(self.htmlContent!, baseURL: nil)
//        }else{
//            let newStr = urlString!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
//            if let url = URL(string: newStr!){
//                webView.load(URLRequest(url: url))
//            }
//        }
//    }
    
    func initUI() {
        let naviView = UIView(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: KNaviBarH))
        naviView.backgroundColor = .white
        
        if self.navigationController == nil{
            let naviView = UIView(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: KNaviBarH))
            let lab = UILabel(frame: CGRect(x: 0, y: KNaviBarH-44, width: KScreenWidth, height: 44))
            lab.text = self.title
            lab.textAlignment = .center
            lab.font = UIFont.boldSystemFont(ofSize: 16)
            naviView.addSubview(lab)
            
            let back = UIButton(frame: CGRect(x: 10, y: KNaviBarH-44, width: 50, height: 44))
            back.setImage(UIImage(named: "BMback_Icon"), for: .normal)
            back.tag = 0
            back.addTarget(self, action: #selector(WebVC.back), for: .touchUpInside)
            
            naviView.addSubview(back)
            naviView.backgroundColor = .white
            
            webView.y = KNaviBarH
            progressView.y = KNaviBarH
            
            self.view.addSubview(naviView)
        }
        
//        progressView.setProgress(0.05, animated:true)
//        self.view.addSubview(progressView)
    }

    @objc open func myBack(_ btn:UIButton){
        if btn.tag == 0{
            super.back()
        }else{
            let count = webView.backForwardList.backList.count
            print(count)
            if count >= 1{
                webView.goBack()
            }else{
                super.back()
            }
        }
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let str = navigationResponse.response.url?.absoluteString{
            print("跳转：" + str)
        }
        decisionHandler(.allow)
    }

//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        // 加载进度
//        if keyPath == "estimatedProgress" {
//            let newprogress = (change?[.newKey] as? NSNumber)!.floatValue
//            let oldprogress = (change?[.oldKey] as? NSNumber)?.floatValue ?? 0.0
//            //不要让进度条倒着走...有时候goback会出现这种情况
//            if newprogress < oldprogress { return }
//
//            if newprogress == 1 {
//                progressView.setProgress(1, animated:true)
//                UIView.animate(withDuration: 0.4, animations: {
//                    self.progressView.alpha = 0
//                }) { (_) in
//                    self.progressView.setProgress(0, animated:false)
//                }
//            }
//
//            else {
//                self.progressView.alpha = 1
//                let progress = 0.05 + 0.95 * newprogress
//                progressView.setProgress(progress, animated:true)
//            }
//        }
//    }

    deinit {
//        webView.removeObserver(self, forKeyPath:"estimatedProgress")
        webView.navigationDelegate = nil
    }
}

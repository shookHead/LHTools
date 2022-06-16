//
//  ScanVC.swift
//  wangfu2
//
//  Created by yimi on 2018/11/13.
//  Copyright © 2018 zbkj. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

open class ScanVC: BaseVC {
    
    open override var preferredStatusBarStyle: UIStatusBarStyle{
        get{ return .lightContent }
    }
    
    public var holeH = KScreenWidth * 0.7
    public var scanHoleY: CGFloat {
        return (KScreenHeight - holeH)*0.4
    }
    public var holeRect:CGRect!
    
    public var naviView:UIView = {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: KNaviBarH))
        v.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6044234155)
        
        let btn = UIButton(frame: CGRect(x: 0, y: KNaviBarH-44, width: 60, height: 44))
        let img = #imageLiteral(resourceName: "fanhui").withRenderingMode(.alwaysTemplate)
        btn.setImage(img, for: .normal)
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(back), for: .touchUpInside)
        v.addSubview(btn)
        return v
    }()
    
    public var scanView:UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight))
        view.backgroundColor = .black
        return view
    }()
    
    public var lightBtn:UIButton = {
        let btn = UIButton(frame: CGRect(x: KScreenWidth-60, y: KNaviBarH-44, width: 60, height: 44))
        let img = #imageLiteral(resourceName: "scan-light").withRenderingMode(.alwaysTemplate)
        btn.setImage(img, for: .normal)
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(openLight), for: .touchUpInside)
        return btn
    }()
    
    //扫码核心
    public var captureSession:AVCaptureSession?
    public var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    public var previewLayer:AVCaptureVideoPreviewLayer?
    public var timer:Timer?
    public var getResult:Bool = false
    
    //扫码遮挡试图
    public var blackView:UIView = {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight))
        v.backgroundColor = UIColor.maskView
        return v
    }()
    public var slideBGView :UIImageView = {
        let v = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        v.image = #imageLiteral(resourceName: "scan-bg")
        v.clipsToBounds = true
        return v
    }()
    public var sliderView :UIImageView = {
        let v = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        v.image = #imageLiteral(resourceName: "scan-slider")
        return v
    }()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.hideNav = true
        self.view.backgroundColor = .black
        self.initUI()
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == AVAuthorizationStatus.restricted || status == AVAuthorizationStatus.denied {
            lh.topMost()?.showComfirm("访问相机", "您还没有打开相机权限", okStr: "去打开", cancle: "取消", cancel: {

            }, complish: {
                ///跳往app设置
                lh.judgeAppSetting()
            })
        }
        
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //在viewDidLoad 初始化会造成卡顿
        startScaning()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.endScaning()
    }
    
    open func initUI() {
        self.view.addSubview(scanView)
        if UIDevice.current.model == "iPad" {
            let wh:CGFloat = 330
            holeRect = CGRect(x: (KScreenWidth - wh)/2, y: (KScreenHeight - wh)/2 - 30, width: wh , height: wh)
        }else{
            holeRect = CGRect(x: KScreenWidth * 0.15, y: scanHoleY, width: holeH, height: holeH)
        }
        let bezierPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight), cornerRadius: 0)
        bezierPath.append(UIBezierPath(roundedRect: holeRect, cornerRadius: 0).reversing())
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.cgPath
        blackView.layer.mask = shapeLayer
        self.view.addSubview(blackView)
        
        slideBGView.frame = holeRect
        self.view.addSubview(slideBGView)
        
        sliderView.frame = CGRect(x: 0, y: -30, width: holeH, height: 30)
        slideBGView.addSubview(sliderView)
        
        naviView.addSubview(lightBtn)
        self.view.addSubview(naviView)
    }
    
    @objc open func timeRepateAction(){
        sliderView.frame = CGRect(x: 0, y: -30, width: holeH, height: 30)
        UIView.animate(withDuration: 2-0.1) {
            self.sliderView.frame = CGRect(x: 0, y: self.holeH, width: self.holeH, height: 30)
        }
    }
    
    //返回
    @objc open override func back(){
        pop()
    }
    
    // 打开或关闭闪光灯
    @objc func openLight(){
        if lightBtn.isSelected{
            //关闭 闪光灯
            if let device = AVCaptureDevice.default(for: .video), device.hasTorch{
                do{
                    try device.lockForConfiguration()
                    device.torchMode = .off
                    device.unlockForConfiguration()
                }catch{ return }
            }
            lightBtn.isSelected = false
        }else{
            if let device = AVCaptureDevice.default(for: .video), device.hasTorch{
                do{
                    try device.lockForConfiguration()
                    device.torchMode = .on
                    device.unlockForConfiguration()
                }catch{
                    print(error)
                    Hud.showText("闪光灯无法打开")
                    return
                }
            }else{
                Hud.showText("当前设备识别不到闪光灯")
                return
            }
            lightBtn.isSelected = true
        }
    }
    
    //开启摄像头
    public func startScaning(){
        if let device = AVCaptureDevice.default(for: .video){
            do {
                let input = try AVCaptureDeviceInput(device: device)
                captureSession = AVCaptureSession()
                captureSession?.addInput(input)
            }catch{
                //                WFPermissionType.capture.showAlert()
                return
            }
            let output = AVCaptureMetadataOutput()
            captureSession?.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            output.metadataObjectTypes = [.qr,.ean13,.code128]
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            previewLayer?.frame = view.layer.bounds
            scanView.layer.addSublayer(previewLayer!)
            
            if UIDevice.current.model == "iPad" {
                
//                let orientation = UIApplication.shared.statusBarOrientation
                let orientation = UIDevice.current.orientation
                let stuckview = previewLayer
                if let layerRect = previewLayer?.bounds{
                    switch orientation {
                    case .landscapeLeft:
                        stuckview?.setAffineTransform(CGAffineTransform(rotationAngle: M_PI + M_PI_2))// 270 degrees
                        stuckview?.bounds = CGRect(x: 0, y: 0, width: layerRect.size.height ?? 0, height: layerRect.size.width ?? 0)
                        print("1")
                    case .landscapeRight:
                        stuckview?.setAffineTransform(CGAffineTransform(rotationAngle: M_PI_2))// 90 degrees
                        stuckview?.bounds = CGRect(x: 0, y: 0, width: layerRect.size.height ?? 0, height: layerRect.size.width ?? 0)
                        print("2")
                    case .portraitUpsideDown:
                        stuckview?.setAffineTransform(CGAffineTransform(rotationAngle: M_PI))// 180 degrees
                        stuckview?.bounds = layerRect
                        print("3")
                    default:
                        stuckview?.setAffineTransform(CGAffineTransform(rotationAngle: 0.0))
                        stuckview?.bounds = layerRect
                        print("4")
                    }
                    stuckview?.position = CGPoint(x: layerRect.midX, y: layerRect.midY)
                }
            }
            captureSession?.startRunning()
            
            timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(timeRepateAction), userInfo: nil, repeats: true)
            timeRepateAction()
            
            getResult = false
        }
    }
    
    //关闭摄像头
    public func endScaning(){
        captureSession?.stopRunning()
        captureSession = nil
        timer?.invalidate()
        timer = nil
    }
    
    // 拿到扫描内容 重写
    open func receiveScanCode(_ code:String?){
        print(code ?? "")
    }
}

extension ScanVC:AVCaptureMetadataOutputObjectsDelegate{
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if getResult == true{
            return
        }
        
        getResult = true
        self.endScaning()
        
        // 取出第一个metadata
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if metadataObj.type == .qr || metadataObj.type == .ean13 || metadataObj.type == .code128 {
            if metadataObj.stringValue != nil {
                self.receiveScanCode(metadataObj.stringValue)
            }
        }else{
            Hud.showText("二维码识别异常，请重新扫描")
            Hud.runAfterHud {
                self.getResult = false
            }
        }
    }
}


//
//  QRCodeManager.swift
//  wenzhuanMerchants
//
//  Created by zbkj on 2020/7/7.
//  Copyright © 2020 baymax. All rights reserved.
//

import Foundation
import UIKit

public class QRCodeManager: NSObject {

    public class func createQRCode(_ qrCode:String!, _ size :CGFloat, handle:@escaping (UIImage)->()){
        
        if qrCode == nil{
            return
        }
        
        DispatchQueue.global().async {
            //1.创建滤镜
            let filter = CIFilter(name: "CIQRCodeGenerator")
            filter?.setDefaults()
            //3设置需要生产二维码的数据到滤镜中
            filter?.setValue(qrCode.data(using: .utf8), forKey: "inputMessage")
            guard let image = filter?.outputImage else { return }
            
            
            //缩放
            let ciextent: CGRect = image.extent.integral
            let scale: CGFloat = min(size/ciextent.width, size/ciextent.height)
            let context = CIContext(options: nil)  //创建基于GPU的CIContext对象,性能和效果更好
            let bitmapImage: CGImage = context.createCGImage(image, from: ciextent)! //CIImage->CGImage
            let width = ciextent.width * scale
            let height = ciextent.height * scale
            let cs: CGColorSpace = CGColorSpaceCreateDeviceGray() //灰度颜色通道
            let info_UInt32 = CGImageAlphaInfo.none.rawValue
            let bitmapRef = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: info_UInt32)! //图形上下文，画布
            bitmapRef.interpolationQuality = CGInterpolationQuality.none //写入质量
            bitmapRef.scaleBy(x: scale, y: scale) //调整“画布”的缩放
            bitmapRef.draw(bitmapImage, in: ciextent)  //绘制图片
            let scaledImage: CGImage = bitmapRef.makeImage()! //保存
            let img = UIImage(cgImage: scaledImage)
            DispatchQueue.main.async {
                handle(img)
            }
        }
    }
    
    /// 将二维码画到台卡上
    public class func createQRCodeWithBGImage(bgImg:String, loc:CGRect, _ qrCode:String!, handle:@escaping (UIImage)->()){
        if qrCode == nil{
            return
        }
        
        DispatchQueue.global().async {
            //1.创建滤镜
            let filter = CIFilter(name: "CIQRCodeGenerator")
            filter?.setDefaults()
            //3设置需要生产二维码的数据到滤镜中
            filter?.setValue(qrCode.data(using: .utf8), forKey: "inputMessage")
            guard let image = filter?.outputImage else { return }
            
            
            //缩放
            let ciextent: CGRect = image.extent.integral
            let context = CIContext(options: nil)  //创建基于GPU的CIContext对象,性能和效果更好
            let bitmapImage: CGImage = context.createCGImage(image, from: ciextent)! //CIImage->CGImage
            let qrImage = UIImage.init(cgImage: bitmapImage, scale: 0.1, orientation: .up)
            
            //合并
            let bgImage = UIImage(named: bgImg)!
            let bgSize = bgImage.size
            UIGraphicsBeginImageContext(bgSize)
            UIGraphicsGetCurrentContext()?.interpolationQuality = .none //设置缩放质量 不失真的放大二维码
            bgImage.draw(in: CGRect(origin: CGPoint.zero, size: bgSize))
            qrImage.draw(in: loc)
            //取出绘制好的图片
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            //返回合成好的图片
            DispatchQueue.main.async {
                handle(newImage!)
            }
        }
    }
    
}



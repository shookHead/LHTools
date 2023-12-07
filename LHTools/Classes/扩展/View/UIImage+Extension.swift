//
//  UIImage+Extension.swift
//  QianRuChao
//
//  Created by 蔡林海 on 2020/1/17.
//  Copyright © 2020 蔡林海. All rights reserved.
//

import Foundation
import UIKit

extension UIImage{
    
    // 选择图片的时候，直接用.name("")
    // 例如 imgView.image = .name("123")
    public class func name(_ name:String) -> UIImage? {
        return UIImage(named: name)
    }
    
    ///裁剪图片为圆形
    public func circleImage() -> UIImage {
        //取最短边长
        let shotest = min(self.size.width, self.size.height)
        //输出尺寸
        let outputRect = CGRect(x: 0, y: 0, width: shotest, height: shotest)
        //开始图片处理上下文（由于输出的图不会进行缩放，所以缩放因子等于屏幕的scale即可）
        UIGraphicsBeginImageContextWithOptions(outputRect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()!
        //添加圆形裁剪区域
        context.addEllipse(in: outputRect)
        context.clip()
        //绘制图片
        self.draw(in: CGRect(x: (shotest-self.size.width)/2,
                             y: (shotest-self.size.height)/2,
                             width: self.size.width,
                             height: self.size.height))
        //获得处理后的图片
        let maskedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return maskedImage
    }
    /// 修复图片旋转
    public func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
        
        var transform = CGAffineTransform.identity
        
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            break
            
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
            
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
            
        default:
            break
        }
        
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
            
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
            
        default:
            break
        }
        
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
        
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
            break
            
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
            break
        }
        
        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)
        
        return img
    }
    // MARK: 裁剪给定区域
    /// 裁剪给定区域
    /// - Parameter crop: 裁剪区域
    /// - Returns: 剪裁后的图片
    public func cropWithCropRect( _ crop: CGRect) -> UIImage? {
        let cropRect = CGRect(x: crop.origin.x * self.scale, y: crop.origin.y * self.scale, width: crop.size.width * self.scale, height: crop.size.height *  self.scale)
        if cropRect.size.width <= 0 || cropRect.size.height <= 0 {
            return nil
        }
        var image:UIImage?
        autoreleasepool{
            let imageRef: CGImage?  = self.cgImage!.cropping(to: cropRect)
            if let imageRef = imageRef {
                image = UIImage(cgImage: imageRef)
            }
        }
        return image
    }
    
    // MARK: 给图片添加文字水印
    /// 给图片添加文字水印
    /// - Parameters:
    ///   - drawTextframe: 水印的 frame
    ///   - drawText: 水印文字
    ///   - withAttributes: 水印富文本
    /// - Returns: 返回水印图片
    public func addTextInImage(drawTextframe: CGRect, drawText: String, withAttributes: [NSAttributedString.Key : Any]? = nil) -> UIImage? {
        // 开启图片上下文
        UIGraphicsBeginImageContext(size)
        // 图形重绘
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        // 水印文字属性
        let attributes = withAttributes
        // 水印文字和大小
        let text = NSString(string: drawText)
        // 获取富文本的 size
        // let size = text.size(withAttributes: attributes)
        // 绘制文字
        text.draw(in: drawTextframe, withAttributes: attributes)
        // 从当前上下文获取图片
        let image = UIGraphicsGetImageFromCurrentImageContext()
        // 关闭上下文
        UIGraphicsEndImageContext()
        return image
    }
    
    // MARK: 添加图片水印
    /// 添加图片水印
    /// - Parameters:
    ///   - rect: 水印图片的位置
    ///   - image: 水印图片
    /// - Returns: 带有水印的图片
    public func addImageWatermark(rect: CGRect, image: UIImage) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        draw(in: CGRect.init(x: 0, y: 0, width: size.width, height: size.height))
        image.draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    /// 保存图片到相册
    public func saveToPhotoAlbum() {
        UIImageWriteToSavedPhotosAlbum(self, self, #selector(saveImage(image:didFinishSavingWithError:contextInfo:)), nil)
    }
    @objc public func saveImage(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        if error == nil {
            Hud.showText(lhSuccessfullySaved)
            return
        }
        let _ = lh.judgeAlbumPower()
    }
    ///生成带渐变色的图片
    public static func gradientImageWithBounds(bounds: CGRect, colors: [CGColor]) -> UIImage {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        if let context = UIGraphicsGetCurrentContext() {
            gradientLayer.render(in: context )
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image!
            
        }
        return UIImage()
    }
    /// 循环压缩
    /// - Parameter maxSize: 最大数据大小
    /// - Returns: 压缩后数据
    public func cycleCompressDataSize(maxSize: Int) -> Data? {
        guard let oldData = self.pngData() else { return nil }
        if oldData.count < maxSize {
            return oldData
        }
        var compress: CGFloat = 0.9
        guard var data = self.jpegData(compressionQuality: compress) else { return nil }
        while data.count > maxSize && compress > 0.01 {
            compress -= 0.02
            data = self.jpegData(compressionQuality: compress)!
        }
        return data
    }
}

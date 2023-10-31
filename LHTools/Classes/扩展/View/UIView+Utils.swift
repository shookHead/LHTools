//
//  UIView+Utils.swift
//  aaaaaa
//
//  Created by 蔡林海 on 2021/2/19.
//

import UIKit

/// 默认渐变时间
public var UIViewDefaultFadeDuration: TimeInterval = 0.4
extension UIView{
    public enum DirectionType {
        ///上往下
        case horizontal
        ///左往右
        case vertical
        ///左上往右下
        case tiltDown
    }
    ///生成图片
    public func toImage() -> UIImage?{
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, UIScreen.main.scale)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    public func toSnapshot(atFrame:CGRect) -> UIImage? {
        if atFrame == CGRect.zero { return nil }
        UIGraphicsBeginImageContextWithOptions(CGSize.init(width: atFrame.maxX, height: atFrame.maxY), false, 0)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        //            view.layer.render(in: UIGraphicsGetCurrentContext()!)
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if atFrame.origin.x > 0 || atFrame.origin.y > 0 { // 剪切图片
            let imageRef = image?.cgImage
            if let subImgRef = imageRef?.cropping(to: atFrame){
                image = UIImage.init(cgImage: subImgRef)
            }
        }
        return image
    }
    ///删除一个view 下的所有子view
    public func clearAll(){
        if self.subviews.count > 0 {
            self.subviews.forEach({ $0.removeFromSuperview()})
        }
    }
    ///自定义控件圆角位置 如：只左上 左下有圆角[.topLeft,.bottomLeft,.bottomLeft,.bottomRight]
    public func addCorner(roundingCorners: UIRectCorner, cornerSize: CGSize) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: roundingCorners, cornerRadii: cornerSize)
        let cornerLayer = CAShapeLayer()
        cornerLayer.frame = bounds
        cornerLayer.path = path.cgPath
        layer.mask = cornerLayer
    }
    ///设置控件渐变
    public func lh_addGradientLayer(gradientColors: [UIColor],gradientDirection direction: DirectionType = .vertical, gradientFrame: CGRect? = nil) {
        //创建并实例化CAGradientLayer
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        //设置frame和插入view的layer
        if let gradientFrame = gradientFrame {
            gradientLayer.frame = gradientFrame
        }else {
            gradientLayer.frame = CGRect(x: 0, y: 0, width: w, height: h)
        }
        gradientLayer.colors = gradientColors.map({ (color) -> CGColor in
            return color.cgColor
        })
        //(这里的起始和终止位置就是按照坐标系,四个角分别是左上(0,0),左下(0,1),右上(1,0),右下(1,1))
        if direction == .vertical {
            gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint.init(x: 1, y: 0)
        }else if direction == .horizontal {
            gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint.init(x: 0, y: 1)
        }else{
            gradientLayer.startPoint = CGPoint(x:0, y:0)
            gradientLayer.endPoint = CGPoint(x:1, y:1)
        }
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    // MARK:平面旋转
    /// 平面旋转
    /// - Parameters:
    ///   - angle: 旋转多少度
    ///   - isInverted: 顺时针还是逆时针，默认是顺时针
    public func setRotation(_ angle: CGFloat, isInverted: Bool = false) {
        self.transform = isInverted ? CGAffineTransform(rotationAngle: angle).inverted() : CGAffineTransform(rotationAngle: angle)
    }
    // MARK: 沿 X、Y、Z 轴方向同时旋转多少度(3D旋转)
    /// 沿 X、Y、Z 轴方向同时旋转多少度(3D旋转)
    /// - Parameters:
    ///   - xAngle: x 轴的角度，旋转的角度，为弧度制 0-2π
    ///   - yAngle: y 轴的角度，旋转的角度，为弧度制 0-2π
    ///   - zAngle: z 轴的角度，旋转的角度，为弧度制 0-2π
    public func setRotation(xAngle: CGFloat, yAngle: CGFloat, zAngle: CGFloat) {
        var transform = CATransform3DIdentity
        transform.m34 = 1.0 / -1000.0
        transform = CATransform3DRotate(transform, xAngle, 1.0, 0.0, 0.0)
        transform = CATransform3DRotate(transform, yAngle, 0.0, 1.0, 0.0)
        transform = CATransform3DRotate(transform, zAngle, 0.0, 0.0, 1.0)
        self.layer.transform = transform
    }
    // MARK: 设置 x,y 缩放
    /// 设置 x,y 缩放
    /// - Parameters:
    ///   - x: x 放大的倍数
    ///   - y: y 放大的倍数
    public func setScale(x: CGFloat, y: CGFloat) {
        var transform = CATransform3DIdentity
        transform.m34 = 1.0 / -1000.0
        transform = CATransform3DScale(transform, x, y, 1)
        self.layer.transform = transform
    }
    //MARK:淡入淡出
    /// 淡入
    /// - Parameters:
    ///   - duration: 时间
    ///   - delay: 延迟多久淡入
    ///   - completion: 完成
    public func fadeIn(_ duration: TimeInterval? = UIViewDefaultFadeDuration, delay: TimeInterval? = 0.0, completion: ((Bool) -> Void)? = nil) {
        fadeTo(1.0, duration: duration, delay: delay, completion: completion)
    }
    /// 淡出
    /// - Parameters:
    ///   - duration: 时间
    ///   - delay: 延迟多久淡出
    ///   - completion: 完成
    public func fadeOut(_ duration: TimeInterval? = UIViewDefaultFadeDuration, delay: TimeInterval? = 0.0, completion: ((Bool) -> Void)? = nil) {
        fadeTo(0.0, duration: duration, delay: delay, completion: completion)
    }
    /// 淡入淡出
    public func fadeTo(_ value: CGFloat, duration: TimeInterval? = UIViewDefaultFadeDuration, delay: TimeInterval? = 0.0, completion: ((Bool) -> Void)? = nil) {
        alpha = value == 1 ? 0:1
        UIView.animate(withDuration: duration ?? UIViewDefaultFadeDuration, delay: delay ?? UIViewDefaultFadeDuration, options: .curveEaseInOut, animations: {
            self.alpha = value
        }, completion: completion)
    }

}

//MARK: - 实现圆角、阴影和边框共存
extension UIView{
    /// 无边框阴影
    /// - Parameters:
    ///   - backgroundColor: 背景颜色
    ///   - shadowColor: 阴影颜色
    ///   - shadowOffset: 阴影偏移范围
    ///   - shadowOpacity: 阴影透明度
    ///   - shadowRadius: 阴影半径
    ///   - cornerRadius: 控件半径
    public func setViewShadow(backgroundColor:UIColor,shadowColor:CGColor,shadowOffset:CGSize,shadowOpacity:Float,shadowRadius:CGFloat,cornerRadius:CGFloat) {
        let curView = self
        curView.backgroundColor = backgroundColor
        curView.layer.shadowColor = shadowColor
        curView.layer.shadowOffset = shadowOffset
        curView.layer.shadowOpacity = shadowOpacity
        curView.layer.shadowRadius = shadowRadius
        curView.layer.cornerRadius = cornerRadius
    }
    /// 渐变背景色+圆角阴影
    /// - Parameters:
    ///   - colors: 渐变背景色数组
    ///   - locations: 渐变从哪里到哪里[0,1]
    ///   - direction: 渐变方向
    ///   - shadowColor: 阴影颜色
    ///   - shadowOffset: 阴影偏移范围
    ///   - shadowOpacity: 阴影透明度
    ///   - shadowRadius: 阴影半径
    ///   - cornerRadius: 控件半径
    public func setViewColorShadow(colors:[UIColor],locations:[CGFloat]?,direction:DirectionType = .vertical,shadowColor:CGColor,shadowOffset:CGSize,shadowOpacity:Float,shadowRadius:CGFloat,cornerRadius:CGFloat) {
        let curView = self
        //设置渐变色
        let gradient = CAGradientLayer()
        gradient.colors = colors.map(\.cgColor)
        gradient.locations = locations?.map { NSNumber(value: Double($0)) }
        gradient.frame = curView.bounds
        //(这里的起始和终止位置就是按照坐标系,四个角分别是左上(0,0),左下(0,1),右上(1,0),右下(1,1))
        if direction == .vertical {
            gradient.startPoint = CGPoint.init(x: 0, y: 0)
            gradient.endPoint = CGPoint.init(x: 1, y: 0)
        }else if direction == .horizontal {
            gradient.startPoint = CGPoint.init(x: 0, y: 0)
            gradient.endPoint = CGPoint.init(x: 0, y: 1)
        }else{
            gradient.startPoint = CGPoint(x:0, y:0)
            gradient.endPoint = CGPoint(x:1, y:1)
        }
//        gradient.startPoint = startPoint
//        gradient.endPoint = endPoint
        //圆角阴影设置
        gradient.shadowColor = shadowColor
        gradient.shadowOffset = shadowOffset
        gradient.shadowOpacity = shadowOpacity
        gradient.shadowRadius = shadowRadius
        gradient.cornerRadius = cornerRadius
        curView.layer.addSublayer(gradient)
    }
    /// 边框圆角阴影
    /// - Parameters:
    ///   - backgroundColor: 背景颜色
    ///   - shadowColor: 阴影颜色
    ///   - shadowOffset: 阴影偏移范围
    ///   - shadowOpacity: 阴影透明度
    ///   - shadowRadius: 阴影半径
    ///   - borderWidth: 控件边框宽度
    ///   - borderColor: 控件边框颜色
    ///   - cornerRadius: 控件半径
    public func setViewBorderShadow(backgroundColor:UIColor,shadowColor:CGColor,shadowOffset:CGSize,shadowOpacity:Float,shadowRadius:CGFloat,borderWidth:CGFloat,borderColor:CGColor,cornerRadius:CGFloat) {
        let curView = self
        curView.backgroundColor = backgroundColor
        curView.layer.shadowColor = shadowColor
        curView.layer.shadowOffset = shadowOffset
        curView.layer.shadowOpacity = shadowOpacity
        curView.layer.shadowRadius = shadowRadius
        curView.layer.borderWidth = borderWidth
        curView.layer.borderColor = borderColor
        curView.layer.cornerRadius = cornerRadius
    }
}
//MARK: - 晃动
public extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "transform.rotation.z"
        animation.values = [(-2.0 / 180 * .pi), (2.0 / 180 * .pi), (-2.0 / 180 * .pi)]
        animation.duration = 0.5
        animation.repeatCount = MAXFLOAT
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        layer.add(animation, forKey: "swifty_shake")
    }
}
public extension UIView {
    //是否在当前页面显示
    var isVisible: Bool {
        if let window = UIApplication.shared.keyWindow {
            let viewFrame = convert(bounds, to: window)
            let intersects = viewFrame.intersects(window.bounds)
            return !isHidden && alpha > 0 && window == self.window && intersects
        }
        return false
    }
}

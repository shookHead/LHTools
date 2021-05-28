//
//  MBProgressHud.swift
//  BaseUtilsDemo
//
//  Created by yimi on 2019/8/20.
//  Copyright © 2019 yimi. All rights reserved.
//

import Foundation
import UIKit

//MARK: - Extension UIView
extension UIView {
    func updateUI() {
        DispatchQueue.main.async { () -> Void in
            self.setNeedsLayout()
            self.setNeedsDisplay()
        }
    }
}

//MARK: - MBProgressHUDDelegate
@objc protocol MBProgressHUDDelegate {
    @objc optional func hudWasHidden(_ hud: MBProgressHUD)
}

//MARK: - ENUM
enum MBProgressHUDMode: Int {
    case indeterminate = 0
    case annularIndeterminate   //
    case determinate
    case determinateHorizontalBar
    case annularDeterminate
    case customView
    case text
}

enum MBProgressHUDAnimation: Int {
    case fade = 0
    case zoom
    case zoomOut
    case zoomIn
}

//MARK: - Global var and func
typealias MBProgressHUDCompletionBlock = () -> Void
typealias MBProgressHUDExecutionClosures = () -> Void

let kPadding: CGFloat = 4.0
let kLabelFontSize: CGFloat = 16.0
let kDetailsLabelFontSize: CGFloat = 12.0

func MB_TEXTSIZE(_ text: String?, font: UIFont) -> CGSize {
    guard let textTemp = text, textTemp.count > 0 else {
        return CGSize.zero
    }
    return textTemp.size(withAttributes: [NSAttributedString.Key.font: font])
}

func MB_MULTILINE_TEXTSIZE(_ text: String?, font: UIFont, maxSize: CGSize, mode: NSLineBreakMode) -> CGSize {
    guard let textTemp = text, textTemp.count > 0 else {
        return CGSize.zero
    }
    
    return textTemp.boundingRect(with: maxSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil).size
}

//MARK: - MBProgressHUD
class MBProgressHUD: UIView {
    fileprivate var useAnimation: Bool = true
    fileprivate var closureForExecution: MBProgressHUDExecutionClosures?
    fileprivate var label: UILabel!
    fileprivate var detailsLabel: UILabel!
    fileprivate var rotationTransform: CGAffineTransform = CGAffineTransform.identity
    
    fileprivate var indicator: UIView?
    fileprivate var graceTimer: Timer?
    fileprivate var minShowTimer: Timer?
    fileprivate var showStarted: Date?
    
    var customView: UIView? {
        didSet {
            self.updateIndicators()
            self.updateUI()
        }
    }
    
    var animationType = MBProgressHUDAnimation.fade
    var mode = MBProgressHUDMode.indeterminate {
        didSet {
            self.updateIndicators()
            self.updateUI()
        }
    }
    var labelText: String? {
        didSet {
            label.text = labelText
            self.updateUI()
        }
    }
    var detailsLabelText: String? {
        didSet {
            detailsLabel.text = detailsLabelText
            self.updateUI()
        }
    }
    var opacity = 0.8
    var color: UIColor?
    var labelFont = UIFont.boldSystemFont(ofSize: kLabelFontSize) {
        didSet {
            label.font = labelFont
            self.updateUI()
        }
    }
    var labelColor = UIColor.white {
        didSet {
            label.textColor = labelColor
            self.updateUI()
        }
    }
    var detailsLabelFont = UIFont.boldSystemFont(ofSize: kDetailsLabelFontSize) {
        didSet {
            detailsLabel.font = detailsLabelFont
            self.updateUI()
        }
    }
    var detailsLabelColor = UIColor.white {
        didSet {
            detailsLabel.textColor = detailsLabelColor
            self.updateUI()
        }
    }
    var activityIndicatorColor = UIColor.white {
        didSet {
            self.updateIndicators()
            self.updateUI()
        }
    }
    var xOffset = 0.0
    var yOffset = 0.0
    var dimBackground = false
    var margin = 20.0
    var cornerRadius_ = 10.0
    var graceTime = 0.0
    var minShowTime = 0.0
    var removeFromSuperViewOnHide = false
    var minSize: CGSize = CGSize.zero
    var square = false
    var size: CGSize = CGSize.zero
    
    var taskInprogress = false
    
    var progress: Float = 0.0 {
        didSet {
            indicator?.setValue(progress, forKey: "progress")
        }
    }
    
    var completionBlock: MBProgressHUDCompletionBlock?
    
    var delegate: MBProgressHUDDelegate?
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentMode = UIView.ContentMode.center
        self.autoresizingMask = [UIView.AutoresizingMask.flexibleTopMargin, UIView.AutoresizingMask.flexibleBottomMargin, UIView.AutoresizingMask.flexibleLeftMargin, UIView.AutoresizingMask.flexibleRightMargin]
        self.isOpaque = false
        self.backgroundColor = UIColor.clear
        self.alpha = 0.0
        
        self.setupLabels()
        self.updateIndicators()
    }
    
    convenience init(view: UIView?) {
        assert(view != nil, "View must not be nil.")
        
        self.init(frame: view!.bounds)
    }
    
    convenience init(window: UIWindow) {
        self.init(view: window)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.unregisterFromNotifications()
    }
    
    // MARK: - Show & Hide
    func show(_ animated: Bool) {
        assert(Thread.isMainThread, "MBProgressHUD needs to be accessed on the main thread.")
        useAnimation = animated
        if graceTime > 0.0 {
            let newGraceTimer: Timer = Timer(timeInterval: graceTime, target: self, selector: #selector(handleGraceTimer), userInfo: nil, repeats: false)
            RunLoop.current.add(newGraceTimer, forMode: RunLoop.Mode.common)
            graceTimer = newGraceTimer
        }
            // ... otherwise show the HUD imediately
        else {
            self.showUsingAnimation(useAnimation)
        }
    }
    
    func hide(_ animated: Bool) {
        assert(Thread.isMainThread, "MBProgressHUD needs to be accessed on the main thread.")
        useAnimation = animated
        // If the minShow time is set, calculate how long the hud was shown,
        // and pospone the hiding operation if necessary
        if let showStarted = showStarted, minShowTime > 0.0 {
            let interv: TimeInterval = Date().timeIntervalSince(showStarted)
            guard interv >= minShowTime else {
                minShowTimer = Timer(timeInterval: minShowTime - interv, target: self, selector:#selector(handleMinShowTimer) , userInfo: nil, repeats: false)
                return
            }
        }
        // ... otherwise hide the HUD immediately
        self.hideUsingAnimation(useAnimation)
    }
    
    func hide(_ animated: Bool, afterDelay delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            self.hideDelayed(animated)
        }
    }
    
    func hideDelayed(_ animated: Bool) {
        self.hide(animated)
    }
    
    // MARK: - Timer callbacks
    @objc func handleGraceTimer(_ theTimer: Timer) {
        // Show the HUD only if the task is still running
        if taskInprogress {
            self.showUsingAnimation(useAnimation)
        }
    }
    
    @objc fileprivate func handleMinShowTimer(_ theTimer: Timer) {
        self.hideUsingAnimation(useAnimation)
    }
    
    // MARK: - View Hierrarchy
    override func didMoveToSuperview() {
        self.updateForCurrentOrientationAnimaged(false)
    }
    
    // MARK: -  Internal show & hide operations
    fileprivate func showUsingAnimation(_ animated: Bool) {
        // Cancel any scheduled hideDelayed: calls
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.setNeedsDisplay()
        
        if animated && animationType == .zoomIn {
            self.transform = rotationTransform.concatenating(CGAffineTransform(scaleX: 0.5, y: 0.5))
        } else if animated && animationType == .zoomOut {
            self.transform = rotationTransform.concatenating(CGAffineTransform(scaleX: 1.5, y: 1.5))
        }
        self.showStarted = Date()
        //Fade in
        if animated {
            UIView.animate(withDuration: 0.30) {
                self.alpha = 1.0
                if self.animationType == .zoomIn || self.animationType == .zoomOut {
                    self.transform = self.rotationTransform
                }
            } completion: { (_) in
            }
        } else {
            self.alpha = 1.0
        }
    }
    
    fileprivate func hideUsingAnimation(_ animated: Bool) {
        // Fade out
        if animated && showStarted != nil {
            
            UIView.animate(withDuration: 0.30) {
                if self.animationType == .zoomIn {
                    self.transform = self.rotationTransform.concatenating(CGAffineTransform(scaleX: 1.5, y: 1.5))
                } else if self.animationType == .zoomOut {
                    self.transform = self.rotationTransform.concatenating(CGAffineTransform(scaleX: 0.5, y: 0.5))
                }
                self.alpha = 0.02
            } completion: { (_) in
                self.done()
            }
        } else {
            self.alpha = 0.0
            self.done()
        }
        self.showStarted = nil
    }
    
    fileprivate func done() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        self.alpha = 0.0
        if removeFromSuperViewOnHide {
            self.removeFromSuperview()
        }
        
        if completionBlock != nil {
            self.completionBlock!()
            self.completionBlock = nil
        }
        
        delegate?.hudWasHidden?(self)
    }
    
    // MARK: - Threading
    func showWhileExecuting(_ closures: @escaping MBProgressHUDExecutionClosures, animated: Bool) {
        // Launch execution in new thread
        taskInprogress = true
        closureForExecution = closures
        
        Thread.detachNewThreadSelector(#selector(launchExecution), toTarget: self, with: nil)
        
        // Show HUD view
        self.show(animated)
    }
    
    func showAnimated(_ animated: Bool, whileExecutingBlock block: @escaping ()->()) {
        self.showAnimated(animated, whileExecutingBlock: block, onQueue: DispatchQueue.global(), completionBlock: nil)
    }
    
    func showAnimated(_ animated: Bool, whileExecutingBlock block: @escaping ()->(), completionBlock completion: MBProgressHUDCompletionBlock?) {
        self.showAnimated(animated, whileExecutingBlock: block, onQueue: DispatchQueue.global(), completionBlock: completion)
    }
    
    func showAnimated(_ animated: Bool, whileExecutingBlock block: @escaping ()->(), onQueue queue: DispatchQueue) {
        self.showAnimated(animated, whileExecutingBlock: block, onQueue: queue, completionBlock: nil)
    }
    
    func showAnimated(_ animated: Bool, whileExecutingBlock block: @escaping ()->(), onQueue queue: DispatchQueue, completionBlock completion: MBProgressHUDCompletionBlock?) {
        taskInprogress = true
        self.completionBlock = completion
        queue.async(execute: { () -> Void in
            block()
            DispatchQueue.main.async(execute: { () -> Void in
                self.cleanUp()
            })
        })
        self.show(animated)
    }
    
    @objc func launchExecution() {
        autoreleasepool { () -> () in
            closureForExecution!()
            DispatchQueue.main.async(execute: { () -> Void in
                self.cleanUp()
            })
        }
    }
    
    func cleanUp() {
        taskInprogress = false
        closureForExecution = nil
        
        self.hide(useAnimation)
    }
    
    // MARK: - UI
    fileprivate func setupLabels() {
        label = UILabel(frame: self.bounds)
        label.adjustsFontSizeToFitWidth = false
        label.textAlignment = NSTextAlignment.center
        label.isOpaque = false
        label.backgroundColor = UIColor.clear
        label.textColor = labelColor
        label.font = labelFont
        label.text = labelText
        self.addSubview(label)
        
        detailsLabel = UILabel(frame: self.bounds)
        detailsLabel.font = detailsLabelFont
        detailsLabel.adjustsFontSizeToFitWidth = false
        detailsLabel.textAlignment = NSTextAlignment.center
        detailsLabel.isOpaque = false
        detailsLabel.backgroundColor = UIColor.clear
        detailsLabel.textColor = detailsLabelColor
        detailsLabel.numberOfLines = 0
        detailsLabel.font = detailsLabelFont
        detailsLabel.text = detailsLabelText
        self.addSubview(detailsLabel)
    }
    
    fileprivate func updateIndicators() {
        let isActivityIndicator: Bool = self.indicator is UIActivityIndicatorView
        let isRoundIndicator: Bool = self.indicator is MBRoundProgressView
        let isIndeterminatedRoundIndicator: Bool = self.indicator is MBIndeterminatedRoundProgressView
        
        switch self.mode {
        case .indeterminate:
            
            var activityIndicator:UIActivityIndicatorView
            if isActivityIndicator == false{
                if #available(iOS 13.0, *) {
                    activityIndicator = UIActivityIndicatorView(style: .large)
                } else {
                    activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
                }
            }else{
                activityIndicator = self.indicator as! UIActivityIndicatorView
            }
            
            if !isActivityIndicator {
                self.indicator?.removeFromSuperview()
                self.indicator = activityIndicator
                
                activityIndicator.startAnimating()
                self.addSubview(activityIndicator)
            }
            activityIndicator.color = activityIndicatorColor
            
        case .annularIndeterminate:
            if !isIndeterminatedRoundIndicator {
                self.indicator?.removeFromSuperview()
                self.indicator = MBIndeterminatedRoundProgressView()
                self.addSubview(self.indicator!)
            }
            
        case .determinateHorizontalBar:
            self.indicator?.removeFromSuperview()
            self.indicator = MBBarProgressView()
            self.addSubview(self.indicator!)
            
        case .determinate:
            fallthrough
            
        case .annularDeterminate:
            if !isRoundIndicator {
                self.indicator?.removeFromSuperview()
                self.indicator = MBRoundProgressView()
                self.addSubview(self.indicator!)
            }
            
            if self.mode == MBProgressHUDMode.annularDeterminate {
                (self.indicator as! MBRoundProgressView).annular = true
            }
            
        case .customView where self.customView != self.indicator:
            self.indicator?.removeFromSuperview()
            self.indicator = self.customView
            self.addSubview(self.indicator!)
            
        case .text:
            self.indicator?.removeFromSuperview()
            self.indicator = nil
            
        default:
            break
        }
    }
    
    // MARK: - Notificaiton
    fileprivate func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(statusBarOrientationDidChange), name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
    }
    
    fileprivate func unregisterFromNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
    }
    
    @objc func statusBarOrientationDidChange(_ notification: Notification) {
        if let _ = self.superview {
            self.updateForCurrentOrientationAnimaged(true)
        }
    }
    
    fileprivate func updateForCurrentOrientationAnimaged(_ animated: Bool) {
        // Stay in sync with the superview in any case
        if let superView = self.superview {
            self.bounds = superView.bounds
            self.setNeedsDisplay()
        }
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Entirely cover the parent view
        if let parent = self.superview {
            self.frame = parent.bounds
        }
        let bounds: CGRect = self.bounds
        
        // Determine the total widt and height needed
        let maxWidth: CGFloat = bounds.size.width - 4 * CGFloat(margin)
        var totalSize: CGSize = CGSize.zero
        
        
        var indicatorF: CGRect = ((indicator != nil) ? indicator!.bounds : CGRect.zero)
        indicatorF.size.width = min(indicatorF.size.width, maxWidth)
        totalSize.width = max(totalSize.width, indicatorF.size.width)
        totalSize.height += indicatorF.size.height
        
        var labelSize: CGSize = MB_TEXTSIZE(label.text, font: label.font)
        labelSize.width = min(labelSize.width, maxWidth)
        totalSize.width = max(totalSize.width, labelSize.width)
        totalSize.height += labelSize.height
        if labelSize.height > 0.0 && indicatorF.size.height > 0.0 {
            totalSize.height += kPadding
        }
        
        let remainingHeight: CGFloat = bounds.size.height - totalSize.height - kPadding - 4 * CGFloat(margin)
        let maxSize: CGSize = CGSize(width: maxWidth, height: remainingHeight)
        let detailsLabelSize: CGSize = MB_MULTILINE_TEXTSIZE(detailsLabel.text, font: detailsLabel.font, maxSize: maxSize, mode: detailsLabel.lineBreakMode)
        totalSize.width = max(totalSize.width, detailsLabelSize.width)
        totalSize.height += detailsLabelSize.height
        if detailsLabelSize.height > 0.0 && (indicatorF.size.height > 0.0 || labelSize.height > 0.0) {
            totalSize.height += kPadding
        }
        
        totalSize.width += 2 * CGFloat(margin)
        totalSize.height += 2 * CGFloat(margin)
        
        // Position elements
        var yPos: CGFloat = round(((bounds.size.height - totalSize.height) / 2)) + CGFloat(margin) + CGFloat(yOffset)
        let xPos: CGFloat = CGFloat(xOffset)
        indicatorF.origin.y = yPos
        indicatorF.origin.x = round((bounds.size.width - indicatorF.size.width) / 2) + xPos
        indicator?.frame = indicatorF
        yPos += indicatorF.size.height
        
        if labelSize.height > 0.0 && indicatorF.size.height > 0.0 {
            yPos += kPadding
        }
        var labelF: CGRect = CGRect.zero
        labelF.origin.y = yPos
        labelF.origin.x = round((bounds.size.width - labelSize.width) / 2) + xPos
        labelF.size = labelSize
        label.frame = labelF
        yPos += labelF.size.height
        
        if detailsLabelSize.height > 0.0 && (indicatorF.size.height > 0.0 || labelSize.height > 0.0) {
            yPos += kPadding
        }
        var detailsLabelF: CGRect = CGRect.zero
        detailsLabelF.origin.y = yPos
        detailsLabelF.origin.x = round((bounds.size.width - detailsLabelSize.width) / 2) + xPos
        detailsLabelF.size = detailsLabelSize
        detailsLabel.frame = detailsLabelF
        
        // Enforce minsize and quare rules
        if square {
            let maxWH: CGFloat = max(totalSize.width, totalSize.height)
            if maxWH <= bounds.size.width - 2 * CGFloat(margin) {
                totalSize.width = maxWH
            }
            if maxWH <= bounds.size.height - 2 * CGFloat(margin) {
                totalSize.height = maxWH
            }
        }
        if totalSize.width < minSize.width {
            totalSize.width = minSize.width
        }
        if totalSize.height < minSize.height {
            totalSize.height = minSize.height
        }
        
        size = totalSize
    }
    
    // MARK: - BG Drawing
    override func draw(_ rect: CGRect) {
        let context: CGContext = UIGraphicsGetCurrentContext()!
        UIGraphicsPushContext(context)
        
        if self.dimBackground {
            //Gradient colours
            let gradLocationsNum: size_t = 2
            let gradLocations: [CGFloat] = [0.0, 1.0]
            let gradColors: [CGFloat] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.75]
            let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient: CGGradient = CGGradient(colorSpace: colorSpace, colorComponents: gradColors, locations: gradLocations, count: gradLocationsNum)!
            //Gradient center
            let gradCenter: CGPoint = CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2)
            //Gradient radius
            let gradRadius: CGFloat = min(self.bounds.size.width , self.bounds.size.height)
            //Gradient draw
            context.drawRadialGradient(gradient, startCenter: gradCenter, startRadius: 0, endCenter: gradCenter, endRadius: gradRadius,options: CGGradientDrawingOptions.drawsAfterEndLocation)
        }
        
        // Set background rect color
        if let color = self.color {
            context.setFillColor(color.cgColor)
        } else {
            context.setFillColor(gray: 0.0, alpha: CGFloat(opacity))
        }
        
        
        // Center HUD
        let allRect: CGRect = self.bounds
        // Draw rounded HUD backgroud rect
        let boxRect: CGRect = CGRect(x: round((allRect.size.width - size.width) / 2) + CGFloat(self.xOffset), y: round((allRect.size.height - size.height) / 2) + CGFloat(self.yOffset), width: size.width, height: size.height)
        let radius = cornerRadius_
        context.beginPath()
        context.move(to: CGPoint(x: boxRect.minX + CGFloat(radius), y: boxRect.minY))
        context.addArc(center: CGPoint(x:boxRect.maxX - CGFloat(radius),y:boxRect.minY + CGFloat(radius)), radius: CGFloat(radius), startAngle: 3 * CGFloat(Double.pi) / 2, endAngle: 0, clockwise: false)
        context.addArc(center: CGPoint(x:boxRect.maxX - CGFloat(radius),y:boxRect.maxY - CGFloat(radius)), radius: CGFloat(radius), startAngle: 0, endAngle: CGFloat(Double.pi) / 2, clockwise: false)
        context.addArc(center: CGPoint(x:boxRect.minX + CGFloat(radius),y:boxRect.maxY - CGFloat(radius)), radius: CGFloat(radius), startAngle: CGFloat(Double.pi) / 2, endAngle: CGFloat(Double.pi), clockwise: false)
        context.addArc(center: CGPoint(x:boxRect.minX + CGFloat(radius),y:boxRect.minY + CGFloat(radius)), radius: CGFloat(radius), startAngle: CGFloat(Double.pi), endAngle: 3 * CGFloat(Double.pi) / 2, clockwise: false)
        context.closePath()
        context.fillPath()
        
        UIGraphicsPopContext()
    }
}

// MARK: - Class methods
extension MBProgressHUD {
    
    class func showHUDAddedTo(_ view: UIView, animated: Bool) -> MBProgressHUD {
        let hud: MBProgressHUD = MBProgressHUD(view: view)
        hud.removeFromSuperViewOnHide = true
        view.addSubview(hud)
        hud.show(animated)
        
        return hud
    }
    
    class func hideHUDForView(_ view: UIView, animated: Bool) -> Bool {
        guard let hud = self.HUDForView(view) else {
            return false
        }
        
        hud.removeFromSuperViewOnHide = true
        hud.hide(animated)
        
        return true
    }
    
    class func hideAllHUDsForView(_ view: UIView, animated: Bool) -> Int {
        let huds = MBProgressHUD.allHUDsForView(view)
        for hud in huds {
            hud.removeFromSuperViewOnHide = true
            hud.hide(animated)
        }
        
        return huds.count
    }
    
    class func HUDForView(_ view: UIView) -> MBProgressHUD? {
        for subview in Array(view.subviews.reversed()) {
            if subview is MBProgressHUD {
                return subview as? MBProgressHUD
            }
        }
        
        return nil
    }
    
    class func allHUDsForView(_ view: UIView) -> [MBProgressHUD] {
        var huds: [MBProgressHUD] = []
        for aView in view.subviews {
            if aView is MBProgressHUD {
                huds.append(aView as! MBProgressHUD)
            }
        }
        
        return huds
    }
}

// MARK: - MBRoundProgressView
class MBRoundProgressView: UIView {
    var progress: Float = 0.0 {
        didSet {
            self.updateUI()
        }
    }
    
    var progressTintColor: UIColor {
        didSet {
            self.updateUI()
        }
    }
    
    var backgroundTintColor: UIColor {
        didSet {
            self.updateUI()
        }
    }
    
    var annular: Bool = false {
        didSet {
            self.updateUI()
        }
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0.0, y: 0.0, width: 37.0, height: 37.0))
    }
    
    override init(frame: CGRect) {
        progressTintColor = UIColor(white: 1.0, alpha: 1.0)
        backgroundTintColor = UIColor(white: 1.0, alpha: 0.1)
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let allRect: CGRect = self.bounds
        let circleRect: CGRect = allRect.insetBy(dx: 2.0, dy: 2.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        
        if annular {
            // Draw background
            let lineWidth: CGFloat = 2.0
            let processBackgroundPath: UIBezierPath = UIBezierPath()
            
            processBackgroundPath.lineWidth = lineWidth
            processBackgroundPath.lineCapStyle = CGLineCap.butt
            
            let center: CGPoint = CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2)
            let radius: CGFloat = (self.bounds.size.width - lineWidth) / 2
            let startAngle: CGFloat = -(CGFloat(Double.pi) / 2)
            var endAngle: CGFloat = (2 * CGFloat(Double.pi)) + startAngle
            processBackgroundPath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            backgroundTintColor.set()
            processBackgroundPath.stroke()
            
            // Draw progress
            let processPath: UIBezierPath = UIBezierPath()
            processPath.lineCapStyle = CGLineCap.square
            processPath.lineWidth = lineWidth
            endAngle = CGFloat(progress) * 2 * CGFloat(Double.pi) + startAngle
            processPath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            progressTintColor.set()
            processPath.stroke()
        } else {
            // Draw background
            progressTintColor.setStroke()
            backgroundTintColor.setFill()
            context.setLineWidth(2.0)
            context.fillEllipse(in: circleRect)
            context.strokeEllipse(in: circleRect)
            
            // Draw progress
            let center: CGPoint = CGPoint(x: allRect.size.width / 2, y: allRect.size.height / 2)
            let radius: CGFloat = (allRect.size.width - 4) / 2
            let startAngle: CGFloat = -(CGFloat(Double.pi) / 2)
            let endAngle: CGFloat = CGFloat(progress) * 2 * CGFloat(Double.pi) + startAngle
            progressTintColor.setFill()
            context.move(to: CGPoint(x: center.x, y: center.y))
            context.addArc(center: CGPoint(x:center.x,y:center.y), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            context.closePath()
            context.fillPath()
        }
    }
}


// MARK: - MBBarProgressView
class MBBarProgressView: UIView {
    var progress: Float {
        didSet {
            self.updateUI()
        }
    }
    
    var lineColor: UIColor {
        didSet {
            self.updateUI()
        }
    }
    
    var progressRemainingColor: UIColor {
        didSet {
            self.updateUI()
        }
    }
    
    var progressColor: UIColor {
        didSet {
            self.updateUI()
        }
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0.0, y: 0.0, width: 120.0, height: 20.0))
    }
    
    override init(frame: CGRect) {
        progress = 0.0
        lineColor = UIColor.white
        progressColor = UIColor.white
        progressRemainingColor = UIColor.clear
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let context: CGContext = UIGraphicsGetCurrentContext()!
        
        context.setLineWidth(2)
        context.setStrokeColor(lineColor.cgColor)
        context.setFillColor(progressRemainingColor.cgColor)
        
        // Draw background
        var radius: CGFloat = (rect.size.height / 2) - 2
        context.move(to: CGPoint(x: 2, y: rect.size.height / 2))
        context.addArc(tangent1End: CGPoint(x:2,y:2), tangent2End: CGPoint(x:radius + 2,y:2), radius: radius)
        context.addLine(to: CGPoint(x: rect.size.width - radius - 2, y: 2))
        context.addArc(tangent1End: CGPoint(x:rect.size.width - 2,y:2), tangent2End: CGPoint(x:rect.size.width - 2,y:rect.size.height / 2), radius: radius)
        context.addArc(tangent1End: CGPoint(x:rect.size.width - 2,y:rect.size.height - 2), tangent2End: CGPoint(x:rect.size.width - radius - 2,y:rect.size.height - 2), radius: radius)
        context.addLine(to: CGPoint(x: radius + 2, y: rect.size.height - 2))
        context.addArc(tangent1End: CGPoint(x:2,y:rect.size.height - 2), tangent2End: CGPoint(x:2,y:rect.size.height / 2), radius: radius)
        context.fillPath()
        
        // Draw border
        context.move(to: CGPoint(x: 2, y: rect.size.height / 2))
        context.addArc(tangent1End: CGPoint(x:2,y:2), tangent2End: CGPoint(x:radius + 2,y:2), radius: radius)
        context.addLine(to: CGPoint(x: rect.size.width - radius - 2, y: 2))
        context.addArc(tangent1End: CGPoint(x:rect.size.width - 2,y:2), tangent2End: CGPoint(x:rect.size.width - 2,y:rect.size.height / 2), radius: radius)
        context.addArc(tangent1End: CGPoint(x:rect.size.width - 2,y:rect.size.height - 2), tangent2End: CGPoint(x:rect.size.width - radius - 2,y:rect.size.height - 2), radius: radius)
        context.addLine(to: CGPoint(x: radius + 2, y: rect.size.height - 2))
        context.addArc(tangent1End: CGPoint(x:2,y:rect.size.height - 2), tangent2End: CGPoint(x:2,y:rect.size.height / 2), radius: radius)
        context.strokePath()
        
        context.setFillColor(progressColor.cgColor)
        radius = radius - 2
        let amount: CGFloat = CGFloat(progress) * rect.size.width
        
        // Progress in the middle area
        if amount >= radius + 4 && amount <= (rect.size.width - radius - 4) {
            context.move(to: CGPoint(x: 4, y: rect.size.height / 2))
            context.addArc(tangent1End: CGPoint(x:4,y:4), tangent2End: CGPoint(x:radius + 4,y:4), radius: radius)
            context.addLine(to: CGPoint(x: amount, y: 4))
            context.addLine(to: CGPoint(x: amount, y: radius + 4))
            
            context.move(to: CGPoint(x: 4, y: rect.size.height / 2))
            context.addArc(tangent1End: CGPoint(x:4,y:rect.size.height - 4), tangent2End: CGPoint(x:radius + 4,y:rect.size.height - 4), radius: radius)
            context.addLine(to: CGPoint(x: amount, y: rect.size.height - 4))
            context.addLine(to: CGPoint(x: amount, y: radius + 4))
            
            context.fillPath()
        }
            
            // Progress in the right arc
        else if (amount > radius + 4) {
            let x: CGFloat = amount - (rect.size.width - radius - 4)
            
            context.move(to: CGPoint(x: 4, y: rect.size.height / 2))
            context.addArc(tangent1End: CGPoint(x:4,y:4), tangent2End: CGPoint(x:radius + 4,y:4), radius: radius)
            context.addLine(to: CGPoint(x: rect.size.width - radius - 4, y: 4))
            var angle: CGFloat = -acos(x / radius)
            if angle.isNaN{
                angle = 0
            }
            //            if isnan(angle) {   angle = 0   }
            context.addArc(center: CGPoint(x:rect.size.width - radius - 4,y:rect.size.height / 2), radius: radius, startAngle: CGFloat(Double.pi), endAngle: angle, clockwise: false)
            context.addLine(to: CGPoint(x: amount, y: rect.size.height / 2))
            
            context.move(to: CGPoint(x: 4, y: rect.size.height/2))
            context.addArc(tangent1End: CGPoint(x:4,y:rect.size.height - 4), tangent2End: CGPoint(x:radius + 4,y:rect.size.height - 4), radius: radius)
            context.addLine(to: CGPoint(x: rect.size.width - radius - 4, y: rect.size.height - 4))
            angle = acos(x/radius)
            if angle.isNaN {
                angle = 0
            }
            context.addArc(center: CGPoint(x:rect.size.width - radius - 4,y:rect.size.height / 2), radius: radius, startAngle: CGFloat(-Double.pi), endAngle: angle, clockwise: true)
            context.addLine(to: CGPoint(x: amount, y: rect.size.height / 2))
            
            context.fillPath()
        }
            
            // Progress is in the left arc
        else if amount < radius + 4 && amount > 0 {
            context.move(to: CGPoint(x: 4, y: rect.size.height / 2))
            context.addArc(tangent1End: CGPoint(x:4,y:4), tangent2End: CGPoint(x:radius + 4,y:4), radius: radius)
            context.addLine(to: CGPoint(x: radius + 4, y: rect.size.height / 2))
            
            context.move(to: CGPoint(x: 4, y: rect.size.height / 2))
            context.addArc(tangent1End: CGPoint(x:4,y:rect.size.height - 4), tangent2End: CGPoint(x:radius + 4,y:rect.size.height - 4), radius: radius)
            context.addLine(to: CGPoint(x: radius + 4, y: rect.size.height / 2))
            
            context.fillPath()
        }
    }
}

// MARK: - MBIndeterminatedRoundProgressView
class MBIndeterminatedRoundProgressView: UIView {
    fileprivate let circleLayer: CAShapeLayer = CAShapeLayer()
    
    var lineColor: UIColor = UIColor.white {
        didSet {
            self.updateUI()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
        
        setupAndStartRotatingCircle()
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0.0, y: 0.0, width: 37.0, height: 37.0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupAndStartRotatingCircle() {
        let circlePath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.bounds.size.width / 2)
        circleLayer.frame = self.bounds
        circleLayer.path = circlePath.cgPath
        circleLayer.strokeColor = lineColor.cgColor
        circleLayer.lineWidth = 2.0
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineCap = CAShapeLayerLineCap.round
        
        self.layer.addSublayer(circleLayer)
        
        startRotatingCircle()
    }
    
    fileprivate func startRotatingCircle() {
        let animationForStrokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        animationForStrokeEnd.fromValue = 0.0
        animationForStrokeEnd.toValue = 1.0
        animationForStrokeEnd.duration = 0.4
        animationForStrokeEnd.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        
        let animationForStrokeStart = CABasicAnimation(keyPath: "strokeStart")
        animationForStrokeStart.fromValue = 0.0
        animationForStrokeStart.toValue = 1.0
        animationForStrokeStart.duration = 0.4
        animationForStrokeStart.beginTime = 0.5
        animationForStrokeStart.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [animationForStrokeEnd, animationForStrokeStart]
        animationGroup.duration = 0.9
        animationGroup.repeatCount = MAXFLOAT
        
        circleLayer.add(animationGroup, forKey: nil)
    }
}

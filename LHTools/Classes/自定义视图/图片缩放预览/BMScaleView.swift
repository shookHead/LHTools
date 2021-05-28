//
//  MultiImgChooseView.swift
//  wangfuAgent
//
//  Created by lzw on 2018/7/24.
//  Copyright © 2018 zhuanbangTec. All rights reserved.
//

import UIKit

public class BMScaleView: UIView,UIScrollViewDelegate{
    
    var scrollView:UIScrollView!
    
    public var image:UIImage!
    
    public var imageView:UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func prepare(){
        self.scrollView = UIScrollView()
        self.scrollView.frame = self.bounds
        self.scrollView.delegate=self
        self.addSubview(self.scrollView)
        
        imageView = UIImageView(image: self.image)
        imageView.frame = CGRect(origin: CGPoint.zero, size: self.image.size)
        self.scrollView.addSubview(imageView)
        self.scrollView.contentSize = image.size
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped(_:)))
        self.scrollView.addGestureRecognizer(tapRecognizer)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(scrollViewDoubleTapped(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        self.scrollView.addGestureRecognizer(doubleTapRecognizer)
        
        //缩小
        let twoFingerTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(scrollViewTwoFingerTapped(_:)))
        twoFingerTapRecognizer.numberOfTapsRequired = 1
        twoFingerTapRecognizer.numberOfTouchesRequired = 2
        self.scrollView.addGestureRecognizer(twoFingerTapRecognizer)
        
        let scrollViewFrame = self.scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height
        let minScale = min(scaleWidth, scaleHeight)
        
        self.scrollView.minimumZoomScale = minScale
        self.scrollView.maximumZoomScale = 1.0
        self.scrollView.zoomScale = minScale
    }
    
    func centerScrollViewContents() {
        let boundsSize = self.scrollView.bounds.size
        var contentsFrame = self.imageView.frame
        
        if (contentsFrame.size.width < boundsSize.width) {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if (contentsFrame.size.height < boundsSize.height) {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        self.imageView.frame = contentsFrame
    }
    
    @objc func scrollViewTapped(_ recognizer:UITapGestureRecognizer){
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
    @objc func scrollViewDoubleTapped(_ recognizer:UITapGestureRecognizer){
        let pointInView = recognizer.location(in: self.imageView)
        
        var newZoomScale = self.scrollView.zoomScale * 1.5
        newZoomScale = min(newZoomScale, self.scrollView.maximumZoomScale)
        
        let scrollViewSize = self.scrollView.bounds.size
        
        let w = scrollViewSize.width / newZoomScale
        let h = scrollViewSize.height / newZoomScale
        let x = pointInView.x - (w / 2.0)
        let y = pointInView.y - (h / 2.0)
        
        let rectToZoomTo = CGRect(x: x, y: y, width: w, height: h)
        self.scrollView .zoom(to: rectToZoomTo, animated: true)
    }
    
    @objc func scrollViewTwoFingerTapped(_ recognizer:UITapGestureRecognizer){
        var newZoomScale = self.scrollView.zoomScale / 1.5
        newZoomScale = max(newZoomScale, self.scrollView.minimumZoomScale)
        self.scrollView.setZoomScale(newZoomScale, animated: true)
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.centerScrollViewContents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension BaseVC {
    @discardableResult
    func previewImage(_ img:UIImage?) -> BMScaleView{
        let imageScView = BMScaleView(frame: window!.bounds)
        imageScView.image = img
        imageScView.prepare()
        imageScView.alpha = 0
        imageScView.backgroundColor = UIColor.black
        window?.addSubview(imageScView)
        UIView.animate(withDuration: 0.2) {
            imageScView.alpha = 1
        }
        return imageScView
    }
}

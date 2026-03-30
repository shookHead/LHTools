//
//  PhotoBrowser.swift
//  demo2
//
//  Created by 蔡林海 on 2020/1/10.
//  Copyright © 2020 蔡林海. All rights reserved.
//

import UIKit
import JXPhotoBrowser

public class PhotoBrowser: NSObject,JXPhotoBrowserDelegate {
    private var images: [String] = []

    public static func show(images:[String],index:Int=0)  {
        let instance = PhotoBrowser()
        instance.images = images
        instance.show(index: index)
    }
    private func show(index: Int) {
        let browser = JXPhotoBrowserViewController()
        browser.register(LoadingImageCell.self, forReuseIdentifier: LoadingImageCell.videoReuseIdentifier)

        browser.delegate = self
        browser.initialIndex = index
        // 使用浏览器设置面板的配置
        browser.scrollDirection = .horizontal
        browser.transitionType = .zoom
        browser.itemSpacing = 20
        objc_setAssociatedObject(browser, "delegate", self, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        guard let vc = lh.topMost() else { return }
        browser.present(from: vc)
    }
    
    public func photoBrowser(_ browser: JXPhotoBrowser.JXPhotoBrowserViewController, cellForItemAt index: Int, at indexPath: IndexPath) -> any JXPhotoBrowser.JXPhotoBrowserAnyCell {
//        let cell = browser.dequeueReusableCell(withReuseIdentifier: LoadingImageCell.reuseIdentifier, for: indexPath) as! LoadingImageCell
//
        let cell = browser.dequeueReusableCell(
            withReuseIdentifier: LoadingImageCell.videoReuseIdentifier, // ✅ 一致
            for: indexPath
        ) as! LoadingImageCell
        let url = images[index]
        cell.reloadData(
            placeholder: nil,
            urlString: url
        )
        return cell
    }
    

    
    public func numberOfItems(in browser: JXPhotoBrowser.JXPhotoBrowserViewController) -> Int {
        images.count
    }
    
}

/// 加上进度环的Cell
class LoadingImageCell: JXZoomImageCell {
    public static let videoReuseIdentifier = "LoadingImageCell"
    /// 进度环
    public let progressView = JXPhotoBrowserProgressView()
//    override func setup() {
//        super.setup()
//        addSubview(progressView)
//    }
    override init(frame: CGRect) {
         super.init(frame: frame)
         setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    func setupUI() {
        addSubview(progressView)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        progressView.progress = 0
    }
 
    override func layoutSubviews() {
        super.layoutSubviews()
        progressView.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
    }
    public func reloadData(placeholder: UIImage?, urlString: String?) {
        progressView.progress = 0
        let url = urlString.flatMap { URL(string: $0) }
        //[.transition(.fade(0.3))]
        imageView.kf.setImage(with: url, placeholder: nil, options: nil) { (received, total) in
            if total > 0 {
                self.progressView.progress = CGFloat(received) / CGFloat(total)
            }
        } completionHandler: { (result) in
            switch result{
            case .success:
                self.progressView.progress = 1.0
            case .failure:
                self.imageView.image = UIImage.init(named: "imageLoadingFailed")
                self.progressView.progress = 0
            }
            self.setNeedsLayout()
        }
    }
}

//
//  PhotoBrowser.swift
//  demo2
//
//  Created by 蔡林海 on 2020/1/10.
//  Copyright © 2020 蔡林海. All rights reserved.
//

import UIKit
import JXPhotoBrowser

public class PhotoBrowser: NSObject {

    public static func show(images:Array<String>,index:Int=0)  {
        let browser = JXPhotoBrowser()
        browser.numberOfItems = {
            images.count
        }
        browser.cellClassAtIndex = { _ in
            LoadingImageCell.self
        }
        browser.reloadCellAtIndex = { context in
            let browserCell = context.cell as? LoadingImageCell
            let indexPath = IndexPath(item: context.index, section: 0)
            browserCell?.reloadData(placeholder: #imageLiteral(resourceName: "imageLoadingFailed"), urlString: images[indexPath.row])
        }
        // 数字样式的页码指示器
        browser.pageIndicator = JXPhotoBrowserNumberPageIndicator()
        browser.pageIndex = index
        browser.show()
    }
}

/// 加上进度环的Cell
class LoadingImageCell: JXPhotoBrowserImageCell {
    /// 进度环
    public let progressView = JXPhotoBrowserProgressView()
    override func setup() {
        super.setup()
        addSubview(progressView)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        progressView.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
    }
    public func reloadData(placeholder: UIImage?, urlString: String?) {
        progressView.progress = 0
        let url = urlString.flatMap { URL(string: $0) }
        imageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(0.3))]) { (received, total) in
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

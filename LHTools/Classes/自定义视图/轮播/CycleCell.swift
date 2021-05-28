//
//  CycleCell.swift
//  saasSwift
//
//  Created by 周玉 on 2017/11/21.
//  Copyright © 2017年 周玉. All rights reserved.
//

import UIKit

public class CycleCell: UICollectionViewCell {
    
    public var mode : contentMode? {
        didSet{
            switch mode ?? .scaleAspectFill {
            case .scaleAspectFill:
                imageView.contentMode = .scaleAspectFill
            case .scaleAspectFit:
                imageView.contentMode = .scaleAspectFit
            }
        }
    }
    
    //FIXME: 本地和网络下载走的不同路径
    public var imageURLString : String? {
        didSet{
            if (imageURLString?.hasPrefix("http"))! {
                //网络图片:使用SDWebImage下载即可
                imageView.kf.setImage(with: imageURLString.resource, placeholder: #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1).image, options: [.transition(.fade(0.45))])
            } else {
                //本地图片
                imageView.image = UIImage(named: imageURLString!)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: 懒加载
    public lazy var imageView : UIImageView = {
        let imageView = UIImageView(frame: bounds)
        imageView.clipsToBounds = true
        return imageView
    }()
}

//MARK: 设置UI
extension CycleCell {
    fileprivate func setUpUI() {
        contentView.addSubview(imageView)
    }
}

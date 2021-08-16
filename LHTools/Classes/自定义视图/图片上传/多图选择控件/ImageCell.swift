//
//  ImageCell.swift
//  Example
//
//  Created by long on 2020/8/20.
//

import UIKit

protocol ImageCellDelegate {
    func longPressClick(gesture:UILongPressGestureRecognizer)
}
class ImageCell: UICollectionViewCell {
    
    public var delegate :ImageCellDelegate?
    var imageView: UIImageView!
    lazy var removeBtn: HotBaseBtn = {
        var btn = HotBaseBtn()
        btn.setImage(#imageLiteral(resourceName: "photoDelete"), for: .normal)
        return btn
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1)
        imageView.isUserInteractionEnabled = true
        contentView.addSubview(imageView)
        
        contentView.addSubview(removeBtn)
        imageView.backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.9764705882, blue: 0.9882352941, alpha: 1)
        let gesture = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressClick(_ :)))
        self.addGestureRecognizer(gesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = self.bounds
        let btnWH:CGFloat = 20
        removeBtn.frame = CGRect(x: self.w - btnWH - 5, y: 5, width: btnWH, height: btnWH)
    }
    @objc func longPressClick(_ gesture:UILongPressGestureRecognizer) {
        delegate?.longPressClick(gesture: gesture)
    }
    
}

//
//  CamerView.swift
//  LHTools
//
//  Created by 蔡林海 on 2021/8/13.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import ZLPhotoBrowser
public class CamerView: UIView {
    public static var imgName = "CamerView_UploadImg"
    var formIndex:Int!
    var toIndex:Int!
    var moveView:UIImageView!
    ///行间距
    public var lineSpacing:CGFloat = 10
    ///列间距
    public var itemSpacing:CGFloat = 10
    ///内边距
    public var edg = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    ///每行多少个
    public var columnCount:CGFloat = 4
    open var collectionView:UICollectionView!
    public var selectedPhotos:[String] = []{
        didSet{
            selectedPhotosStr = selectedPhotos.joined(separator: ",")
        }
    }
    public var selectedPhotosStr:String!
    
    var mutlSelectedPhotos:[UIImage] = []
    ///是否能展示大图
    public var canShowBigImage = true
    ///最大选择数量
    public var maxCount = 1000
    public var scrollDirection: UICollectionView.ScrollDirection = .vertical{
        didSet{
            layout.scrollDirection = scrollDirection
            collectionView.collectionViewLayout = layout
            collectionView.reloadData()
        }
    }
    lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        return layout
    }()
    /// 页面传参回调
    public var setViewHeightClosure: ((_ height:CGFloat) -> ())?
    public var canMove = false{
        didSet{
            collectionView.reloadData()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        collectionView = UICollectionView.init(frame: self.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        addSubview(collectionView)
        collectionView.register(ImageCell.classForCoder(), forCellWithReuseIdentifier: "imageCell")
        collectionView.reloadData()
    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = self.bounds
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func openCamera() {
        var vc = UIViewController()
        let rootVc = lh.topMost()
        if rootVc == nil {
            return
        }
        vc = rootVc!
        let alertSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let acrion1 = UIAlertAction(title: "拍照", style: .default) { (action) in
            self.setconfig(maxSelectCount: 1)
            let camera = ZLCustomCamera()
            camera.takeDoneBlock = { [weak self] (image, videoUrl) in
                print(image as Any)
                self?.save(image: image)
            }
            vc.showDetailViewController(camera, sender: nil)
        }
        let acrion2 = UIAlertAction(title: "从相册选取", style: .default) { [self] (action) in
            self.setconfig(maxSelectCount: maxCount - selectedPhotos.count)
            let ps = ZLPhotoPreviewSheet()
            ps.selectImageBlock = { [weak self] (images, assets, isOriginal) in
                print(images)
                self?.mutlSelectedPhotos.removeAll()
                self?.mutlSelectedPhotos += images
                self?.upDataImagewithimage(index: 0)
            }
            ps.showPhotoLibrary(sender: vc)
        }
        let acrion3 = UIAlertAction(title: "取消", style: .cancel) { (action) in
            
        }
        alertSheet.addAction(acrion1)
        alertSheet.addAction(acrion2)
        alertSheet.addAction(acrion3)
        vc.present(alertSheet, animated: true, completion: nil)
    }
    public func setconfig(maxSelectCount:Int) {
        let config = ZLPhotoConfiguration.default()
        config.maxSelectCount = maxSelectCount
        config.allowSelectVideo = false
        config.allowSelectGif = false
        config.allowEditImage = false
        config.allowSelectOriginal = false
        config.allowSelectImage  = true
    }
    func save(image: UIImage?) {
        if let image = image {
            ZLPhotoManager.saveImageToAlbum(image: image) { [weak self] (suc, asset) in
                if suc {
                    self?.mutlSelectedPhotos.removeAll()
                    self?.mutlSelectedPhotos.append(image)
                    self?.upDataImagewithimage(index: 0)
                } else {
                    Hud.showText("保存图片到相册失败")
                }
            }
        }else{
            Hud.showText("保存图片到相册失败")
        }
    }
    public func setViewHeightClosure(_ closure : @escaping (_ height:CGFloat) -> ()){
        setViewHeightClosure = closure
    }
    func setHeightBlock() {
        layoutSubviews()
        if let block = setViewHeightClosure {
            var h:CGFloat = 0
            let totalWH = collectionView.bounds.width - (columnCount - 1) * itemSpacing - edg.left - edg.right
            let singleWH = totalWH / columnCount
            h += edg.top
            h += edg.bottom
            var row = 0
            if selectedPhotos.count >= maxCount {
                row = (selectedPhotos.count + Int(columnCount) - 1) / Int(columnCount)
            }else{
                row = (selectedPhotos.count + Int(columnCount)) / Int(columnCount)
            }
            h = h + singleWH * CGFloat(row) + (CGFloat(row) - 1) * lineSpacing
            DispatchQueue.main.async {
                block(h)
            }
        }
    }
    
    @objc func removeBtnAction(_ btn:UIButton) {
        if selectedPhotos.count <= btn.tag {
            collectionView.reloadData()
            return
        }
        if self.collectionView(self.collectionView, numberOfItemsInSection: 0) <= self.selectedPhotos.count {
            selectedPhotos.remove(at: btn.tag)
            collectionView.reloadData()
            return
        }
        selectedPhotos.remove(at: btn.tag)
        collectionView.performBatchUpdates {
            let indexPath = IndexPath.init(row: btn.tag, section: 0)
            self.collectionView.deleteItems(at: [indexPath])
        } completion: { (_) in
            self.collectionView.reloadData()
            self.setHeightBlock()
        }
    }
    func upDataImagewithimage(index:Int) {
        Hud.showWait("上传图片\(index)/\(mutlSelectedPhotos.count)")
        network.upload(mutlSelectedPhotos[index]) { (progress) in
            
        } finish: { [self] (imageUrl) in
            if imageUrl == nil{
                Hud.showText("上传失败")
                return
            }
            add(url: imageUrl!, index: selectedPhotos.count)
            if (index + 1) < mutlSelectedPhotos.count{
                upDataImagewithimage(index: index + 1)
            }else{//上传完毕
                Hud.hide()
                UIView.animate(withDuration: 0.5) {
                    collectionView.reloadData()
                }
            }
        }
    }
    func add(url:String,index:Int) {
        selectedPhotos.append(url)
        if #available(iOS 13.0, *) {
            updateCollectionView(index: index)
        }else{
            if maxCount <= selectedPhotos.count {
                collectionView.reloadData()
            }else{
                updateCollectionView(index: index)
            }
        }

//        collectionView.reloadData()
    }
    func updateCollectionView(index:Int) {
        collectionView.performBatchUpdates {
            let indexPath = IndexPath.init(row: index, section: 0)
            collectionView.insertItems(at: [indexPath])
        } completion: { [self] (_) in
            collectionView.reloadData()
            setHeightBlock()
        }
    }
    public func reloadViewWithImages(imageStr:String) {
        let images = imageStr.components(separatedBy: ",")
        self.selectedPhotos = images
        collectionView.reloadData()
        self.setHeightBlock()
    }
}
extension CamerView: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,ImageCellDelegate{
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if maxCount <= selectedPhotos.count {
            return selectedPhotos.count
        }
        return selectedPhotos.count + 1
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCell
        if indexPath.row == self.selectedPhotos.count{
            cell.imageView.image = UIImage(named: CamerView.imgName)
            cell.removeBtn.isHidden = true
        }else{
            let imgUrl = selectedPhotos[indexPath.row]
            cell.imageView.kf.setImage(with: imgUrl.resource, placeholder:#colorLiteral(red: 0.9410951734, green: 0.937307477, blue: 0.9410645962, alpha: 1).image , options: [.transition(.fade(0.5))])
            cell.removeBtn.isHidden = false
        }
        cell.removeBtn.tag = indexPath.item
        cell.removeBtn.addTarget(self, action: #selector(removeBtnAction(_ :)), for: .touchUpInside)
        if canMove {
            cell.delegate = self
        }
        return cell
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        edg
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        lineSpacing
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        itemSpacing
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWH = collectionView.bounds.width - (columnCount - 1) * itemSpacing - edg.left - edg.right
        let singleWH = totalWH / columnCount - 0.01
        return CGSize(width: singleWH, height: singleWH)
    }
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == self.selectedPhotos.count {
            openCamera()
            return
        }
        if canShowBigImage {
            PhotoBrowser.show(images: selectedPhotos, index: indexPath.row)
        }
    }
    func longPressClick(gesture: UILongPressGestureRecognizer) {
        if gesture.view == nil {
            return
        }
        var point = CGPoint.zero
        if gesture.state == .began {
            moveView = UIImageView.init(image: gesture.view?.toImage())
            moveView.frame = gesture.view!.frame
            gesture.view?.isHidden = true
            moveView.center = gesture.view!.center
            collectionView.addSubview(moveView)
            point = gesture.location(ofTouch: 0, in: collectionView)
            moveView.center = point
            moveView.setScale(x: 1.2, y: 1.2)
            let oldCell = gesture.view as! UICollectionViewCell
            let startIndexPath = collectionView.indexPath(for: oldCell)
            formIndex = startIndexPath!.item
//            print("开始\(formIndex!)")
        }else if gesture.state == .changed {
//            print("移动")
            let x = gesture.location(ofTouch: 0, in: collectionView).x - point.x
            let y = gesture.location(ofTouch: 0, in: collectionView).y - point.y
            moveView.centerX = x
            moveView.centerY = y
            point = gesture.location(ofTouch: 0, in: collectionView)
            for cell in collectionView.visibleCells {
                let endIndexPath = collectionView.indexPath(for: cell)
                if cell.isHidden == true || endIndexPath!.item == selectedPhotos.count {
                    continue
                }
                let cellPoint = CGPoint(x: cell.centerX, y: cell.centerY)
                let x = abs(cellPoint.x - point.x)
                let y = abs(cellPoint.y - point.y)
                if cell.w/2 > x && cell.h/2 > y {
                    toIndex = endIndexPath!.item
                    let photo = selectedPhotos[formIndex]
                    selectedPhotos.remove(at: formIndex)
                    selectedPhotos.insert(photo, at: toIndex)
                    collectionView.moveItem(at: IndexPath(row: formIndex, section: 0), to: IndexPath(row: toIndex, section: 0))
                    formIndex = toIndex
//                    print(endIndexPath!.item)
                    break
                }
            }
        }else if gesture.state == .ended{
            print("结束")
            UIView.animate(withDuration: 0.25) { [self] in
                moveView.center = gesture.view!.center
            } completion: { [self] (_) in
                moveView.removeFromSuperview()
                gesture.view?.isHidden = false
            }
        }
    }
}

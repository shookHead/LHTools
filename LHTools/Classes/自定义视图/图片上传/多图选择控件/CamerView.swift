//
//  CamerView.swift
//  LHTools
//
//  Created by 蔡林海 on 2021/8/13.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import ZLPhotoBrowser
class CamerView: UIView {
    var formIndex:Int!
    var toIndex:Int!
    
    var moveView:UIImageView!
    ///是否是原图
    var isOriginal = false
    ///行间距
    var lineSpacing:CGFloat = 10
    ///列间距
    var itemSpacing:CGFloat = 10
    ///内边距
    var edg = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    ///每行多少个
    var columnCount:CGFloat = 4
    var collectionView:UICollectionView!
    var selectedPhotos:[UIImage] = []
    ///最大选择数量
    var maxCount = 8

    override init(frame: CGRect) {
        super.init(frame: frame)

        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        addSubview(collectionView)
        collectionView.register(ImageCell.classForCoder(), forCellWithReuseIdentifier: "imageCell")
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(50)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(-100)
        }
        self.backgroundColor = .red
        collectionView.reloadData()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func openCamera() {
        var vc = UIViewController()
        let rootVc = window?.rootViewController
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
                self?.selectedPhotos += images
                self!.collectionView.reloadData()
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
    func setconfig(maxSelectCount:Int) {
        let config = ZLPhotoConfiguration.default()
        config.maxSelectCount = maxSelectCount
        config.allowSelectVideo = false
        config.allowSelectGif = false
        config.allowEditImage = false
        config.allowSelectOriginal = false
    }
    func save(image: UIImage?) {
        let hud = ZLProgressHUD(style: ZLPhotoConfiguration.default().hudStyle)
        if let image = image {
            hud.show()
            ZLPhotoManager.saveImageToAlbum(image: image) { [weak self] (suc, asset) in
                if suc {
                    self?.selectedPhotos += [image]
                    self?.collectionView.reloadData()
                } else {
                    debugPrint("保存图片到相册失败")
                }
                hud.hide()
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
        }
    }
}
extension CamerView: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,ImageCellDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if maxCount <= selectedPhotos.count {
            return selectedPhotos.count
        }
        return selectedPhotos.count + 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCell
        if indexPath.row == self.selectedPhotos.count{
            cell.imageView.image = #imageLiteral(resourceName: "BMImgItems_UploadImg")
            cell.removeBtn.isHidden = true
        }else{
            cell.imageView.image = selectedPhotos[indexPath.row]
            cell.removeBtn.isHidden = false
        }
        cell.removeBtn.tag = indexPath.item
        cell.removeBtn.addTarget(self, action: #selector(removeBtnAction(_ :)), for: .touchUpInside)
        cell.delegate = self
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        edg
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        lineSpacing
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        itemSpacing
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalW = collectionView.bounds.width - (columnCount - 1) * itemSpacing - edg.left - edg.right
        let singleW = totalW / columnCount
        return CGSize(width: singleW, height: singleW)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == self.selectedPhotos.count {
            openCamera()
            return
        }
//        let ac = ZLPhotoPreviewSheet()
//        ac.selectImageBlock = { [weak self] (images, assets, isOriginal) in
//            self?.selectedPhotos = images
//            self?.collectionView.reloadData()
//            debugPrint("\(images)   \(assets)   \(isOriginal)")
//        }
//        ac.previewAssets(sender: self, assets: self.selectedAssets, index: indexPath.row, isOriginal: false, showBottomViewAndSelectBtn: true)
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

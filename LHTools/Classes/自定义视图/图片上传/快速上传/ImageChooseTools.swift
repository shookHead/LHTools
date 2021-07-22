//
//  ImageChooseTools.swift
//  wangfuAgent
//
//  Created by lzw on 2018/7/24.
//  Copyright © 2018 zhuanbangTec. All rights reserved.
//

import UIKit
import Photos
import ZLPhotoBrowser
//import CLImagePickerTool

//public class ImageChooseTools: NSObject {
//
//}

// 全局持有 防止释放 后 不走回调
//public var clImgTools:CLImagePickerTool!

public extension UIViewController{
    func chooseSingleImg(_ complish:@escaping (_ img:UIImage?)->() ){
//        clImgTools = CLImagePickerTool()
//        clImgTools.cameraOut = true
//        clImgTools.isHiddenVideo = true
//        clImgTools.singleImageChooseType = .singlePicture
//        //单图时 拿到缩略图
//        clImgTools.cl_setupImagePickerWith(MaxImagesCount: 1, superVC: self) { (_, cutImage) in
//            complish(cutImage)
//        }
        let alertSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let acrion1 = UIAlertAction(title: "拍照", style: .default) { (action) in
            let camera = ZLCustomCamera()
            camera.takeDoneBlock = { (image, videoUrl) in
                print(image as Any)
                if let img = image{
                    complish(img)
                }
            }
            self.showDetailViewController(camera, sender: nil)
        }
        let acrion2 = UIAlertAction(title: "从相册选取", style: .default) { (action) in
            self.setconfig(maxSelectCount: 1)
            let ps = ZLPhotoPreviewSheet()
            ps.selectImageBlock = { (images, assets, isOriginal) in
                // your code
                print(images)
                if images.count == 0{
                    return
                }
                complish(images[0])
            }
            ps.showPhotoLibrary(sender: self)
        }
        let acrion3 = UIAlertAction(title: "取消", style: .cancel) { (action) in
            
        }
        alertSheet.addAction(acrion1)
        alertSheet.addAction(acrion2)
        alertSheet.addAction(acrion3)
        self.present(alertSheet, animated: true, completion: nil)
    }

    func chooseMutiImg(_ num:Int,_ complish:@escaping (_ img:[UIImage])->() ){
//        clImgTools = CLImagePickerTool()
//        clImgTools.cameraOut = true
//        clImgTools.isHiddenVideo = true
//        //多图时 使用asset 数组
//        clImgTools.cl_setupImagePickerWith(MaxImagesCount: num, superVC: self) { (asset,cutImage) in
//            var imageArr = [UIImage]()
//            CLImagePickerTool.convertAssetArrToOriginImage(assetArr: asset, scale: 0.1, successClouse: { (image, assetItem) in
//                imageArr.append(image)
//                if imageArr.count == asset.count {
//                    complish(imageArr)
//                }
//            }, failedClouse: {
//                complish(imageArr)
//            })
//        }
        let alertSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let acrion1 = UIAlertAction(title: "拍照", style: .default) { (action) in
            let camera = ZLCustomCamera()
            camera.takeDoneBlock = { (image, videoUrl) in
                print(image as Any)
                if let img = image{
                    complish([img])
                }
            }
            self.showDetailViewController(camera, sender: nil)
        }
        let acrion2 = UIAlertAction(title: "从相册选取", style: .default) { (action) in
            self.setconfig(maxSelectCount: num)
            let ps = ZLPhotoPreviewSheet()
            ps.selectImageBlock = { (images, assets, isOriginal) in
                // your code
                print(images)
                if images.count == 0{
                    return
                }
                complish(images)
            }
            ps.showPhotoLibrary(sender: self)
        }
        let acrion3 = UIAlertAction(title: "取消", style: .cancel) { (action) in
            
        }
        alertSheet.addAction(acrion1)
        alertSheet.addAction(acrion2)
        alertSheet.addAction(acrion3)
        self.present(alertSheet, animated: true, completion: nil)
    }
    func setconfig(maxSelectCount:Int) {
        let config = ZLPhotoConfiguration.default()
        config.maxSelectCount = maxSelectCount
        config.allowSelectVideo = false
        config.allowSelectGif = false
        config.allowEditImage = false
    }
}





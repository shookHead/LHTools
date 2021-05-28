//
//  ImageChooseTools.swift
//  wangfuAgent
//
//  Created by lzw on 2018/7/24.
//  Copyright © 2018 zhuanbangTec. All rights reserved.
//

import UIKit
import Photos
import CLImagePickerTool

public class ImageChooseTools: NSObject {

}

// 全局持有 防止释放 后 不走回调
public var clImgTools:CLImagePickerTool!

public extension UIViewController{
    func chooseSingleImg(_ complish:@escaping (_ img:UIImage?)->() ){
        clImgTools = CLImagePickerTool()
        clImgTools.cameraOut = true
        clImgTools.isHiddenVideo = true
        clImgTools.singleImageChooseType = .singlePicture
        //单图时 拿到缩略图
        clImgTools.cl_setupImagePickerWith(MaxImagesCount: 1, superVC: self) { (_, cutImage) in
            complish(cutImage)
        }
    }

    func chooseMutiImg(_ num:Int,_ complish:@escaping (_ img:[UIImage])->() ){
        clImgTools = CLImagePickerTool()
        clImgTools.cameraOut = true
        clImgTools.isHiddenVideo = true
        //多图时 使用asset 数组
        clImgTools.cl_setupImagePickerWith(MaxImagesCount: num, superVC: self) { (asset,cutImage) in
            var imageArr = [UIImage]()
            CLImagePickerTool.convertAssetArrToOriginImage(assetArr: asset, scale: 0.1, successClouse: { (image, assetItem) in
                imageArr.append(image)
                if imageArr.count == asset.count {
                    complish(imageArr)
                }
            }, failedClouse: {
                complish(imageArr)
            })
        }
    }
}





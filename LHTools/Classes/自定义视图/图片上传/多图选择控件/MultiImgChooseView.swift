//
//  MultiImgChooseView.swift
//  wangfuAgent
//
//  Created by  on 2018/7/24.
//  Copyright © 2018 zhuanbangTec. All rights reserved.
//

import UIKit

public class BMImgItems : UIButton{

    public var img:UIImage?

    public var imgUrl:String?
    
    public static var uploadBtnImgName = "BMImgItems_UploadImg"

    public let deleteBtnW:CGFloat = 21

    public lazy var deleteBtn:UIButton = {
        var btn = UIButton.init(frame: CGRect(x: self.frame.size.width-deleteBtnW-3, y: 3, width: deleteBtnW, height: deleteBtnW))
        btn.setImage(UIImage(named:"photoDelete"), for: .normal)
        self.addSubview(btn)
        return btn
    }()

    //设置url
    public func setImg(_ imgUrl:String){
//        self.kf.setImage(with: ImageResource(downloadURL: URL.init(string: imgUrl)!), for:.normal)
        self.kf.setImage(with: imgUrl.resource, for:.normal, placeholder: nil, options: [.transition(.fade(0.5))])
        self.imgUrl = imgUrl
        self.deleteBtn.isHidden = false
        self.imageView?.contentMode = .scaleToFill
    }

    //设置图片
    public func setImg(_ image:UIImage?){
        if image == nil {
            return
        }
        self.kf.cancelImageDownloadTask()
        self.img = image
        self.imgUrl = nil
        self.setImage(image, for: .normal)
        self.deleteBtn.isHidden = false
        self.imageView?.contentMode = .scaleToFill
        //uploadImg
        uploadImg()
    }

    public func uploadImg(){
        self.upload(img: self.img!, showPrograss: YES) {[weak self] (btn,success, data) in
            self?.imgUrl = data
        }
    }

    //设置为 上传 按钮
    public func setUploadImg(){
        self.kf.cancelImageDownloadTask()
        self.setImage(UIImage(named: BMImgItems.uploadBtnImgName), for: .normal)
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        self.backgroundColor = .rgb(230, 230, 230)
        self.imgUrl = nil
        self.imageView?.contentMode = .scaleAspectFit
        self.deleteBtn.isHidden = true
    }

    public override func removeFromSuperview() {
        super.removeFromSuperview()
        self.kf.cancelImageDownloadTask()
    }

    public init(width:CGFloat){
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: width))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public enum BMUploadBtnPosition {
    case front
//    case back
}

public protocol MultiImgChooseViewDelegate{
    func multiImgChooseView(imgHadChange view:MultiImgChooseView)
}

public class MultiImgChooseView: UIView {

    /// 图片间隔
    public var imgBlock    :CGFloat = 12.0
    /// 每行个数
    public var numEachRow  :Int = 4
    /// 图片最大个数
    public var maxNum      :Int = 8
    /// 上传按钮 位置
    public var uploadAtFront :BMUploadBtnPosition = .front

    public var delegate :MultiImgChooseViewDelegate?

    public var imgUrlArray:Array<String>{
        var arr = Array<String>()
        for btn in imgBtnArray{
            if let url = btn.imgUrl{
                arr.append(url)
            }
        }
        return arr
    }

    /// 拼接 图片地址 为string 供接口上传用
    public var imgUrlArrayString:String{
        var str = ""
        for btn in imgBtnArray{
            if let url = btn.imgUrl{
                if str.count == 0{
                    str.append(url)
                }else{
                    str.append(",")
                    str.append(url)
                }
            }
        }
        return str
    }

    ///计算属性 按钮宽度
    public var imgW: CGFloat {
        let w = self.w > 0 ? self.w : KScreenWidth
        return (w - imgBlock) / CGFloat(numEachRow) - imgBlock
    }

    //是否有按钮在上传
    public var isUploading:Bool{
        for btn in imgBtnArray{
            if btn.isUploading == true{
                return true
            }
        }
        return false
    }

    //所有按钮地址
    public var imgBtnArray = Array<BMImgItems>()

    lazy private var uploadBtn: BMImgItems = BMImgItems(width: self.imgW)


    //初始化的时候 调用
    public func reload(imgURLArray:Array<String>?) {
        let tempImgURLArray = imgURLArray ?? Array<String>()

        var needBtnNum = imgURLArray?.count ?? 0
        //已经上传 满
        if needBtnNum >= maxNum{
            needBtnNum = maxNum
        }else{//未上传满的  添加一个 上传 按钮
            needBtnNum = needBtnNum+1
        }

        //凑齐不够的按钮
        while imgBtnArray.count < needBtnNum {
            let btn = self.createBtn()
            self.imgBtnArray.append(btn)
        }
        //删除多余的
        while imgBtnArray.count > needBtnNum{
            self.imgBtnArray.removeLast()
        }

        //遍历 设置图片
        for (index, btn) in imgBtnArray.enumerated(){
            if (uploadAtFront == .front){
                if index == 0 && imgBtnArray.count != imgURLArray?.count{
                    btn.setUploadImg()
                }else{
                    if imgBtnArray.count != imgURLArray?.count{
                        btn.setImg(tempImgURLArray[index-1])
                    }else{
                        btn.setImg(tempImgURLArray[index])
                    }
                }
            }else{
                if index == tempImgURLArray.count{
                    btn.setUploadImg()
                }else{
                    btn.setImg(tempImgURLArray[index])
                }
            }
        }
        updatePosition()
    }

    //刷新位置
    func updatePosition() {
        //遍历
        for (index, btn) in imgBtnArray.enumerated(){
            btn.tag = index
            btn.deleteBtn.tag = index
            //移动
            UIView.animate(withDuration: 0.2, animations: {
                btn.frame = self.getRectWithIndex(index)
            })
        }
        if let vc = self.delegate{
            vc.multiImgChooseView(imgHadChange: self)
        }
    }


    private func getRectWithIndex(_ index: Int) -> CGRect {
        let x = imgBlock + CGFloat(index % numEachRow)*(imgBlock+imgW)
        let y = CGFloat(index / numEachRow)*(imgBlock+imgW)
        return CGRect(x: x, y: y, width: self.imgW, height: self.imgW)
    }
    // 添加图片按钮事件
    @objc private func addImgAction(_ btn:BMImgItems){
        if btn.deleteBtn.isHidden != true{
            return
        }
        if let vc = delegate as? UIViewController{
            let num = maxNum - imgBtnArray.count + 1
            vc.chooseMutiImg(num, {[weak self] (imgs) in
                //添加图片
                for img in imgs{
                    self?.addImg(img)
                }
                self?.updatePosition()
            })
        }
    }

    // 将新的图片加到显示中
    private func addImg(_ img:UIImage) {
        if self.imgBtnArray.count < self.maxNum{
            let btn = self.createBtn()
            btn.setImg(img)
            if self.uploadAtFront == .front{
                btn.frame = self.getRectWithIndex(1)
                self.imgBtnArray.insert(btn, at: 1)
            }else{
                
            }
        }
        else if self.imgBtnArray.count == self.maxNum{
            let btn:BMImgItems?
            if self.uploadAtFront == .front{
                btn = self.imgBtnArray[0]
            }else{
                btn = self.imgBtnArray[self.maxNum-1]
            }
            btn?.setImg(img)
        }
    }

    private func createBtn() -> BMImgItems {
        let btn = BMImgItems(width: self.imgW)
        btn.deleteBtn .addTarget(self, action: #selector(MultiImgChooseView.deleteImgAction(_:)), for: .touchUpInside)
        btn.adjustsImageWhenHighlighted = false
        btn.backgroundColor = .KBGGray
        btn.addTarget(self, action: #selector(MultiImgChooseView.addImgAction(_:)), for: .touchUpInside)
        btn.layer.borderWidth = 0.5
        btn.layer.borderColor = UIColor.KBGGrayLine.cgColor
        self.addSubview(btn)
        return btn
    }


    @objc func deleteImgAction(_ btn:UIButton){
        let item = imgBtnArray[btn.tag]
        imgBtnArray.remove(at: btn.tag)
        UIView.animate(withDuration: 0.1, animations: {
            item.alpha = 0
        }) { (_) in
            item.removeFromSuperview()
        }
        //补回 上传 按钮
        if self.uploadAtFront == .front{
            if imgBtnArray.first?.deleteBtn.isHidden != true{
                let btn = self.createBtn()
                btn.setUploadImg()
                imgBtnArray.insert(btn, at: 0)
            }
        }
//        if self.uploadAtFront == .back{
//            if imgBtnArray.last?.deleteBtn.isHidden != true{
//                let btn = self.createBtn()
//                btn.setUploadImg()
//                imgBtnArray.insert(btn, at: maxNum-1)
//            }
//        }

        self.updatePosition()
    }






}

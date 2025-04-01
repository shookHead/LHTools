//
//  WorkModel.swift
//  ShuHua
//
//  Created by clh on 2022/9/7.
//



import Foundation
import LHTools
import UIKit
class WorkModel :SmartCodable,Equatable{
//    static func == (lhs: WorkModel, rhs: WorkModel) -> Bool {
//        var lhsHasher = Hasher()
//        var rhsHasher = Hasher()
//        lhs.hash(into: &lhsHasher)
//        rhs.hash(into: &rhsHasher)
//        return lhsHasher.finalize() == rhsHasher.finalize()
//    }
    static func == (lhs: WorkModel, rhs: WorkModel) -> Bool {
        return lhs.userId == rhs.userId && lhs.drawWorkId == rhs.drawWorkId
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(drawWorkId)
    }
    var isSelected = false
    ///10.风格画  30 AI画   40.水印照片  100.拍摄作品 110.相册作品  210.使用权作品
    var workType: Int! = 0
    ///作者id
    var creatorUserId:String! = ""
    ///是否请求过图片的高度
    var isreqsut :Bool! = false
    var image_H :CGFloat! = 0
    
    var index:Int!
    var nickName : String! = ""
//    var image_mo : UIImage! = nil
    ///作者的头像
    var headLogo  : String! = ""
    ///(null)
    var drawWorkId  : Int! = 0
    ///用户
    var userId  : String! = ""
    ///(null)
    var drawStyleId  : Int! = 0
    ///作品标题
    var workTitle  : String! = ""
    ///作品包含信息
    var workMsg  : String! = ""
    ///作品寓意
    var workMean :String! = ""
    ///
    var workInputImage  : String! = ""
    ///创作图
    var workImage  : String! = ""
    ///创作高清图
    var workHdImage  : String! = ""
    ///数字指纹
    var digitalFingerprint  : String! = ""
    ///创作的状态 100. 创作中 199.创作失败 200.创作成功 300.完成创作
    var workResultStatus  : Int! = 0
    ///失败原因
    var workResultMsg  : String! = ""
    ///优先级
    var workPriority  : Int! = 0
    ///完成时间
    var finishTime  : String! = ""
    ///创作时间
    var createTime  : String! = ""
    ///是否拥有版权
    var isHasCopyright  : Int! = 0
    var itemWidth  : String! = ""
    var itemHeight  : String! = ""
    var itemSize:Double! = 0
    var itemHashCode:String! = ""
    ///是否收藏
    var isCollection :Bool! = false
    ///是否点赞
    var isLike :Bool! = false
    ///此值会依次取workHdImage    workImage   workInputImage
    var imgStr :String! = ""
    ///验真时可见
    var isOpenVerifyReadWorkMean  : Int! = 1
    ///阅后销毁
    var isOpenReadDestroyWorkMean  : Int! = 1
    ///是否开通商业授权
    var isOpenCommercialLicensing  : Int! = 0
    ///是否开通所有权价
    var isOpenOwnership  : Int! = 0
    ///所有权价
    var ownershipPrice  : Double! = 0
    ///授权价
    var licensingPrice  : Double! = 0
    ///是否发布过推荐
    var isApplyRecommend  : Int! = 0
    ///1. 公开  10. 私密
    var workLookAuthType :Int! = 1
    ///收藏数量
    var collectQuantity :Int! = 0
    ///人气(浏览量)
    var popularity :Int! = 0
    ///赞数
    var pollQuantity :Int! = 0
    var watermarkSecurityCode:String = ""
    func didFinishMapping() {
//        if !creatorUserId.notEmpty {
//            if let mod = cache[.userM],nickName.count == 0 {
//                nickName = mod.nickName
//            }
//        }

        imgStr = workHdImage
        if !imgStr.notEmpty {
            imgStr = workImage
        }
        if !imgStr.notEmpty {
            imgStr = workInputImage
        }
        isOpenCommercialLicensing = 0
        isOpenOwnership = 0
        itemHashCode = ""
    }
   
   
    required init() {}
}

//
//  ResourceModel.swift
//  wangfuAgent
//
//  Created by yimi on 2019/3/20.
//  Copyright © 2019 zhuanbangTec. All rights reserved.
//

import HandyJSON

class ResourceModel: HandyJSON {

    var id :Int!

    // 标题
    var newsTitle:String!
    // 摘要
    var newsSummary:String!
    // 内容模式 1.文章类  2.视频类  3.文档类
    var contentType:Int!
    
    var newsImage:String!   //新闻主图
    var newsContent:String! //新闻内容
    var newsResUrl:String!  //新闻资源
    var newsResTime:Int!    //资源时长
    var newsUrl:String!     //新闻地址

    var outLink:String! // 资源地址
    
    // 自动读取outLink和newsResUrl种不为空的一项
    var resourceLink:String!{
        var temp = outLink
        if temp == nil || temp.bm_count == 0{
            temp = newsResUrl
        }
        return temp
    }
    
    var isOutNews:Int!// 0站内内容  1站外链接  优先读取这个字段
    var resSiteName:String!//来源站点
    
    var pageViews:Int!//浏览量
    var createTime:String!//创建时间

    // 用于缓存的名字
    var saveLocation:String{
        var fileName = id.toString() ?? ""
        fileName = fileName + (newsTitle ?? "")
        fileName = fileName.md5
        
        var fileType = "temp"
        var link = self.outLink
        if link.bm_count == 0{
            link = self.newsResUrl
        }
        if let type = link!.components(separatedBy: ".").last{
            fileType = type
        }
        let documnets = NSHomeDirectory() + "/Documents/" + fileName + "." + fileType
        return documnets
    }
    var cacheLocation:String{
        var fileName = id.toString() ?? ""
        fileName = fileName + (newsTitle ?? "")
        fileName = fileName.md5
        let documnets = NSHomeDirectory() + "/Documents/cache_" + fileName
        return documnets
    }
    
    // 保存的时间戳
    var saveTimeInterval:TimeInterval!
    
    /// 1:正在下载   0:等待下载   -1:暂停   40:-下载完成
    var cacheState:Int = 0

    var isShowed:Bool! = false //是否显示过
    
    /// 上次下载进度
    var writtenfileSize:Int64!
    var allFileSize:Int64!

    
    required init() {}
    
    func copy() -> ResourceModel {
        let model = ResourceModel()
        model.id = self.id
        model.newsTitle = self.newsTitle
        model.newsSummary = self.newsSummary
        model.contentType = self.contentType
        model.newsImage = self.newsImage
        model.newsContent = self.newsContent
        model.newsResUrl = self.newsResUrl
        model.newsResTime = self.newsResTime
        model.outLink = self.outLink
        model.isOutNews = self.isOutNews
        model.resSiteName = self.resSiteName
        model.pageViews = self.pageViews
        model.createTime = self.createTime
        model.saveTimeInterval = self.saveTimeInterval
        model.cacheState = self.cacheState
        return model
    }
}

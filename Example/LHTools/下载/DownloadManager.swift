//
//  DownloadManager.swift
//  wangfuAgent
//
//  Created by yimi on 2019/3/20.
//  Copyright © 2019 zhuanbangTec. All rights reserved.
//

import UIKit
import Alamofire
import SQLite
import UserNotifications

private class DownloadDB:NSObject {
    //单例模式
    static var shared = DownloadDB()
    
    var db:Connection!
    
    // 需要下载的队列
    var downLoadList:Array<ResourceModel>!
    
    override init() {
        super.init()
        
        downLoadList = cache[.resource_downloadArray] ?? []
    }
    
    func add(_ model:ResourceModel) -> ResourceModel?{
        //  查重
        for i in 0..<downLoadList.count {
            let res = downLoadList[i]
            if res.id == model.id{
                return res
            }
        }
        downLoadList.append(model)
        saveCache()
        return nil
    }
    
    func changeVal(id:Int,state:Int? = nil,witten:Int64? = nil,all:Int64? = nil) {
        for i in 0..<downLoadList.count {
            let res = downLoadList[i]
            if res.id == id{
                if state != nil{
                    res.cacheState = state!
                    if res.cacheState == 40{
                        res.saveTimeInterval = Date().timeIntervalSince1970
                    }
                }
                if witten != nil{
                    res.writtenfileSize = witten!
                }
                if all != nil{
                    res.allFileSize = all!
                }
            }
        }
        saveCache()
    }
    
    func find(_ id:Int) -> ResourceModel? {
        for i in 0..<downLoadList.count {
            let res = downLoadList[i]
            if res.id == id{
                return res
            }
        }
        return nil
    }
    
    func delete(_ id:Int!){
        if id == nil{
            return
        }
        var model: ResourceModel!
        for i in 0..<downLoadList.count {
            let res = downLoadList[i]
            if res.id == id{
                model = res
                downLoadList.remove(at: i)
                break
            }
        }
        if model == nil{
            return
        }
        try? FileManager.default.removeItem(atPath: model.cacheLocation)
        try? FileManager.default.removeItem(atPath: model.saveLocation)
        saveCache()
    }
    
    func saveCache(){
        cache[.resource_downloadArray] = downLoadList
    }
}


class DownloadManager: NSObject, URLSessionDelegate, URLSessionDownloadDelegate{
    //单例模式
    static var shared = DownloadManager()
    
    private var db = DownloadDB.shared
    
    // 需要下载的队列
    var loadingList:Array<ResourceModel>{
        var temp = Array<ResourceModel>()
        for i in db.downLoadList{
            if i.cacheState != 40{
                temp.append(i)
            }
        }
        return temp
    }
        
    // 已完成下载的资源
    var loadedList:Array<ResourceModel>{
        var temp = Array<ResourceModel>()
        for i in DownloadDB.shared.downLoadList{
            if i.cacheState == 40{
                temp.append(i)
            }
        }
        return temp
    }
    
    // 当前正在下载的资源
    weak var currentResource:ResourceModel?
    // 上一次接受数据的时间 用于计算速度
    var lastTime:TimeInterval?
    var lastWrite:Int64 = 0
    //  正在下载的进度回调
    var onProgress: ((Double,Double,Double) -> ())?
    
    var session:URLSession!
    var dataTask:URLSessionDownloadTask!
    
    
    // 开始或继续 下一个任务
    private func startNextTask(){
        if loadingList.count == 0{
            session.invalidateAndCancel()
            session = nil
            dataTask.cancel()
            dataTask = nil
            return}
        
        // 判断currentResource 与缓存中的数据是否一致
        var loadingModel:ResourceModel?
        for i in loadingList{
            if i.cacheState == 1{
                loadingModel = i
            }
        }
        if loadingModel == nil{
            currentResource = nil
            dataTask = nil
        }else{
            return
        }
        
        // 拿到第一个等待任务
        var resource:ResourceModel! = nil
        for i in 0..<loadingList.count{
            let temp = loadingList[i]
            if temp.cacheState != 0{
                continue
            }
            resource = temp
            break
        }
        
        if resource == nil{
            return
        }
        resource.cacheState = 1
        currentResource = resource
        
        let url = resource.resourceLink
        if url == nil{
            resource.cacheState = -1
            startNextTask()
        }
        
        let request = URLRequest(url: URL(string: url!.urlEncode!)!)
        if session == nil{
            let config = URLSessionConfiguration.background(withIdentifier: .backgroundSessionId)
            config.timeoutIntervalForRequest = 10
            session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        }
        lastWrite = 0
        lastTime = nil
        
        runInMainThread {
            //启动任务
            let path = self.currentResource!.cacheLocation
            if FileManager.default.fileExists(atPath: path){
                if let data = try? Data(contentsOf: URL(fileURLWithPath: path.urlEncode!)){
                    self.dataTask = self.session.downloadTask(withResumeData: data)
                }else{
                    self.dataTask = self.session.downloadTask(with: request)
                }
            }else{
                self.dataTask = self.session.downloadTask(with: request)
            }
            self.dataTask.resume()
            
            Noti.post(name: .download_Begin, object: self.currentResource)
        }
    }
    
    func runInMainThread(_ task:@escaping ()->()){
        if Thread.isMainThread{
            task()
        }else{
            DispatchQueue.main.async {
                task()
            }
        }
    }
    
    // 监听下载进度
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        if currentResource == nil{
            return
        }
        //获取进度
        var speed:Double = -1
        let now = Date().timeIntervalSince1970
        if lastTime != nil{
            if now - lastTime! > 0.8{
                speed = (Double)(totalBytesWritten - lastWrite)/( now - lastTime!)
                lastWrite = totalBytesWritten
                lastTime = now
            }
        }else{
            lastTime = now
        }
        let written = (Double)(totalBytesWritten)
        let total = (Double)(totalBytesExpectedToWrite)
        currentResource?.writtenfileSize = totalBytesWritten
        currentResource?.allFileSize = totalBytesExpectedToWrite
        
        print("time:",lastTime ?? ""," speed:", speed , " totalWritten:", totalBytesWritten)

        if let onProgress = onProgress {
            runInMainThread {
                onProgress(speed,written,total)
            }
        }
    }
    
    // 下载结束回调
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("下载结束")
        print("临时地址:\(location)")
        guard currentResource != nil else{
            return
        }
        let locationPath = location.path
        let toPath = currentResource!.saveLocation
        let id = currentResource!.id.toString()
        do {
            if FileManager.default.fileExists(atPath: toPath){
                try FileManager.default.removeItem(atPath: toPath)
            }
            try FileManager.default.moveItem(atPath: locationPath, toPath: toPath)
            print("文件保存到:\(toPath)")
        }catch{
            print(error)
        }
        
        // 下载队列中移除
        DownloadDB.shared.changeVal(id: self.currentResource!.id, state: 40)
        currentResource = nil
        lastTime = nil
        
        runInMainThread {
            // 发送页面刷新通知
            Noti.post(name: .download_Done, object: self.currentResource)
            if #available(iOS 10.0, *){
                let content = UNMutableNotificationContent()
                content.title = ""
                content.body = "下载完成"
                content.subtitle = ""
                content.sound = UNNotificationSound.default
                // 发送本地推送通知
                let req = UNNotificationRequest(identifier: id ?? "", content: content, trigger: nil)
                UNUserNotificationCenter.current().add(req, withCompletionHandler: { (_) in })
            }
            // 开始下一个任务
            self.startNextTask()
        }
    }
    
    //session完成事件
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        //主线程调用
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                //调用此方法告诉操作系统，现在可以安全的重新suspend你的app
                completionHandler()
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil{
//            let err = error! as NSError
//            if let data = err.userInfo[NSURLSessionDownloadTaskResumeData] as? Data{
//                if self.currentResource != nil{
//                    let url = URL(fileURLWithPath: self.currentResource!.saveLocation)
//                    try? data.write(to: url, options: Data.WritingOptions.atomic)
//                    runInMainThread {
//                        self.currentResource?.cacheState = -1
//                        self.currentResource = nil
//                        self.startNextTask()
//                    }
//                }
//            }else{
//                runInMainThread {
//                    DownloadDB.shared.changeVal(id: self.currentResource!.id, state: -1)
//                    self.currentResource = nil
//                    Hud.showText("下载失败")
//                    self.startNextTask()
//                    NotificationCenter.default.post(name: KNoti_Download_Begin, object: self.currentResource)
//                }
//            }
        }
    }
}


extension DownloadManager{
    /// 加入下载队列调用（暂停任务重启）
    @discardableResult
    func add(resource:ResourceModel) -> ResourceModel?{
        if let mod = DownloadDB.shared.add(resource){//存在重复任务
            if mod.cacheState == -1{
                mod.cacheState = 0
            }else{
                // 已经在下载 等待状态 或已完成状态
                return mod}
        }else{
            resource.cacheState = 0
        }
        startNextTask()
        return nil
    }
    
    /// 暂停
    func pause(resource:ResourceModel){
        DownloadDB.shared.changeVal(id: resource.id, state: -1)
        if currentResource == nil{
            return
        }
        if resource.id == currentResource!.id{
            dataTask.cancel { (data)in
                let url = URL(fileURLWithPath: resource.cacheLocation)
                if FileManager.default.fileExists(atPath: resource.cacheLocation){
                    try? FileManager.default.removeItem(atPath: resource.cacheLocation)
                }
                try? data?.write(to: url, options: Data.WritingOptions.atomic)
                self.currentResource = nil
                self.runInMainThread {
                    self.startNextTask()
                }
            }
        }
    }
    
    func pauseAll(){
        // 暂停进行中的任务
        if currentResource != nil{
            DownloadDB.shared.changeVal(id: currentResource!.id, state: -1)
            dataTask.cancel { (data) in
                let url = URL(fileURLWithPath: self.currentResource!.cacheLocation)
                if FileManager.default.fileExists(atPath: self.currentResource!.cacheLocation){
                    try? FileManager.default.removeItem(atPath: self.currentResource!.cacheLocation)
                }
                try? data?.write(to: url, options: Data.WritingOptions.atomic)
                self.currentResource = nil
            }
        }
        // 暂停队列中的所有任务
        for model in loadingList{
            if model.cacheState == 0{
                DownloadDB.shared.changeVal(id: model.id, state: -1)
            }
        }
        DownloadDB.shared.saveCache()
    }
    
    func find(_ id:Int) -> ResourceModel? {
        return DownloadDB.shared.find(id)
    }
    
    func delete(_ id:Int){
        
        DownloadDB.shared.delete(id)
    }
    
    func save(){
        DownloadDB.shared.saveCache()
    }
}






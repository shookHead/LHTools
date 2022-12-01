//
//  Network.swift
//  wenzhuan
//
//  Created by zbkj on 2020/5/21.
//  Copyright © 2020 baymax. All rights reserved.
//

import Foundation
import Alamofire
public let network = BMNetwork()

public class HTMLString {}

public enum RequestError : Int{
    case cancel            = -999
    case timeOut            = -1001
    case requestFalid       = -1002
    case serverConnectFalid = -1003
    case noNetwork          = -1009
    case jsonDeserializeFalid   = -2003
    case responsDeserializeFalid   = -2004
    case noMsg  = -9998
    case unknow = -9999

    var msg :String{
        switch  self {
        case .cancel:
            return "请求被取消"
        case .timeOut:
            return "请求超时"
        case .requestFalid:
            return "请求地址无效"
        case .serverConnectFalid:
            return "服务器无法访问"
        case .noNetwork:
            return "无法访问网络"
        case .jsonDeserializeFalid:
            return "数据解析失败"
        case .responsDeserializeFalid:
            return "数据解析失败"
        case .noMsg:
            return ""
        case .unknow:
            return "请求失败"
        }
    }
}


///     配置示例：
///
///     //服务器地址
///     public class WangFuApi<ValueType> : BMApiTemplete<ValueType> {
///         var host: String = "http://163.gg"
///     }
///     //接口
///     extension BMApiSet {
///         static let login = WangFuApi<LoginModel?>("/api/login")
///         static let list = WangFuApi<Array<LoginModel>?>("/api/list")
///     }
///
///     使用：
///     network[.login].request(params: nil) { (resp) in
///         if resp?.code == 1{
///             let model = resp?.data
///             print("\(model)")
///         }
///      }
///     再也不用在调方法的时候传 Model.self 了
///
///

// MARK: -  ---------------------- 需要重写或者扩展的 ------------------------

// 外部用来 extension 该类 添加接口
open class BMApiSet {
    fileprivate init() {}
}

//
open class BMApiTemplete<ValueType> : BMApiSet{

    open var method: HTTPMethod = .post

    open var host: String{
        return ""
    }

    let url: String

    open var urlWithHost:String{
        return self.host + self.url
    }
    
    open var defaultParam:Dictionary<String, Any> {
        return ["pfDevice":"iPhone","pfAppVersion":Utils.appCurVersion]
    }
    
    public init(_ url: String) {
        self.url = url
        super.init()
    }
}


// MARK: -  ---------------------- 实现 network[.接口] 的调用方式------------------------
public class BMNetwork{
    
    //超时时间,可以通过 BMNetwork.timeout = “”修改
    public static var timeout:TimeInterval = 30
    public static var quality:TimeInterval = 0.3
    
    static var sessionManager: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        return Session.init(configuration: configuration, delegate: SessionDelegate.init())
    }()
    
    
    //可以通过 BMNetwork.imgUplodeApi = “”修改
    public static var imgUplodeApi = "https://img.163.gg/YmUpload_image"
    public static var videoUplodeApi = "https://img.163.gg/YmUpload_videoFile"

    public func upload(_ img:UIImage, uploading:((_ progress:Double) -> ())?, finish: @escaping (_ imgUrl:String?)->()){
        let newImg = img.fixOrientation()//防止图片被旋转
        let api = BMNetwork.imgUplodeApi
        let imageData = newImg.jpegData(compressionQuality: BMNetwork.quality)
        let name = "\(Date().toTimeInterval())" + ".jpeg"
        let request = AF.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(imageData!, withName: "file", fileName: name, mimeType: "image/jpeg")
        }, to: api, method: .post)
        request.uploadProgress { (progress) in
            DispatchQueue.global().async {
                uploading?(progress.fractionCompleted)
                print("progress",progress.fractionCompleted)
            }
        }
        request.responseJSON { (response) in
            DispatchQueue.global().async {
                switch response.result {
                case .success:
                    DispatchQueue.main.async {
                        var url:String!
                        defer {
                            finish(url)
                        }
                        let json = String(data: response.data!, encoding: String.Encoding.utf8)
                        if let resp = JSONDeserializer<ZBJsonDic>.deserializeFrom(json: json)  {
                            if resp.code == 1{
                                let data = resp.data
                                if let urlStr = data?["url"] as? String{
                                    print(urlStr)
                                    url = urlStr
                                }
                            }
                        }
                    }
                    
                case .failure:
                    let statusCode = response.response?.statusCode
                    print(response.response as Any,statusCode as Any)
                    finish(nil)
                }
            }
        }
    }
    
    public func uploadVideo(_ file:String, uploading:((_ progress:Double) -> ())?, finish: @escaping (_ fileUrl:String?)->()){
        guard let fileData = FileManager.default.contents(atPath: file) else {
            finish(nil)
            return
        }
        let api = BMNetwork.videoUplodeApi
        let name = "\(Date().toTimeInterval())" + ".mp4"
        let request = AF.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(fileData, withName: "file", fileName: name, mimeType: "video/mp4")
        }, to: api, method: .post)
        request.uploadProgress { (progress) in
            DispatchQueue.global().async {
                uploading?(progress.fractionCompleted)
                print("progress",progress.fractionCompleted)
            }
        }
        request.responseJSON { (response) in
            DispatchQueue.global().async {
                switch response.result {
                case .success:
                    DispatchQueue.main.async {
                        var url:String!
                        defer {
                            finish(url)
                        }
                        let json = String(data: response.data!, encoding: String.Encoding.utf8)
                        if let resp = JSONDeserializer<ZBJsonDic>.deserializeFrom(json: json)  {
                            if resp.code == 1{
                                let data = resp.data
                                if let urlStr = data?["url"] as? String{
                                    print(urlStr)
                                    url = urlStr
                                }
                            }
                        }
                    }
                    
                case .failure:
                    let statusCode = response.response?.statusCode
                    print(response.response as Any,statusCode as Any)
                    finish(nil)
                }
            }
        }
    }
    public subscript<T:HandyJSON>(key: BMApiTemplete<T?>) -> BMRequester_Model<T> {
        get { return BMRequester_Model(key)}
        set { }
    }
    
    public subscript<T:HandyJSON>(key: BMApiTemplete<Array<T>?>) -> BMRequester_ModelList<T> {
        get { return BMRequester_ModelList(key)}
        set { }
    }
    
    public subscript(key: BMApiTemplete<Int?>) -> BMRequester_Int {
        get { return BMRequester_Int(key)}
        set { }
    }
    
    public subscript(key: BMApiTemplete<String?>) -> BMRequester_String {
        get { return BMRequester_String(key)}
        set { }
    }
    public subscript(key: BMApiTemplete<Dictionary<String,Any>?>) -> BMRequester_Dic {
        get { return BMRequester_Dic(key)}
        set { }
    }
    
    public subscript(key: BMApiTemplete<HTMLString?>) -> BMRequester_Json {
        get { return BMRequester_Json(key)}
        set { }
    }
    
    
}


// MARK: -  ---------------------- 基础请求类 ------------------------

public class BMRequester{
    // 打印错误
    private func getApiGetUrl(_ url:String, _ params:[String:Any]) -> String{
        var allUrl = url
        if params.keys.count != 0{
            var count = 0
            for key in params.keys{
                if count == 0{
                    allUrl = allUrl + "?"
                }else{
                    allUrl = allUrl + "&"
                }
                let val = params[key]
                let valStr = String(describing: val!)
                allUrl = allUrl + "\(key)=\(valStr)"
                count += 1
            }
        }
        return allUrl
    }
    
    func handelResponce(code:Int?){
        var msg = ""
        // 重新登录
        if let _ = cache[.sessionId]{
            msg = "登录失效，请重新登录"
        }else{
            msg = "未登录，请登录"
        }
        if code == 2{
            Hud.showText(msg)
            Hud.runAfterHud {
                noti.post(name: .needRelogin, object: nil)
            }
        }
    }

    /// 最基础的请求 返回Json
    /// - Parameters:
    ///   - url: url description
    ///   - method: method description
    ///   - params: params description
    ///   - finish: finish description
    @discardableResult
    public func requestJson(_ url:String, method:HTTPMethod, params:[String:Any], finish: @escaping (_ code:Int, _ resp:String?)->())  -> DataRequest{
        var dic = params
        if let session = cache[.sessionId]{
            dic["sessionId"] = session
            dic["userId"] = cache[.userId]
        }
        return BMNetwork.sessionManager.request(url, method: method, parameters: dic).responseString { (response) in
            /// 打印请求接口
            print("----------------------")
            print("\(self.getApiGetUrl(url, dic))")
            
            switch response.result{
                case .success(let jsonStr):
                    finish(1,jsonStr)
                case  .failure(let error):
                    let err = BMRequester.bundleError(error as NSError)
                    
                    print(" ***** 请求失败： ***** ")
                    print("\(error)")
                    finish(err.rawValue, nil)
            }
        }
    }
    
    
    static func bundleError(_ err:NSError) -> RequestError{
        switch err.code{
        case -999:
            return .cancel
        case -1001:
            return .timeOut
        case -1002:
            return .requestFalid
        case -1003:
            return .serverConnectFalid
        case -1009:
            return .noMsg
        case 4:
            return .responsDeserializeFalid
        default:
            print("未处理的 error code:\(err.code)\n \(err)")
            return .unknow

        }
    }
    
}

// MARK: -  ---------------------- 封装了返回类型的请求类 ------------------------
public class BMRequester_Model<T:HandyJSON>: BMRequester{

    var api:BMApiTemplete<T?>

    public init(_ api:BMApiTemplete<T?>) {
        self.api = api
    }
    
    /// 返回 HandyJSON 对象
    /// - Parameters:
    ///   - params: 参数
    ///   - finish: 回调
    @discardableResult
    public func request(params:[String:Any]? = nil, finish: @escaping (_ resp:ZBJsonModel<T>?)->()) -> DataRequest{
        let url = api.host + api.url
        var withDefault = params ?? [:]
        for (key,value) in api.defaultParam{
            withDefault[key] = value
        }
        
        return self.requestJson(url, method: api.method, params: withDefault) { (code,jsonStr) in
            if jsonStr == nil{
                let err = ZBJsonModel<T>()
                err.code = code
                err.msg = "网络异常，请求失败"
                finish(err)
                return
            }
            let mod = JSONDeserializer<ZBJsonModel<T>>.deserializeFrom(json: jsonStr)
            if mod != nil{
                print("code:\(mod!.code ?? -99)")
                print("msg:\(mod!.msg ?? "")")
                print("data:\(jsonStr ?? ""))")
                finish(mod)
                if params != nil && params!["needOperationLogin"] != nil{
                    return
                }
                self.handelResponce(code: mod?.code)
            }else{
                print(" ***** 解析失败： ***** ")
                if jsonStr != nil{
                    print(jsonStr!)
                }else{
                    print("解析失败")
                }
                let err = ZBJsonModel<T>()
                err.code = RequestError.responsDeserializeFalid.rawValue
                err.msg = "网络异常，请求失败"
                finish(err)
            }
        }
    }
    
    
}

public class BMRequester_ModelList<T:HandyJSON> : BMRequester{

    var api: BMApiTemplete<Array<T>?>

    init(_ api: BMApiTemplete<Array<T>?>) {
        self.api = api
    }
    /// 返回 HandyJSON 对象数组
    /// - Parameters:
    ///   - params: 参数
    ///   - finish: 回调
    @discardableResult
    public func request(params:[String:Any]? = nil, finish: @escaping (_ resp:ZBJsonArrayModel<T>?)->()) -> DataRequest{
        let url = api.host + api.url
        var withDefault = params ?? [:]
        for (key,value) in api.defaultParam{
            withDefault[key] = value
        }
        return self.requestJson(url, method: api.method, params: withDefault) { (code,jsonStr) in
            if jsonStr == nil{
                let err = ZBJsonArrayModel<T>()
                err.code = code
                err.msg = "网络异常，请求失败"
                finish(err)
                return
            }
            var mod = JSONDeserializer<ZBJsonArrayModel<T>>.deserializeFrom(json: jsonStr)
            // 为其他App做适配，外面不套ZBJson***再解析一次
            if mod == nil{
                if let data = [T].deserialize(from: jsonStr) as? [T]{
                    mod = ZBJsonArrayModel<T>()
                    mod?.code = 1
                    mod?.data = data
                }
            }
            
            if mod != nil{
                print("code:\(mod!.code ?? -99)")
                print("msg:\(mod!.msg ?? "")")
                print("data:\(String(describing: jsonStr!)))")
                finish(mod)
                if params != nil && params!["needOperationLogin"] != nil{
                    return
                }
                self.handelResponce(code: mod?.code)
            }else{
                print(" ***** 解析失败： ***** ")
                if jsonStr != nil{
                    print(jsonStr!)
                }else{
                    print("请求失败")
                }
                let err = ZBJsonArrayModel<T>()
                err.code = RequestError.responsDeserializeFalid.rawValue
                err.msg = "网络异常，请求失败"
                finish(err)
            }
        }
    }
}

public class BMRequester_Int : BMRequester{

    var api: BMApiTemplete<Int?>

    init(_ api: BMApiTemplete<Int?>) {
        self.api = api
    }
    /// 返回 HandyJSON 对象数组
    /// - Parameters:
    ///   - params: 参数
    ///   - finish: 回调
    @discardableResult
    public func request(params:[String:Any]? = nil, finish: @escaping (_ resp:ZBJsonInt?)->()) -> DataRequest{
        let url = api.host + api.url
        var withDefault = params ?? [:]
        for (key,value) in api.defaultParam{
            withDefault[key] = value
        }
        return self.requestJson(url, method: api.method, params: withDefault) { (code,jsonStr) in
            let mod = JSONDeserializer<ZBJsonInt>.deserializeFrom(json: jsonStr)
            if mod != nil{
                print("code:\(mod!.code ?? -99)")
                print("msg:\(mod!.msg ?? "")")
                print("data:\(String(describing: jsonStr!)))")
                finish(mod)
                if params != nil && params!["needOperationLogin"] != nil{
                    return
                }
                self.handelResponce(code: mod?.code)
            }else{
                print(" ***** 解析失败： ***** ")
                if jsonStr != nil{
                    print(jsonStr!)
                }else{
                    print("请求失败")
                }
                let err = ZBJsonInt()
                err.code = RequestError.responsDeserializeFalid.rawValue
                err.msg = "网络异常，请求失败"
                finish(err)
            }
        }
    }
}

public class BMRequester_String : BMRequester{
    var api: BMApiTemplete<String?>
    init(_ api: BMApiTemplete<String?>) {
        self.api = api
    }
    
    /// 返回 HandyJSON 对象数组
    /// - Parameters:
    ///   - params: 参数
    ///   - finish: 回调
    @discardableResult
    public func request(params:[String:Any]? = nil, finish: @escaping (_ resp:ZBJsonString?)->()) -> DataRequest{
        let url = api.host + api.url
        var withDefault = params ?? [:]
        for (key,value) in api.defaultParam{
            withDefault[key] = value
        }
        return self.requestJson(url, method: api.method, params: withDefault) { (code,jsonStr) in
            let mod = JSONDeserializer<ZBJsonString>.deserializeFrom(json: jsonStr)
            if mod != nil{
                print("code:\(mod!.code ?? -99)")
                print("msg:\(mod!.msg ?? "")")
                print("data:\(String(describing: jsonStr!)))")
                finish(mod)
                if params != nil && params!["needOperationLogin"] != nil{
                    return
                }
                self.handelResponce(code: mod?.code)
            }else{
                print(" ***** 解析失败： ***** ")
                if jsonStr != nil{
                    print(jsonStr!)
                }else{
                    print("请求失败")
                }
                let err = ZBJsonString()
                err.code = RequestError.responsDeserializeFalid.rawValue
                err.msg = "网络异常，请求失败"
                finish(err)
            }
        }
    }
    
    
}

public class BMRequester_Dic : BMRequester{
    var api: BMApiTemplete<Dictionary<String,Any>?>
    init(_ api: BMApiTemplete<Dictionary<String,Any>?>) {
        self.api = api
    }
    
    /// 返回 HandyJSON 字典
    /// - Parameters:
    ///   - params: 参数
    ///   - finish: 回调
    @discardableResult
    public func request(params:[String:Any]? = nil, finish: @escaping (_ resp:ZBJsonDic?)->()) -> DataRequest{
        let url = api.host + api.url
        var withDefault = params ?? [:]
        for (key,value) in api.defaultParam{
            withDefault[key] = value
        }
        return self.requestJson(url, method: api.method, params: withDefault) { (code,jsonStr) in
            let mod = JSONDeserializer<ZBJsonDic>.deserializeFrom(json: jsonStr)
            if mod != nil{
                print("code:\(mod!.code ?? -99)")
                print("msg:\(mod!.msg ?? "")")
                print("data:\(String(describing: jsonStr!)))")
                finish(mod)
                if params != nil && params!["needOperationLogin"] != nil{
                    return
                }
                self.handelResponce(code: mod?.code)
            }else{
                print(" ***** 解析失败： ***** ")
                if jsonStr != nil{
                    print(jsonStr!)
                }else{
                    print("请求失败")
                }
                let err = ZBJsonDic()
                err.code = RequestError.responsDeserializeFalid.rawValue
                err.msg = "网络异常，请求失败"
                finish(err)
            }
        }
    }
}


public class BMRequester_Json : BMRequester{
    var api: BMApiTemplete<HTMLString?>
    init(_ api: BMApiTemplete<HTMLString?>) {
        self.api = api
    }
    
    @discardableResult
    public func requestJson(params:[String:Any]? = nil, finish: @escaping (_ json:String?)->()) -> DataRequest {
        let url = api.host + api.url
        var withDefault = params ?? [:]
        for (key,value) in api.defaultParam{
            withDefault[key] = value
        }
        return self.requestJson(url, method: api.method, params: withDefault)  { (code,jsonStr) in
            finish(jsonStr)
        }
    }
}

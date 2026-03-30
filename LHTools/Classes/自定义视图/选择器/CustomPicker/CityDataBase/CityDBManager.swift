

//import UIKit
//import SQLite
//
//public struct Address {
//    public var ID:Int64?
//    public var name:String?
//    public var shortName:String?
//}
//class LHCityModel: SmartCodableX {
//    
//    public var ID:Int64?
//    public var name:String?
//    public var shortName:String?
//    required init() {}
//}
//
//public class CityDBManager {
//
//    public var db:Connection!
//    //表
//    private let provinces = Table("province")
//    private let citys = Table("city")
//    private let districts = Table("district")
//
//    var provincesArr:[LHCityModel] = []
//    var citysArr:[LHCityModel] = []
//    var districtsArr:[LHCityModel] = []
//    public static let share:CityDBManager = {
//        let manager = CityDBManager()
//        return manager
//    }()
//
//    init() {
//        if let path = Bundle.main.path(forResource: "city.sqlite", ofType: "") {
//            db = try! Connection(path, readonly: true)
//            print("拿到city地址\(path)")
//        }
////        if let path = Bundle.main.path(forResource: "mei.mp3", ofType: "") {
////            print("拿到mp3地址\(path)")
////        }
////        if let path = Bundle.main.path(forResource: "BMback_Icon.png", ofType: "") {
////            print("拿到图片地址\(path)")
////        }
//    }
//    public func requestData() {
//        var params = Dictionary<String,Any>()
//        params["userId"] = "328682"
//        params["sessionId"] = "2FBF3F67E71F2E06ACE16F8ABBCF1E6A"
//        network[.Place_provinceList].request(params: params) { [self] resp in
//            if resp?.code == 1{
//                guard let arr = resp?.data else {
//                    return
//                }
//                provincesArr = arr
//            }
//        }
//    }
//    func requestCity(provinceId:Int) {
//        var params = Dictionary<String,Any>()
//        params["provinceId"] = provinceId
//        network[.Place_cityList].request(params: params) { [self] resp in
//            if resp?.code == 1{
//                guard let arr = resp?.data else {
//                    return
//                }
//                provincesArr = arr
//            }
//        }
//    }
//    func requestDistricts(cityId:Int) {
//        var params = Dictionary<String,Any>()
//        params["cityId"] = cityId
//        network[.Place_districtList].request(params: params) { [self] resp in
//            if resp?.code == 1{
//                guard let arr = resp?.data else {
//                    return
//                }
//                districtsArr = arr
//            }
//        }
//    }
//    public func getAddressModel(_ provinceId:Int64!,_ cityId:Int64!,_ districtsId:Int64!) -> Array<Address>{
//        var result = Array<Address>()
//        var list = getProvinceList()
//        for m in list{
//            if m.ID == provinceId{
//                result.append(m)
//                break
//            }
//        }
//        if cityId != nil{
//            list = getCityList(provinceId)
//            for m in list{
//                if m.ID == cityId{
//                    result.append(m)
//                    break
//                }
//            }
//        }
//        if districtsId != nil{
//            list = getDistrictList(cityId)
//            for m in list{
//                if m.ID == districtsId{
//                    result.append(m)
//                    break
//                }
//            }
//        }
//        return result
//    }
//
//    public func getProvinceList() -> Array<Address> {
//        var provinceArray = Array<Address>()
//        
//        let id = SQLite.Expression<Int64?>( "id")
//        let name = SQLite.Expression<String?>( "provincename")
//        let shortname = SQLite.Expression<String?>( "shortname")
//
//        let query = try! db.prepare(provinces)
//        for user in query {
//            do {
//                var model = Address()
////                let aa = try user.get(id)
//                model.ID        = try user.get(id)
//                model.name      = try user.get(name)
//                model.shortName = try user.get(shortname)
//                provinceArray.append(model)
//            } catch {
//                print(error)
//                return Array<Address>()
//            }
//        }
//        return provinceArray
//    }
//
//    public func getCityList(_ chooseProvinceid:Int64) -> Array<Address> {
//        var cityArray = Array<Address>()
//
//        let provinceId = SQLite.Expression<Int64>( "provinceid")
//        let ID = SQLite.Expression<Int64>( "id")
//        let name = SQLite.Expression<String>( "cityName")
//        let shortname = SQLite.Expression<String>( "shortCityName")
//
//        let query = try! db.prepare(citys.filter(provinceId == chooseProvinceid))
//        for user in query {
//            do {
//                var model = Address()
//                model.ID        = try user.get(ID)
//                model.name      = try user.get(name)
//                model.shortName = try user.get(shortname)
//                cityArray.append(model)
//            } catch {
//                print(error)
//                return Array<Address>()
//            }
//        }
//        return cityArray
//    }
//
//    public func getDistrictList(_ chooseCityid:Int64) -> Array<Address> {
//        var districtArray = Array<Address>()
//
//        let provinceId = SQLite.Expression<Int64>( "cityId")
//        let ID = SQLite.Expression<Int64>( "id")
//        let name = SQLite.Expression<String>( "districtName")
//        let shortname = SQLite.Expression<String>( "districtName")
//
//        let query = try! db.prepare(districts.filter(provinceId == chooseCityid))
//        for user in query {
//            do {
//                var model = Address()
//                model.ID        = try user.get(ID)
//                model.name      = try user.get(name)
//                model.shortName = try user.get(shortname)
//                districtArray.append(model)
//            } catch {
//                print(error)
//                return Array<Address>()
//            }
//        }
//        return districtArray
//    }
//}
//
//
//// 易城市接口基类
//public class YCSApi<ValueType> : BMApiTemplete<ValueType> {
//    public override var host: String{
//        return "https://api.163.gg/"
//    }
//    public override var defaultParam: Dictionary<String, Any>{
//        let params = Dictionary<String,Any>()
//        return params
//    }
//}
//
///// 接口列表 <接口返回类型>(接口地址)
//extension BMApiSet {
//    static let Place_provinceList = YCSApi<Array<LHCityModel>?>("agentapi/Place_provinceList")
//    static let Place_cityList = YCSApi<Array<LHCityModel>?>("agentapi/Place_cityList")
//    static let Place_districtList = YCSApi<Array<LHCityModel>?>("agentapi/Place_districtList")
//}




//
//  CityDBManager.swift
//  wangfuAgent
//
//  Created by  on 2018/7/27.
//  Copyright © 2018 zhuanbangTec. All rights reserved.
//

import UIKit
import SQLite

public struct Address {
    public var ID:Int64?
    public var name:String?
    public var shortName:String?
}

public class CityDBManager {

    public var db:Connection!
    //表
    private let provinces = Table("province")
    private let citys = Table("city")
    private let districts = Table("district")

    public static let share:CityDBManager = {
        let manager = CityDBManager()
        return manager
    }()

    init() {
//        if let path = Bundle.current()?.path(forResource: "city_db", ofType: "sqlite") {
//            db = try! Connection(path, readonly: true)
//        }

        
        if let path = Bundle.main.path(forResource: "city_db", ofType: "sqlite") {
            db = try! Connection(path, readonly: true)
        }
    }

//    func getBundleResource(bundName: String, resourceName: String, ofType ext: String?) -> String? {
//        let resourcePath = bundleType == .otherBundle ? "Frameworks/\(bundName).framework/\(bundName)" : "\(bundName)"
//        guard let bundlePath = Bundle.main.path(forResource: resourcePath, ofType: "bundle"), let bundle = Bundle(path: bundlePath) else {
//            return nil
//        }
//        let imageStr = bundle.path(forResource: resourceName, ofType: ext)
//        return imageStr
//    }
    public func getAddressModel(_ provinceId:Int64!,_ cityId:Int64!,_ districtsId:Int64!) -> Array<Address>{
        var result = Array<Address>()
        var list = getProvinceList()
        for m in list{
            if m.ID == provinceId{
                result.append(m)
                break
            }
        }
        if cityId != nil{
            list = getCityList(provinceId)
            for m in list{
                if m.ID == cityId{
                    result.append(m)
                    break
                }
            }
        }
        if districtsId != nil{
            list = getDistrictList(cityId)
            for m in list{
                if m.ID == districtsId{
                    result.append(m)
                    break
                }
            }
        }
        return result
    }

    public func getProvinceList() -> Array<Address> {
        var provinceArray = Array<Address>()
        
        let id = SQLite.Expression<Int64?>( "id")
        let name = SQLite.Expression<String?>( "provincename")
        let shortname = SQLite.Expression<String?>( "shortname")

        let query = try! db.prepare(provinces)
        for user in query {
            do {
                var model = Address()
//                let aa = try user.get(id)
                model.ID        = try user.get(id)
                model.name      = try user.get(name)
                model.shortName = try user.get(shortname)
                provinceArray.append(model)
            } catch {
                print(error)
                return Array<Address>()
            }
        }
        return provinceArray
    }

    public func getCityList(_ chooseProvinceid:Int64) -> Array<Address> {
        var cityArray = Array<Address>()

        let provinceId = SQLite.Expression<Int64>( "provinceid")
        let ID = SQLite.Expression<Int64>( "id")
        let name = SQLite.Expression<String>( "cityName")
        let shortname = SQLite.Expression<String>( "shortCityName")

        let query = try! db.prepare(citys.filter(provinceId == chooseProvinceid))
        for user in query {
            do {
                var model = Address()
                model.ID        = try user.get(ID)
                model.name      = try user.get(name)
                model.shortName = try user.get(shortname)
                cityArray.append(model)
            } catch {
                print(error)
                return Array<Address>()
            }
        }
        return cityArray
    }

    public func getDistrictList(_ chooseCityid:Int64) -> Array<Address> {
        var districtArray = Array<Address>()

        let provinceId = SQLite.Expression<Int64>( "cityId")
        let ID = SQLite.Expression<Int64>( "id")
        let name = SQLite.Expression<String>( "districtName")
        let shortname = SQLite.Expression<String>( "districtName")

        let query = try! db.prepare(districts.filter(provinceId == chooseCityid))
        for user in query {
            do {
                var model = Address()
                model.ID        = try user.get(ID)
                model.name      = try user.get(name)
                model.shortName = try user.get(shortname)
                districtArray.append(model)
            } catch {
                print(error)
                return Array<Address>()
            }
        }
        return districtArray
    }
}


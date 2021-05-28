//
//  CityDBManager.swift
//  wangfuAgent
//
//  Created by lzw on 2018/7/27.
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
        if let path = Bundle(for: LHTools.self).resourcePath?.appending("/city_db.sqlite") {
            db = try! Connection(path, readonly: true)
        }
    }
    
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

        let id = Expression<Int64?>("id")
        let name = Expression<String?>("provincename")
        let shortname = Expression<String?>("shortname")

        let query = try! db.prepare(provinces)
        for user in query {
            do {
                var model = Address()
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

        let provinceId = Expression<Int64>("provinceid")
        let ID = Expression<Int64>("id")
        let name = Expression<String>("cityName")
        let shortname = Expression<String>("shortCityName")

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

        let provinceId = Expression<Int64>("cityId")
        let ID = Expression<Int64>("id")
        let name = Expression<String>("districtName")
        let shortname = Expression<String>("districtName")

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


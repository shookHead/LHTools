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

final class LHCityModel: SmartCodableX {
    public var ID:Int64?
    public var name:String?
    public var shortName:String?

    required init() {}
}

private final class LHProvinceResponseModel: SmartCodableX {
    public var provinceId: Int64?
    public var provincename: String?
    public var shortname: String?

    required init() {}
}

private final class LHCityResponseModel: SmartCodableX {
    public var cityId: Int64?
    public var cityName: String?
    public var shortCityName: String?

    required init() {}
}

private final class LHDistrictResponseModel: SmartCodableX {
    public var districtId: Int64?
    public var districtName: String?

    required init() {}
}

private final class YCSApi<ValueType>: BMApiTemplete<ValueType> {
    override var host: String {
        return "https://api.163.gg/"
    }
}

private extension BMApiSet {
    static let Place_provinceList = YCSApi<Array<LHProvinceResponseModel>?>("agentapi/Place_provinceList")
    static let Place_cityList = YCSApi<Array<LHCityResponseModel>?>("agentapi/Place_cityList")
    static let Place_districtList = YCSApi<Array<LHDistrictResponseModel>?>("agentapi/Place_districtList")
    static let Place_provinceListRaw = YCSApi<HTMLString?>("agentapi/Place_provinceList")
    static let Place_cityListRaw = YCSApi<HTMLString?>("agentapi/Place_cityList")
    static let Place_districtListRaw = YCSApi<HTMLString?>("agentapi/Place_districtList")
}

private extension BMDefaultsKeys {
    static let cityPickerLastFullSyncAt = BMCacheKey<String?>("city_picker_last_full_sync_at")
}

public class CityDBManager {

    public var db: Connection?

    private let provinces = Table("province")
    private let citys = Table("city")
    private let districts = Table("district")

    private let dbQueue = DispatchQueue(label: "com.lhtools.citypicker.sqlite")
    private let stateQueue = DispatchQueue(label: "com.lhtools.citypicker.state")
    private var isFullSyncing = false

    private static let syncInterval: TimeInterval = 7 * 24 * 60 * 60

    public static let share: CityDBManager = {
        let manager = CityDBManager()
        return manager
    }()

    init() {
        prepareDatabase()
        refreshAllDataIfNeeded()
    }

    public func forceRefreshAllData() {
        cache[.cityPickerLastFullSyncAt] = nil
        refreshAllDataIfNeeded(force: true)
    }

    public func getAddressModel(_ provinceId:Int64!,_ cityId:Int64!,_ districtsId:Int64!) -> Array<Address>{
        var result = Array<Address>()
        var list = getProvinceList()
        for m in list {
            if m.ID == provinceId {
                result.append(m)
                break
            }
        }
        if cityId != nil {
            list = getCityList(provinceId)
            for m in list {
                if m.ID == cityId {
                    result.append(m)
                    break
                }
            }
        }
        if districtsId != nil {
            list = getDistrictList(cityId)
            for m in list {
                if m.ID == districtsId {
                    result.append(m)
                    break
                }
            }
        }
        return result
    }

    public func getProvinceList() -> Array<Address> {
        return toAddressArray(fetchProvinceModels())
    }

    public func getCityList(_ chooseProvinceid:Int64) -> Array<Address> {
        return toAddressArray(fetchCityModels(provinceId: chooseProvinceid))
    }

    public func getDistrictList(_ chooseCityid:Int64) -> Array<Address> {
        return toAddressArray(fetchDistrictModels(cityId: chooseCityid))
    }
}

private extension CityDBManager {
    func prepareDatabase() {
        guard let localPath = Self.localDatabasePath() else { return }
        let fileManager = FileManager.default
        let localURL = URL(fileURLWithPath: localPath)
        let folderURL = localURL.deletingLastPathComponent()

        if !fileManager.fileExists(atPath: folderURL.path) {
            try? fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
        }

        if !fileManager.fileExists(atPath: localPath) {
            if let bundledPath = Self.bundledDatabasePath() {
                try? fileManager.copyItem(atPath: bundledPath, toPath: localPath)
            }
        }

        db = try? Connection(localPath)
        createTablesIfNeeded()
        restoreBundledDatabaseIfNeeded()
    }

    static func localDatabasePath() -> String? {
        let folder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent("LHTools/CityPicker", isDirectory: true)
        return folder?.appendingPathComponent("city.sqlite").path
    }

    static func bundledDatabasePath() -> String? {
        let resourceNames = ["city.sqlite", "city_db.sqlite"]
        let bundles = [
            Bundle.main,
            Bundle(for: CityDBManager.self)
        ]

        for bundle in bundles {
            for resourceName in resourceNames {
                let fileName = (resourceName as NSString).deletingPathExtension
                let fileExt = (resourceName as NSString).pathExtension
                if let path = bundle.path(forResource: fileName, ofType: fileExt) {
                    return path
                }
            }
        }

        if let resourcePath = Bundle(for: CityDBManager.self).resourcePath {
            let candidateBundles = [
                URL(fileURLWithPath: resourcePath).appendingPathComponent("LHTools.bundle"),
                URL(fileURLWithPath: resourcePath).appendingPathComponent("Frameworks/LHTools.framework/LHTools.bundle")
            ]
            for bundleURL in candidateBundles {
                if let bundle = Bundle(url: bundleURL) {
                    for resourceName in resourceNames {
                        let fileName = (resourceName as NSString).deletingPathExtension
                        let fileExt = (resourceName as NSString).pathExtension
                        if let path = bundle.path(forResource: fileName, ofType: fileExt) {
                            return path
                        }
                    }
                }
            }
        }

        return nil
    }

    func createTablesIfNeeded() {
        guard let db else { return }
        dbQueue.sync {
            try? db.run("CREATE TABLE IF NOT EXISTS province (id integer NOT NULL PRIMARY KEY, provincename text, shortname text)")
            try? db.run("CREATE TABLE IF NOT EXISTS city (id integer NOT NULL PRIMARY KEY, cityName text, shortCityName text, allspell text, domainName text, provinceid integer DEFAULT 0, isorder integer DEFAULT 0)")
            try? db.run("CREATE TABLE IF NOT EXISTS district (id integer NOT NULL PRIMARY KEY, districtName text DEFAULT NULL, cityId integer DEFAULT NULL)")
        }
    }

    func restoreBundledDatabaseIfNeeded() {
        guard !hasValidProvinceCache(),
              let localPath = Self.localDatabasePath(),
              let bundledPath = Self.bundledDatabasePath() else { return }

        db = nil
        let fileManager = FileManager.default
        try? fileManager.removeItem(atPath: localPath)
        try? fileManager.copyItem(atPath: bundledPath, toPath: localPath)
        db = try? Connection(localPath)
        createTablesIfNeeded()
    }

    func toAddressArray(_ models: [LHCityModel]) -> [Address] {
        return models.map { model in
            var address = Address()
            address.ID = model.ID
            address.name = model.name
            address.shortName = model.shortName
            return address
        }
    }

    func normalizedProvinceModels(_ models: [LHProvinceResponseModel]?) -> [LHCityModel] {
        return (models ?? []).compactMap { model in
            guard let id = model.provinceId else { return nil }
            let item = LHCityModel()
            item.ID = id
            item.name = model.provincename ?? model.shortname
            item.shortName = model.shortname ?? model.provincename
            return item
        }.sorted { ($0.ID ?? 0) < ($1.ID ?? 0) }
    }

    func normalizedCityModels(_ models: [LHCityResponseModel]?) -> [LHCityModel] {
        return (models ?? []).compactMap { model in
            guard let id = model.cityId else { return nil }
            let item = LHCityModel()
            item.ID = id
            item.name = model.cityName ?? model.shortCityName
            item.shortName = model.shortCityName ?? model.cityName
            return item
        }.sorted { ($0.ID ?? 0) < ($1.ID ?? 0) }
    }

    func normalizedDistrictModels(_ models: [LHDistrictResponseModel]?) -> [LHCityModel] {
        return (models ?? []).compactMap { model in
            guard let id = model.districtId else { return nil }
            let item = LHCityModel()
            item.ID = id
            item.name = model.districtName
            item.shortName = model.districtName
            return item
        }.sorted { ($0.ID ?? 0) < ($1.ID ?? 0) }
    }

    func dataArray(from json: String?) -> [[String: Any]] {
        guard let json, let jsonData = json.data(using: .utf8) else { return [] }
        let object = try? JSONSerialization.jsonObject(with: jsonData, options: [.fragmentsAllowed])
        if let dict = object as? [String: Any] {
            if let code = int64Value(dict["code"]), code != 1 {
                return []
            }
            return dict["data"] as? [[String: Any]] ?? []
        }
        return object as? [[String: Any]] ?? []
    }

    func int64Value(_ value: Any?) -> Int64? {
        switch value {
        case let number as NSNumber:
            return number.int64Value
        case let string as String:
            return Int64(string)
        default:
            return nil
        }
    }

    func stringValue(_ value: Any?) -> String? {
        switch value {
        case let string as String:
            return string
        case let number as NSNumber:
            return number.stringValue
        default:
            return nil
        }
    }

    func firstInt64Value(in dictionary: [String: Any], keys: [String]) -> Int64? {
        for key in keys {
            if let value = int64Value(dictionary[key]) {
                return value
            }
        }
        return nil
    }

    func firstStringValue(in dictionary: [String: Any], keys: [String]) -> String? {
        for key in keys {
            if let value = stringValue(dictionary[key]), !value.isEmpty {
                return value
            }
        }
        return nil
    }

    func normalizedProvinceModels(from dictionaries: [[String: Any]]) -> [LHCityModel] {
        return dictionaries.compactMap { dictionary in
            guard let id = firstInt64Value(in: dictionary, keys: ["id", "ID", "provinceId", "provinceid"]) else { return nil }
            let item = LHCityModel()
            item.ID = id
            item.name = firstStringValue(in: dictionary, keys: ["provincename", "provinceName", "name", "shortname", "shortName"])
            item.shortName = firstStringValue(in: dictionary, keys: ["shortname", "shortName", "shortProvinceName", "provincename", "provinceName", "name"]) ?? item.name
            return item
        }.sorted { ($0.ID ?? 0) < ($1.ID ?? 0) }
    }

    func normalizedCityModels(from dictionaries: [[String: Any]]) -> [LHCityModel] {
        return dictionaries.compactMap { dictionary in
            guard let id = firstInt64Value(in: dictionary, keys: ["id", "ID", "cityId", "cityid"]) else { return nil }
            let item = LHCityModel()
            item.ID = id
            item.name = firstStringValue(in: dictionary, keys: ["cityName", "cityname", "name", "shortCityName", "shortname", "shortName", "cityShortName"])
            item.shortName = firstStringValue(in: dictionary, keys: ["shortCityName", "shortname", "shortName", "cityShortName", "cityName", "cityname", "name"]) ?? item.name
            return item
        }.sorted { ($0.ID ?? 0) < ($1.ID ?? 0) }
    }

    func normalizedDistrictModels(from dictionaries: [[String: Any]]) -> [LHCityModel] {
        return dictionaries.compactMap { dictionary in
            guard let id = firstInt64Value(in: dictionary, keys: ["id", "ID", "districtId", "districtid"]) else { return nil }
            let item = LHCityModel()
            item.ID = id
            item.name = firstStringValue(in: dictionary, keys: ["districtName", "districtname", "name"])
            item.shortName = item.name
            return item
        }.sorted { ($0.ID ?? 0) < ($1.ID ?? 0) }
    }

    func requestProvinceModels(completion: @escaping ([LHCityModel]) -> Void) {
        network[.Place_provinceList].request { [weak self] resp in
            guard let self else {
                completion([])
                return
            }
            let models = self.normalizedProvinceModels(resp?.data)
            if !models.isEmpty {
                completion(models)
                return
            }
            network[.Place_provinceListRaw].requestJson { [weak self] json in
                guard let self else {
                    completion([])
                    return
                }
                completion(self.normalizedProvinceModels(from: self.dataArray(from: json)))
            }
        }
    }

    func requestCityModels(provinceId: Int64, completion: @escaping ([LHCityModel]) -> Void) {
        let params: [String: Any] = ["provinceId": provinceId]
        network[.Place_cityList].request(params: params) { [weak self] resp in
            guard let self else {
                completion([])
                return
            }
            let models = self.normalizedCityModels(resp?.data)
            if !models.isEmpty {
                completion(models)
                return
            }
            network[.Place_cityListRaw].requestJson(params: params) { [weak self] json in
                guard let self else {
                    completion([])
                    return
                }
                completion(self.normalizedCityModels(from: self.dataArray(from: json)))
            }
        }
    }

    func requestDistrictModels(cityId: Int64, completion: @escaping ([LHCityModel]) -> Void) {
        let params: [String: Any] = ["cityId": cityId]
        network[.Place_districtList].request(params: params) { [weak self] resp in
            guard let self else {
                completion([])
                return
            }
            let models = self.normalizedDistrictModels(resp?.data)
            if !models.isEmpty {
                completion(models)
                return
            }
            network[.Place_districtListRaw].requestJson(params: params) { [weak self] json in
                guard let self else {
                    completion([])
                    return
                }
                completion(self.normalizedDistrictModels(from: self.dataArray(from: json)))
            }
        }
    }

    func modelsEqual(_ lhs: [LHCityModel], _ rhs: [LHCityModel]) -> Bool {
        lhs.toJSONString() == rhs.toJSONString()
    }

    func fetchProvinceModels() -> [LHCityModel] {
        guard let db else { return [] }

        let id = SQLite.Expression<Int64?>("id")
        let name = SQLite.Expression<String?>("provincename")
        let shortname = SQLite.Expression<String?>("shortname")

        return dbQueue.sync {
            guard let query = try? db.prepare(provinces.order(id.asc)) else { return [] }
            return query.compactMap { user in
                let model = LHCityModel()
                model.ID = try? user.get(id)
                model.name = try? user.get(name)
                model.shortName = try? user.get(shortname)
                model.name = model.name ?? model.shortName
                return model.ID == nil ? nil : model
            }
        }
    }

    func fetchCityModels(provinceId currentProvinceId: Int64) -> [LHCityModel] {
        guard let db else { return [] }

        let provinceId = SQLite.Expression<Int64>("provinceid")
        let id = SQLite.Expression<Int64>("id")
        let name = SQLite.Expression<String>("cityName")
        let shortname = SQLite.Expression<String>("shortCityName")

        return dbQueue.sync {
            guard let query = try? db.prepare(citys.filter(provinceId == currentProvinceId).order(id.asc)) else { return [] }
            return query.compactMap { user in
                let model = LHCityModel()
                model.ID = try? user.get(id)
                model.name = try? user.get(name)
                model.shortName = try? user.get(shortname)
                model.name = model.name ?? model.shortName
                return model.ID == nil ? nil : model
            }
        }
    }

    func fetchDistrictModels(cityId currentCityId: Int64) -> [LHCityModel] {
        guard let db else { return [] }

        let cityId = SQLite.Expression<Int64>("cityId")
        let id = SQLite.Expression<Int64>("id")
        let name = SQLite.Expression<String>("districtName")

        return dbQueue.sync {
            guard let query = try? db.prepare(districts.filter(cityId == currentCityId).order(id.asc)) else { return [] }
            return query.compactMap { user in
                let model = LHCityModel()
                model.ID = try? user.get(id)
                model.name = try? user.get(name)
                model.shortName = try? user.get(name)
                return model.ID == nil ? nil : model
            }
        }
    }

    func replaceProvinceModels(_ models: [LHCityModel]) throws {
        guard let db else { return }

        let id = SQLite.Expression<Int64>("id")
        let name = SQLite.Expression<String?>("provincename")
        let shortname = SQLite.Expression<String?>("shortname")

        try db.run(provinces.delete())
        for model in models {
            guard let modelId = model.ID else { continue }
            try db.run(provinces.insert(or: .replace,
                                        id <- modelId,
                                        name <- model.name,
                                        shortname <- (model.shortName ?? model.name)))
        }
    }

    func replaceCityModels(_ models: [LHCityModel], provinceId currentProvinceId: Int64) throws {
        guard let db else { return }

        let provinceId = SQLite.Expression<Int64>("provinceid")
        let id = SQLite.Expression<Int64>("id")
        let name = SQLite.Expression<String?>("cityName")
        let shortname = SQLite.Expression<String?>("shortCityName")
        let allspell = SQLite.Expression<String?>("allspell")
        let domainName = SQLite.Expression<String?>("domainName")
        let isorder = SQLite.Expression<Int64>("isorder")

        try db.run(citys.filter(provinceId == currentProvinceId).delete())
        for model in models {
            guard let modelId = model.ID else { continue }
            try db.run(citys.insert(or: .replace,
                                    id <- modelId,
                                    name <- model.name,
                                    shortname <- (model.shortName ?? model.name),
                                    allspell <- nil,
                                    domainName <- nil,
                                    provinceId <- currentProvinceId,
                                    isorder <- 0))
        }
    }

    func replaceDistrictModels(_ models: [LHCityModel], cityId currentCityId: Int64) throws {
        guard let db else { return }

        let cityId = SQLite.Expression<Int64>("cityId")
        let id = SQLite.Expression<Int64>("id")
        let name = SQLite.Expression<String?>("districtName")

        try db.run(districts.filter(cityId == currentCityId).delete())
        for model in models {
            guard let modelId = model.ID else { continue }
            try db.run(districts.insert(or: .replace,
                                        id <- modelId,
                                        name <- (model.name ?? model.shortName),
                                        cityId <- currentCityId))
        }
    }

    func hasValidProvinceCache() -> Bool {
        let models = fetchProvinceModels()
        guard models.count >= 30 else { return false }
        return models.allSatisfy { !($0.name ?? $0.shortName ?? "").isEmpty }
    }

    func hasRecentFullSync() -> Bool {
        guard let value = cache[.cityPickerLastFullSyncAt], let lastSync = TimeInterval(value) else { return false }
        return Date().timeIntervalSince1970 - lastSync < Self.syncInterval
    }

    func markFullSyncSuccess() {
        cache[.cityPickerLastFullSyncAt] = String(Date().timeIntervalSince1970)
    }

    func refreshAllDataIfNeeded(force: Bool = false) {
        let shouldSync = stateQueue.sync { () -> Bool in
            if isFullSyncing { return false }
            if !force, hasRecentFullSync(), hasValidProvinceCache() { return false }
            isFullSyncing = true
            return true
        }
        guard shouldSync else { return }

        fetchAllRemoteData { [weak self] provinceModels, cityMap, districtMap in
            guard let self else { return }
            defer {
                self.stateQueue.async {
                    self.isFullSyncing = false
                }
            }

            guard !provinceModels.isEmpty else { return }

            self.dbQueue.async {
                guard let db = self.db else { return }
                do {
                    try db.transaction {
                        try self.replaceProvinceModels(provinceModels)
                        for (provinceId, cityModels) in cityMap {
                            try self.replaceCityModels(cityModels, provinceId: provinceId)
                        }
                        for (cityId, districtModels) in districtMap {
                            try self.replaceDistrictModels(districtModels, cityId: cityId)
                        }
                    }
                    self.markFullSyncSuccess()
                } catch {
                    print(error)
                }
            }
        }
    }

    func fetchAllRemoteData(completion: @escaping (_ provinces: [LHCityModel], _ cityMap: [Int64: [LHCityModel]], _ districtMap: [Int64: [LHCityModel]]) -> Void) {
        requestProvinceModels { [weak self] provinceModels in
            guard let self else {
                completion([], [:], [:])
                return
            }
            guard !provinceModels.isEmpty else {
                completion([], [:], [:])
                return
            }

            let provinceGroup = DispatchGroup()
            let cityStateQueue = DispatchQueue(label: "com.lhtools.citypicker.citysync")
            var cityMap: [Int64: [LHCityModel]] = [:]
            var districtMap: [Int64: [LHCityModel]] = [:]

            for province in provinceModels {
                guard let provinceId = province.ID else { continue }
                provinceGroup.enter()
                self.requestCityModels(provinceId: provinceId) { cityModels in
                    cityStateQueue.sync {
                        cityMap[provinceId] = cityModels
                    }

                    let districtGroup = DispatchGroup()
                    for city in cityModels {
                        guard let cityId = city.ID else { continue }
                        districtGroup.enter()
                        self.requestDistrictModels(cityId: cityId) { districtModels in
                            cityStateQueue.sync {
                                districtMap[cityId] = districtModels
                            }
                            districtGroup.leave()
                        }
                    }

                    districtGroup.notify(queue: cityStateQueue) {
                        provinceGroup.leave()
                    }
                }
            }

            provinceGroup.notify(queue: cityStateQueue) {
                completion(provinceModels, cityMap, districtMap)
            }
        }
    }
}

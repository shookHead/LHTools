//
//  AuthorizationManager.swift
//  internationalization
//
//  Created by 海 on 2023/9/14.
//

import UIKit
import CoreLocation
import LHTools
import AVFoundation
import Photos
import CoreBluetooth

class AuthorizationManager: NSObject,CLLocationManagerDelegate {

    typealias WKLocationHandler = (Bool) -> Void
    typealias WKAuthorizationHandler = (Bool) -> Void
    
    var locationAuthType : LocationAuthorizationType? = nil
    var locationClosure: WKLocationHandler?
    private class var share: AuthorizationManager{
        struct Static {
            static let sharedInstance = AuthorizationManager()
        }
        return Static.sharedInstance
    }
    lazy var lhLocationManager: CLLocationManager = {
        let cm = CLLocationManager.init()
        cm.delegate = self
        return cm
    }()
    private var authorizationSemaphore: DispatchSemaphore?
    private var centralManager: CBCentralManager?
    
    var authorizationStatus:PhotoAuthorizationStatus?


    public static func jumpSetting(_ title:String,_ msg:String){
        lh.topMost()?.showComfirm(title, msg, okStr: lhGoOpen, cancle: lhCancle, cancel: {

        }, complish: {
            lh.judgeAppSetting()
        })
    }
}

extension AuthorizationManager{
    public enum PhotoAuthorizationStatus {
        case notDetermined   // 还没有确定是否授权
        case restricted     // 权限被限制
        case denied         // 没有授权
        case authorized     // 已获得授权
    }
    ///判断相机权限
    public static func checkCameraAuthorization(_ completion: @escaping (PhotoAuthorizationStatus) -> Void)  {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            let semaphore = DispatchSemaphore(value: 0)
            
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    completion(.authorized)
                } else {
                    completion(.denied)
                }
                semaphore.signal()
            }
            
            semaphore.wait()
        case .restricted:
            completion(.restricted)
            jumpSetting(lhAccessingCameras, lhPermissionCamera)
        case .denied:
            completion(.denied)
            jumpSetting(lhAccessingCameras, lhPermissionCamera)
        case .authorized:
            completion(.authorized)
        default:
            completion(.denied)
        }
    }
}
extension AuthorizationManager{

    ///判断相册权限
    public static func checkAlbumAuthorization(_ completion: @escaping (PhotoAuthorizationStatus) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined:
            // 请求授权
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    if status == .authorized {
                        completion(.authorized)
                    } else {
                        completion(.denied)
                    }
                }
            }
        case .restricted:
            completion(.restricted)
            jumpSetting(lhAccessingAlbum, lhPermissionAlbum)
        case .denied:
            completion(.denied)
            jumpSetting(lhAccessingAlbum, lhPermissionAlbum)
        case .authorized:
            completion(.authorized)
        default:
            break
        }
    }
}

extension AuthorizationManager{
    ///判断录音权限 granted isFirstTimeRequest
    public static func checkMicrophoneAuthorization(completion: @escaping (Bool) -> Void) {
        let recordingSession = AVAudioSession.sharedInstance()

        switch recordingSession.recordPermission {
        case .granted:
            // 已授权
            completion(true)
            
        case .denied:
            // 已拒绝
            completion(false)
            jumpSetting(lhAccessRecording, lhPermissionRecording)
        case .undetermined:
            // 第一次请求权限
            recordingSession.requestRecordPermission { granted in
                completion(granted)
            }
        @unknown default:
            completion(false)
            jumpSetting(lhAccessRecording, lhPermissionRecording)
        }
    }
}


extension AuthorizationManager{
    enum LocationAuthorizationType {
        case aways //一直获取
        case WhenInUse //仅在使用期间
    }
    ///定位权限
    public class func checkLocationAuthorization(locationType type: LocationAuthorizationType ,completionHandler handler: @escaping WKLocationHandler) -> () {
        let status = CLLocationManager.authorizationStatus()
        share.locationClosure = handler
        share.locationAuthType = type
        switch status {
        case .notDetermined:
            // 第一次请求权限
            if type == .WhenInUse{
                share.lhLocationManager.requestWhenInUseAuthorization()
            }else{
                share.lhLocationManager.requestAlwaysAuthorization()
            }
        case .restricted, .denied:
            // 权限被拒绝或受限制，需要提醒用户打开定位权限
//            print("定位权限被拒绝或受限制")
            share.estimateLocationAuthResult(status)
            jumpSetting(lhAccessLocation, lhPermissionLocation)
        case .authorizedWhenInUse, .authorizedAlways:
            // 已经获得定位权限
//            print("已获得定位权限")
            share.estimateLocationAuthResult(status)
        @unknown default:
            share.estimateLocationAuthResult(status)
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .notDetermined{
            self.estimateLocationAuthResult(status)
        }
    }
    func estimateLocationAuthResult(_ result: CLAuthorizationStatus) -> Void {
        switch result {
        case .restricted, .denied,.notDetermined:
            self.locationClosure?(false)
        case .authorizedWhenInUse, .authorizedAlways:
            self.locationClosure?(true)
        default:
            self.locationClosure?(false)
        }
    }
}

extension AuthorizationManager:CBCentralManagerDelegate{
    ///蓝牙权限
    public static func checkBluetoothAuthorization(_ completion: @escaping (PhotoAuthorizationStatus) -> Void) {
        guard share.centralManager == nil else {
            completion(share.checkAuthorizationStatus())
            return
        }
        share.authorizationSemaphore = DispatchSemaphore(value: 0)
        let dispatchQueue = DispatchQueue(label: "bluetooth_queue")
        share.centralManager = CBCentralManager(delegate: share, queue: dispatchQueue)

        _ = share.authorizationSemaphore?.wait(timeout: .distantFuture)
        let status = share.checkAuthorizationStatus()
        completion(status)
    }
    private func checkAuthorizationStatus() -> PhotoAuthorizationStatus {
        guard let state = centralManager?.state else {
            return .denied
        }
        switch state {
        case .poweredOn:
            return .authorized
        case .unknown, .resetting, .unsupported, .unauthorized,.poweredOff:
            return .denied
        @unknown default:
            return .denied
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        authorizationStatus = checkAuthorizationStatus()
        authorizationSemaphore?.signal()
    }
}

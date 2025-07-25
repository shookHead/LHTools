//
//  LHAudioPlayer.swift
//  huitun
//
//  Created by 海 on 2025/7/25.
//

import UIKit
import AVFoundation

@objc protocol LHAudioPlayerDelegate: AnyObject {
    @objc func audioPlayerDidFinishPlaying()
    @objc func audioPlayerDidFail(withError error: Error?)
    @objc func audioPlayerDidUpdate(currentTime: TimeInterval, duration: TimeInterval)
}

public class LHAudioPlayer: NSObject, AVAudioPlayerDelegate {
    
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    private var playbackTime: TimeInterval = 0
    weak var delegate: LHAudioPlayerDelegate?
    
    enum PlaybackStatus {
        case stopped
        case playing
        case paused
    }
    
    private(set) var status: PlaybackStatus = .stopped
    
    // MARK: - Init
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    // MARK: - Public Methods
    
    public func playLocalAudio(withFileName fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil) else {
            delegate?.audioPlayerDidFail(withError: nil)
            return
        }
        playAudio(atURL: url)
    }

    public func playRemoteAudio(withURLString urlString: String) {
        guard let url = URL(string: urlString) else {
            delegate?.audioPlayerDidFail(withError: nil)
            return
        }

        let ext = url.pathExtension.isEmpty ? "mp3" : url.pathExtension
        let filename = urlString.md5 + "." + ext
        let cacheURL = Self.cacheDirectory.appendingPathComponent(filename)

        if FileManager.default.fileExists(atPath: cacheURL.path) {
            playAudio(atURL: cacheURL)
        } else {
            print("开始下载网络资源\(url)")
            let task = URLSession.shared.downloadTask(with: url) { [weak self] tempURL, _, error in
                guard let self = self else { return }
                if let error = error {
                    self.delegate?.audioPlayerDidFail(withError: error)
                    return
                }
                guard let tempURL = tempURL else {
                    self.delegate?.audioPlayerDidFail(withError: nil)
                    return
                }
                do {
                    try FileManager.default.moveItem(at: tempURL, to: cacheURL)
                    self.playAudio(atURL: cacheURL)
                } catch {
                    self.delegate?.audioPlayerDidFail(withError: error)
                }
            }
            task.resume()
        }
    }

    public func play() {
        audioPlayer?.play()
        status = .playing
        startTimer()
    }

    public func pause() {
        audioPlayer?.pause()
        status = .paused
        stopTimer()
    }

    public func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        status = .stopped
        playbackTime = 0
        stopTimer()
    }

    public func savePlaybackTime() {
        playbackTime = audioPlayer?.currentTime ?? 0
    }

    public func restorePlaybackTime() {
        audioPlayer?.currentTime = playbackTime
    }

    public var currentTime: TimeInterval {
        return audioPlayer?.currentTime ?? 0
    }

    public var duration: TimeInterval {
        return audioPlayer?.duration ?? 0
    }

    // MARK: - Private Methods
    
    private func playAudio(atURL url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            restorePlaybackTime()
            audioPlayer?.play()
            status = .playing

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let duration = self.audioPlayer?.duration, duration > 0 {
                    self.startTimer()
                } else {
                    self.waitForDurationAndStartTimer()
                }
            }
        } catch {
            delegate?.audioPlayerDidFail(withError: error)
        }
    }

    private func waitForDurationAndStartTimer() {
        guard let player = self.audioPlayer else { return }
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            if player.duration > 0 {
                timer.invalidate()
                self?.startTimer()
            }
        }
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(timeInterval: 0.1,
                                     target: self,
                                     selector: #selector(updatePlaybackTime),
                                     userInfo: nil,
                                     repeats: true)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    @objc private func updatePlaybackTime() {
        guard let player = audioPlayer else { return }
        delegate?.audioPlayerDidUpdate(currentTime: player.currentTime, duration: player.duration)
    }

    // MARK: - AVAudioPlayerDelegate
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        status = .stopped
        stopTimer()
        delegate?.audioPlayerDidFinishPlaying()
    }

    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        status = .stopped
        stopTimer()
        delegate?.audioPlayerDidFail(withError: error ?? NSError(domain: "decodeError", code: -1))
    }

    // MARK: - Audio Session (静音播放支持)
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AVAudioSession 配置失败: \(error.localizedDescription)")
        }
    }

    // MARK: - Cache Management
    
    static var cacheDirectory: URL {
        let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            .appendingPathComponent("AudioCache")
        if !FileManager.default.fileExists(atPath: path.path) {
            try? FileManager.default.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
        }
        return path
    }

    /// 清理 24 小时前缓存
    public static func cleanExpiredCache(olderThan hours: Double = 24) {
        let fm = FileManager.default
        guard let files = try? fm.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.creationDateKey], options: []) else { return }
        let now = Date()
        for fileURL in files {
            if let info = try? fileURL.resourceValues(forKeys: [.creationDateKey]),
               let created = info.creationDate,
               now.timeIntervalSince(created) > hours * 3600 {
                try? fm.removeItem(at: fileURL)
            }
        }
    }

    /// 删除指定 URL 缓存
    public static func removeCache(for urlString: String) {
        let ext = URL(string: urlString)?.pathExtension ?? "mp3"
        let filename = urlString.md5 + "." + (ext.isEmpty ? "mp3" : ext)
        let fileURL = cacheDirectory.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: fileURL)
    }

    /// 删除所有缓存
    public static func clearAllCache() {
        guard let files = try? FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil) else { return }
        for file in files {
            try? FileManager.default.removeItem(at: file)
        }
    }
}

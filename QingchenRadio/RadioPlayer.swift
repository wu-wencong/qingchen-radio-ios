import Foundation
import UIKit
import AVFoundation
import MediaPlayer
import Combine

/// 电台播放核心：AVPlayer + 后台播放 + 锁屏/车机远程控制
final class RadioPlayer: ObservableObject {

    @Published private(set) var index: Int = 0
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var isBuffering: Bool = false
    @Published private(set) var statusText: String = "轻触任意电台开始收听"

    let stations = Station.all
    var current: Station { stations[index] }

    private var player: AVPlayer?
    private var statusObs: NSKeyValueObservation?
    private var tcObs: NSKeyValueObservation?
    private var retryTask: DispatchWorkItem?
    private var retryLeft = 2
    /// 当前在第几路源上。一个台可能挂了 2~3 路，一路不通就往下换
    private var sourceIndex = 0
    /// 当前源的名字，状态栏里能看出是不是换到备用线上了
    @Published private(set) var currentSourceName: String = ""
    private var didAutoStart = false

    init() {
        activateSession()
        setupRemoteCommands()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onInterruption(_:)),
                                               name: AVAudioSession.interruptionNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onStalled(_:)),
                                               name: AVPlayerItem.playbackStalledNotification,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 对外操作

    /// 启动即自动播放主台
    func autoStart() {
        guard !didAutoStart else { return }
        didAutoStart = true
        tune(to: index)
    }

    func tune(to i: Int) {
        retryTask?.cancel()
        retryLeft = 2
        sourceIndex = 0
        index = ((i % stations.count) + stations.count) % stations.count
        load()
    }

    func toggle() {
        if isPlaying { pause() } else { resume() }
    }

    func next() { tune(to: index + 1) }
    func prev() { tune(to: index - 1) }

    func resume() {
        guard let p = player else {
            tune(to: index)
            return
        }
        activateSession()
        isBuffering = true
        statusText = "正在连接…"
        p.play()
        refreshNowPlaying()
    }

    func pause() {
        player?.pause()
        isPlaying = false
        isBuffering = false
        statusText = "已暂停"
        refreshNowPlaying()
    }

    // MARK: - 装载与重试

    private func load() {
        let s = current
        if sourceIndex < 0 || sourceIndex >= s.sources.count { sourceIndex = 0 }
        let src = s.sources[sourceIndex]
        currentSourceName = src.name
        teardown()

        activateSession()
        isBuffering = true
        isPlaying = false
        statusText = "正在连接 \(s.name)…"

        let item = AVPlayerItem(url: src.url)
        let p = AVPlayer(playerItem: item)
        p.allowsExternalPlayback = false
        p.automaticallyWaitsToMinimizeStalling = true
        player = p

        statusObs = item.observe(\.status, options: [.new, .initial]) { [weak self] it, _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch it.status {
                case .readyToPlay:
                    self.retryLeft = 2
                    self.isBuffering = false
                    self.isPlaying = true
                    self.statusText = "正在播放 · \(self.currentSourceName)"
                    self.refreshNowPlaying()
                case .failed:
                    self.scheduleRetry()
                default:
                    break
                }
            }
        }

        tcObs = p.observe(\.timeControlStatus, options: [.new]) { [weak self] pl, _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch pl.timeControlStatus {
                case .playing:
                    self.isPlaying = true
                    self.isBuffering = false
                case .waitingToPlayAtSpecifiedRate:
                    self.isBuffering = true
                default:
                    break
                }
            }
        }

        p.play()
        refreshNowPlaying()
    }

    private func scheduleRetry() {
        retryTask?.cancel()
        let s = current
        let delay: Double
        let msg: String

        if sourceIndex + 1 < s.sources.count {
            // 还有备用线路：直接换过去，比在同一条死路上重试有用
            sourceIndex += 1
            delay = 1.0
            msg = "主线路没通，切到\(s.sources[sourceIndex].name)…"
        } else if retryLeft > 0 {
            // 所有线路都试过了，回主源再来一轮（有些台是瞬时抖动）
            retryLeft -= 1
            sourceIndex = 0
            delay = 1.5
            msg = "线路不稳，正在重试…"
        } else {
            isBuffering = false
            isPlaying = false
            statusText = "这条线路暂时打不开，换一台试试"
            refreshNowPlaying()
            return
        }

        isBuffering = true
        statusText = msg
        let task = DispatchWorkItem { [weak self] in self?.load() }
        retryTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: task)
    }

    private func teardown() {
        statusObs?.invalidate()
        statusObs = nil
        tcObs?.invalidate()
        tcObs = nil
        player?.pause()
        player = nil
    }

    // MARK: - 会话

    private func activateSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)
        } catch {
            // 静默忽略：真机上极少失败，失败时系统仍会尝试播放
        }
    }

    // MARK: - 锁屏 / 车机信息

    private func refreshNowPlaying() {
        let s = current
        var info: [String: Any] = [:]
        info[MPMediaItemPropertyTitle] = s.name
        info[MPMediaItemPropertyArtist] = "私人电台"
        info[MPMediaItemPropertyAlbumTitle] = s.subtitle
        info[MPNowPlayingInfoPropertyIsLiveStream] = true
        info[MPNowPlayingInfoPropertyDefaultPlaybackRate] = 1.0
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        if let img = UIImage(named: s.art) {
            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: img.size) { _ in img }
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    // MARK: - 远程控制（锁屏 / 蓝牙车机 / 方向盘）

    private func setupRemoteCommands() {
        let c = MPRemoteCommandCenter.shared()
        c.playCommand.isEnabled = true
        c.pauseCommand.isEnabled = true
        c.togglePlayPauseCommand.isEnabled = true
        c.nextTrackCommand.isEnabled = true
        c.previousTrackCommand.isEnabled = true
        c.changePlaybackPositionCommand.isEnabled = false

        c.playCommand.addTarget { [weak self] _ in
            DispatchQueue.main.async { self?.resume() }
            return .success
        }
        c.pauseCommand.addTarget { [weak self] _ in
            DispatchQueue.main.async { self?.pause() }
            return .success
        }
        c.togglePlayPauseCommand.addTarget { [weak self] _ in
            DispatchQueue.main.async { self?.toggle() }
            return .success
        }
        c.nextTrackCommand.addTarget { [weak self] _ in
            DispatchQueue.main.async { self?.next() }
            return .success
        }
        c.previousTrackCommand.addTarget { [weak self] _ in
            DispatchQueue.main.async { self?.prev() }
            return .success
        }
    }

    // MARK: - 通知

    @objc private func onInterruption(_ note: Notification) {
        guard let raw = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: raw) else { return }

        if type == .began {
            isPlaying = false
            isBuffering = false
            statusText = "被其他音频打断"
            refreshNowPlaying()
        } else if type == .ended {
            let optRaw = note.userInfo?[AVAudioSessionInterruptionOptionKey] as? UInt ?? 0
            let opts = AVAudioSession.InterruptionOptions(rawValue: optRaw)
            if opts.contains(.shouldResume) {
                resume()
            }
        }
    }

    @objc private func onStalled(_ note: Notification) {
        guard let item = note.object as? AVPlayerItem, item === player?.currentItem else { return }
        isBuffering = true
        statusText = "缓冲中…"
    }
}

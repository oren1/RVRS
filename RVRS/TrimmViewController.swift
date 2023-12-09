//
//  TrimmViewController.swift
//  RVRS
//
//  Created by oren shalev on 05/12/2023.
//

import UIKit
import AVFoundation

enum TrimmigError: Error {
    case general(description: String)
}

class TrimmViewController: AssetSelectionViewController {

    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var trimmerView: TrimmerView!
    
    var asset: AVAsset?
    var player: AVPlayer?
    var playbackTimeCheckerTimer: Timer?
    var trimmerPositionChangedTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let asset = asset else {return}
        loadAsset(asset)
        
        trimmerView.handleColor = UIColor.white
        trimmerView.mainColor = UIColor.darkGray
        trimmerView.regenerateThumbnails()

    }
    @IBAction func continueButtonTapped(_ sender: Any) {
    }
    
    override func loadAsset(_ asset: AVAsset) {
        trimmerView.asset = asset
        trimmerView.delegate = self
        addVideoPlayer(with: asset, playerView: playerView)
        player?.play()
    }

    private func addVideoPlayer(with asset: AVAsset, playerView: UIView) {
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)

        NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying(_:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)

        let layer: AVPlayerLayer = AVPlayerLayer(player: player)
        layer.backgroundColor = UIColor.white.cgColor
        layer.frame = CGRect(x: 0, y: 0, width: playerView.frame.width, height: playerView.frame.height)
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerView.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
        playerView.layer.addSublayer(layer)
    }

    @objc func itemDidFinishPlaying(_ notification: Notification) {
        if let startTime = trimmerView.startTime {
            player?.seek(to: startTime)
            if (player?.isPlaying != true) {
                player?.play()
            }
        }
    }

    func startPlaybackTimeChecker() {

        stopPlaybackTimeChecker()
        playbackTimeCheckerTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self,
                                                        selector:
            #selector(onPlaybackTimeChecker), userInfo: nil, repeats: true)
    }

    func stopPlaybackTimeChecker() {

        playbackTimeCheckerTimer?.invalidate()
        playbackTimeCheckerTimer = nil
    }

    @objc func onPlaybackTimeChecker() {

        guard let startTime = trimmerView.startTime, let endTime = trimmerView.endTime, let player = player else {
            return
        }

        let playBackTime = player.currentTime()
        trimmerView.seek(to: playBackTime)

        if playBackTime >= endTime {
            player.seek(to: startTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            trimmerView.seek(to: startTime)
        }
    }


    // MARK: - Custom Logic
    func getTrimmedAsset() async throws -> AVAsset?  {
        guard let asset = asset else {
            throw TrimmigError.general(description: "Unable Reading Asset")
        }
        guard let startTime = trimmerView.startTime,let endTime = trimmerView.endTime else {
            throw TrimmigError.general(description: "Trimmer startTime or endTime doesn't exist")
            
        }
        
        guard let exportSession = AVAssetExportSession(
            asset: asset,
            presetName: AVAssetExportPresetHighestQuality)
        else {
            throw TrimmigError.general(description: "Couldn't create AVAssetExportSession")
        }
        
        exportSession.timeRange = CMTimeRange(start: startTime, end: endTime)
        
        let fileExtension = "mov"
        let videoName = UUID().uuidString
        let exportURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(videoName)
            .appendingPathExtension(fileExtension)
        
        exportSession.outputFileType = .mov
        exportSession.outputURL = exportURL
        
        await exportSession.export()
        switch exportSession.status {
        case .completed:
            return AVAsset(url: exportURL)
        default:
            throw TrimmigError.general(description: "Something went wrong during export.")
            
        }
    }
}


extension TrimmViewController: TrimmerViewDelegate {
    func positionBarStoppedMoving(_ playerTime: CMTime) {
        player?.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        player?.play()
        startPlaybackTimeChecker()
    }

    func didChangePositionBar(_ playerTime: CMTime) {
        stopPlaybackTimeChecker()
        player?.pause()
        player?.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        let duration = (trimmerView.endTime! - trimmerView.startTime!).seconds
        print(duration)
    }
}

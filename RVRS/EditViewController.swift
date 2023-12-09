//
//  ViewController.swift
//  VideoSpeed
//
//  Created by oren shalev on 13/07/2023.
//

import UIKit
import AVFoundation
import AVKit
import Accelerate
import FirebaseRemoteConfig


enum BusinessModelType: Int {
    case onlyProVersionExport = 0, allowedReverseExport
}

class EditViewController: UIViewController {
    var playerController: AVPlayerViewController!
    var asset: AVAsset!
    var reversedAsset: AVAsset!
    var reversedAudio: AVAsset?
    var composition: AVMutableComposition!
    var videoComposition: AVMutableVideoComposition!
    var speed: Float = 1
    var fps: Int32 = 30
    var fileType: AVFileType = .mov
    var soundOn: Bool! = true
    var assetUrl: URL!
    var compositionOriginalDuration: CMTime!
    var compositionVideoTrack: AVMutableCompositionTrack!
    var exportSession: AVAssetExportSession?
    var timer: Timer?
    var numberOfLoops: Int = 1
    var loopStartingPoint: LoopStart = .reverse
    var proButton: UIButton!
    var tabs: [TabItem]!
    
    @IBOutlet weak var tabCollectionView: UICollectionView!
    @IBOutlet weak var soundSwitch: UISwitch!
    @IBOutlet weak var loopSwitch: UISwitch!
    @IBOutlet weak var slider: UISlider!
    
    lazy var loadingView: LoadingView = {
        loadingView = LoadingView()
        return loadingView
    }()
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    lazy var progressIndicatorView: ProgressIndicatorView = {
        progressIndicatorView = ProgressIndicatorView()
        return progressIndicatorView
    }()
    
    lazy var blackTransparentOverlay: BlackTransparentOverlay = {
        blackTransparentOverlay = BlackTransparentOverlay()
        return blackTransparentOverlay
    }()
    
    lazy var usingProFeaturesAlertView: UsingProFeaturesAlertView = {
        usingProFeaturesAlertView = UsingProFeaturesAlertView()
        return usingProFeaturesAlertView
    }()
    
    @IBOutlet weak var dashboardContainerView: UIView!
    @IBOutlet weak var sectionContainerView: UIView!
    
    var speedSectionVC: SpeedSectionVC!
    var loopSectionVC: LoopSectionVC!
    var soundSectionVC: SoundSectionVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit"
        proButton = createProButton()

        showLoading(opacity: 1, title: "Reversing Video")
        
        addSpeedSection()
        addLoopSection()
        addSoundSection()
        

        showLoopSection()
        
        tabs = [TabItem(title: "Loops", selected: true, imageName: "infinity.circle", selectedImageName: "infinity.circle.fill"),
                    TabItem(title: "Speed", selected: false, imageName: "timer.circle", selectedImageName: "timer.circle.fill"),
//                    TabItem(title: "Sound", selected: false, imageName: "volume.2", selectedImageName: "volume.2.fill")
                    ]
        
        asset = AVAsset(url: assetUrl)
        let fileExtension = "mov"
         let videoName = UUID().uuidString
         let outputURL = URL(fileURLWithPath: NSTemporaryDirectory())
           .appendingPathComponent(videoName)
           .appendingPathExtension(fileExtension)
        
        Task {
            let session = await AssetReverseSession(asset: self.asset, outputFileURL: outputURL)
            let reversedVideo = try await session.reverse()
           
            self.reversedAsset = reversedVideo
            
            
            guard let (composition, videoComposition) = await createCompositionWith(speed: speed,
                                                                                    fps: fps,
                                                                                    soundOn: UserDataManager.soundOn) else {
                return showNoTracksError()
            }
            self.composition = composition
            self.videoComposition = videoComposition
            let compositionCopy = self.composition.copy() as! AVComposition
            let videoCompositionCopy = self.videoComposition.copy() as! AVVideoComposition

            
            setNavigationItems()
            let playerItem = AVPlayerItem(asset: compositionCopy)
            playerItem.audioTimePitchAlgorithm = .spectral
            playerItem.videoComposition = videoCompositionCopy
            let player = AVPlayer(playerItem: playerItem)
            self.playerController = AVPlayerViewController()
            self.playerController.player = player
            self.addPlayerToTop()
            await self.reloadComposition()
            self.loopVideo()
            self.playerController.player?.play()
            hideLoading()

        }
    }

    deinit {
        UserDataManager.usingLoops = false
        UserDataManager.usingSpeedSlider = false
        UserDataManager.soundOn = true
        
        tabs.forEach { tabItem in
            if tabItem.title == "Loops" {
                tabItem.selected = true
            }
            else {
                tabItem.selected = false
            }
        }
    }
    
    func integrate(reversedVideo: AVAsset, reversedAudio: AVAsset) async -> AVAsset? {
        let composition = AVMutableComposition(urlAssetInitializationOptions: nil)

        let compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: 1)!
        let compositionAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: 2)!
        let assetDuration = try! await asset.load(.duration)
        
        
        let videoTracks = try! await reversedVideo.loadTracks(withMediaType: .video)
        guard  videoTracks.count > 0 else { return nil }
        let videoTrack = videoTracks[0]
        try? compositionVideoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: assetDuration),
                                                                of: videoTrack,
                                                                at: CMTime.invalid)
        
        let audioTracks = try! await reversedAudio.loadTracks(withMediaType: .audio)
        guard  audioTracks.count > 0 else { return nil }
        let audioTrack = audioTracks[0]
        try? compositionAudioTrack.insertTimeRange(CMTimeRange(start: .zero, duration: assetDuration),
                                                                of: audioTrack,
                                                                at: CMTime.invalid)
        
        let preferredTransform = try! await videoTrack.load(.preferredTransform)
        compositionVideoTrack.preferredTransform = preferredTransform
        return composition
    }
    
    func extractAudioTrackToFileIfExists(asset: AVAsset) async -> URL? {
        guard let audioTrack = try? await asset.loadTracks(withMediaType: .audio).first else {
            return nil
        }
        let assetDuration = try! await asset.load(.duration)
        
        let composition = AVMutableComposition(urlAssetInitializationOptions: nil)
        let compositionAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: 1)!
        try? compositionAudioTrack.insertTimeRange(CMTimeRange(start: .zero, duration: assetDuration),
                                                                of: audioTrack,
                                                                at: CMTime.invalid)
        guard let exportSession = AVAssetExportSession(
          asset: composition,
          presetName: AVAssetExportPresetAppleM4A)
          else {
            print("Cannot create export session.")
            return nil
        }
        
        
        let audioName = UUID().uuidString
        let exportURL = URL(fileURLWithPath: NSTemporaryDirectory())
          .appendingPathComponent(audioName)
          .appendingPathExtension("m4a")
        
        exportSession.outputFileType = .m4a
        exportSession.outputURL = exportURL
        await exportSession.export()
        
        switch exportSession.status {
        case .completed:
          print("completed export with url: \(exportURL)")
          return exportURL
        default:
          print("Something went wrong during export.")
          print(exportSession.error ?? "unknown error")
          return nil
        }

    }
    
    func reverseAudio(fromUrl: URL) -> URL? {
        do {
            let input = try AVAudioFile(forReading: fromUrl)
            let format = input.processingFormat
            let frameCount = AVAudioFrameCount(input.length)

            let outSettings = [AVNumberOfChannelsKey: format.channelCount,
                               AVSampleRateKey: format.sampleRate,
                               AVLinearPCMBitDepthKey: 16,
                               AVFormatIDKey: kAudioFormatMPEG4AAC] as [String: Any]

            let outputUrl = FileManager.default.temporaryDirectory.appendingPathComponent("reversed.m4a")
            try? FileManager.default.removeItem(at: outputUrl)

            let output = try AVAudioFile(forWriting: outputUrl, settings: outSettings)
            guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
                return nil
            }

            try input.read(into: buffer)
            let frameLength = buffer.frameLength

            guard let data = buffer.floatChannelData else { return nil }

            for i in 0..<buffer.format.channelCount {
                let stride = vDSP_Stride(1)
                vDSP_vrvrs(data.advanced(by: Int(i)).pointee, stride, vDSP_Length(frameLength))
            }

            try output.write(from: buffer)
            return outputUrl
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
        
    func createLoopAsset(startingPoint: LoopStart) async -> (composition: AVMutableComposition, videoComposition: AVMutableVideoComposition)? {
        let composition = AVMutableComposition(urlAssetInitializationOptions: nil)
        let compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: 1)!

        if soundOn,
        let reversedAudioTrack = try? await reversedAsset.loadTracks(withMediaType: .audio).first,
        let forwardAudioTrack = try? await asset.loadTracks(withMediaType: .audio).first {
            
            let compositionAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: 2)!


            guard let reversedAudioDuration = try? await reversedAsset.load(.duration),
                  let forwardAudioDuration = try? await asset.load(.duration) else {return nil}
            
            if startingPoint == .forward {
                try? compositionAudioTrack.insertTimeRange(CMTimeRange(start: .zero, duration: forwardAudioDuration),
                                                           of: forwardAudioTrack,
                                                           at: CMTime.invalid)
                try? compositionAudioTrack.insertTimeRange(CMTimeRange(start: .zero, duration: reversedAudioDuration),
                                                           of: reversedAudioTrack,
                                                           at: CMTime.invalid)
            }
            else if startingPoint == .reverse{
                try? compositionAudioTrack.insertTimeRange(CMTimeRange(start: .zero, duration: reversedAudioDuration),
                                                           of: reversedAudioTrack,
                                                           at: CMTime.invalid)
                try? compositionAudioTrack.insertTimeRange(CMTimeRange(start: .zero, duration: forwardAudioDuration),
                                                           of: forwardAudioTrack,
                                                           at: CMTime.invalid)
            }
        }
        
        
        guard let reversedVideoTrack = try? await reversedAsset.loadTracks(withMediaType: .video).first,
              let forwardVideoTrack = try? await asset.loadTracks(withMediaType: .video).first,
              let reversedVideoDuration = try? await reversedAsset.load(.duration),
              let forwardVideoDuration = try? await asset.load(.duration) else {return nil}
        
        
        if startingPoint == .forward {
            try? compositionVideoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: forwardVideoDuration),
                                                       of: forwardVideoTrack,
                                                       at: CMTime.invalid)
            try? compositionVideoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: reversedVideoDuration),
                                                       of: reversedVideoTrack,
                                                       at: CMTime.invalid)
        }
        else if startingPoint == .reverse{
            try? compositionVideoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: reversedVideoDuration),
                                                       of: reversedVideoTrack,
                                                       at: CMTime.invalid)
            try? compositionVideoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: forwardVideoDuration),
                                                       of: forwardVideoTrack,
                                                       at: CMTime.invalid)
        }
        
        guard let compositioDuration = try? await composition.load(.duration) else {return nil}
        let newDuration = Int64(compositioDuration.seconds / Double(speed))
        composition.scaleTimeRange(CMTimeRange(start: .zero, duration: compositioDuration), toDuration: CMTime(value: newDuration, timescale: 1))
        
        let loopComposition = AVMutableComposition(urlAssetInitializationOptions: nil)
        let loopCompositionVideoTrack = loopComposition.addMutableTrack(withMediaType: .video, preferredTrackID: 1)!
        var loopCompositionAudioTrack: AVMutableCompositionTrack?
        if soundOn, let _ = try? await composition.loadTracks(withMediaType: .audio).first {
            loopCompositionAudioTrack = loopComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: 2)!
        }
        
        if numberOfLoops != 0 {
            guard let compositionVideoTrack = try? await composition.loadTracks(withMediaType: .video).first else {return nil}
            
            for _ in 0..<numberOfLoops {
                try? loopCompositionVideoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: compositioDuration), of: compositionVideoTrack, at: CMTime.invalid)
                if soundOn {
                    guard let compositionAudioTrack = try? await composition.loadTracks(withMediaType: .audio).first else {
                        continue
                    }
                    try? loopCompositionAudioTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: compositioDuration), of: compositionAudioTrack, at: CMTime.invalid)
                }
                
            }
            
            
            let naturalSize = try! await reversedVideoTrack.load(.naturalSize)
            let preferredTransform = try! await reversedVideoTrack.load(.preferredTransform)
            compositionVideoTrack.preferredTransform = preferredTransform

            let videoInfo = VideoHelper.orientation(from: preferredTransform)
            print("videoInfo.orientation \(videoInfo.orientation)")

            let videoSize: CGSize

            if videoInfo.isPortrait {
              videoSize = CGSize(
                width: naturalSize.height,
                height: naturalSize.width)
            } else {
              videoSize = naturalSize
            }
            
            print("videoSize \(videoSize)")

            
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRange(
              start: .zero,
              duration: loopComposition.duration)
            
            let layerInstruction = await compositionLayerInstruction(
              for: compositionVideoTrack,
              assetTrack: reversedVideoTrack,
              videoSize: videoSize,
              isPortrait: videoInfo.isPortrait)
            
            instruction.layerInstructions = [layerInstruction]
            
            let videoComposition = AVMutableVideoComposition()
            videoComposition.instructions = [instruction]
            videoComposition.frameDuration = CMTimeMake(value: 1, timescale: fps)
            videoComposition.renderSize = videoSize


            return (loopComposition,videoComposition)
        }
        else {
            return nil
        }
        
    }
    func createCompositionWith(speed: Float, fps: Int32, soundOn: Bool) async -> (composition: AVMutableComposition, videoComposition: AVMutableVideoComposition)? {
        let composition = AVMutableComposition(urlAssetInitializationOptions: nil)

        let compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: 1)!

        if  soundOn,
            let audioTracks = try? await reversedAsset.loadTracks(withMediaType: .audio),
            audioTracks.count > 0 {
            let audioTrack = audioTracks[0]
            let compositionAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: 2)!
            let audioDuration = try! await reversedAsset.load(.duration)
            
            try? compositionAudioTrack.insertTimeRange(CMTimeRange(start: .zero, duration: audioDuration),
                                                                    of: audioTrack,
                                                                    at: CMTime.invalid)
        }
        
        
        let videoTracks = try! await reversedAsset.loadTracks(withMediaType: .video)
        guard  videoTracks.count > 0 else { return nil }
        
        let videoTrack = videoTracks[0]
        
        let videoDuration = try! await reversedAsset.load(.duration)
        
        try? compositionVideoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: videoDuration),
                                                                of: videoTrack,
                                                                at: CMTime.invalid)
        
        
       
        
        compositionOriginalDuration = try! await composition.load(.duration)
        let newDuration = Int64(compositionOriginalDuration.seconds / Double(speed))
        composition.scaleTimeRange(CMTimeRange(start: .zero, duration: compositionOriginalDuration), toDuration: CMTime(value: newDuration, timescale: 1))
        
        

        let naturalSize = try! await videoTrack.load(.naturalSize)
        let preferredTransform = try! await videoTrack.load(.preferredTransform)
        compositionVideoTrack.preferredTransform = preferredTransform

        let videoInfo = VideoHelper.orientation(from: preferredTransform)
        print("videoInfo.orientation \(videoInfo.orientation)")

        let videoSize: CGSize

        if videoInfo.isPortrait {
          videoSize = CGSize(
            width: naturalSize.height,
            height: naturalSize.width)
        } else {
          videoSize = naturalSize
        }
        
        print("videoSize \(videoSize)")

        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(
          start: .zero,
          duration: composition.duration)
        
        let layerInstruction = await compositionLayerInstruction(
          for: compositionVideoTrack,
          assetTrack: videoTrack,
          videoSize: videoSize,
          isPortrait: videoInfo.isPortrait)
        
        instruction.layerInstructions = [layerInstruction]
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.instructions = [instruction]
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: fps)
        videoComposition.renderSize = videoSize


        return (composition,videoComposition)
        
    }
    
    
    func reloadComposition() async {
        
        if numberOfLoops != 0,
           let (composition, videoComposition) = await createLoopAsset(startingPoint: loopStartingPoint){
            self.composition = composition
            self.videoComposition = videoComposition
            let compositionCopy = self.composition.copy() as! AVComposition
            let videoCompositionCopy = self.videoComposition.copy() as! AVVideoComposition

            let playerItem = AVPlayerItem(asset: compositionCopy)
            playerItem.audioTimePitchAlgorithm = .spectral
            playerItem.videoComposition = videoCompositionCopy

            playerController.player?.replaceCurrentItem(with: playerItem)
            return
        }
        
        guard let (composition, videoComposition) = await createCompositionWith(speed: speed,
                                                                                fps: fps,
                                                                                soundOn: UserDataManager.soundOn) else {
            return showNoTracksError()
        }
        self.composition = composition
        self.videoComposition = videoComposition
        let compositionCopy = self.composition.copy() as! AVComposition
        let videoCompositionCopy = self.videoComposition.copy() as! AVVideoComposition

        let playerItem = AVPlayerItem(asset: compositionCopy)
        playerItem.audioTimePitchAlgorithm = .spectral
        playerItem.videoComposition = videoCompositionCopy

        playerController.player?.replaceCurrentItem(with: playerItem)
    }
    
    

    
    func createRightItemLabel() -> UILabel {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        label.layer.cornerRadius = 8
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        
        return label
    }
    
    @objc func exportVideo() {
        Task {
            let theComposition = composition.copy() as! AVComposition
            let videoComposition = videoComposition.copy() as! AVVideoComposition
            
            guard let exportSession = AVAssetExportSession(
              asset: theComposition,
              presetName: AVAssetExportPresetHighestQuality)
              else {
                print("Cannot create export session.")
                return
            }
            
            let compositionDuration = try! await theComposition.load(.duration)
            let fifthOfSecond = CMTime(value: 20, timescale: 1000)
            exportSession.timeRange = CMTimeRange(start: fifthOfSecond, duration: compositionDuration - fifthOfSecond)
            self.exportSession = nil
            self.exportSession = exportSession
            
            let fileExtension = "mov"
            let videoName = UUID().uuidString
            let exportURL = URL(fileURLWithPath: NSTemporaryDirectory())
              .appendingPathComponent(videoName)
              .appendingPathExtension(fileExtension)
            
            exportSession.videoComposition = videoComposition
            exportSession.outputFileType = .mov
            exportSession.outputURL = exportURL
            
            showProgreeView()
            exportSession.exportAsynchronously {
                DispatchQueue.main.async { [weak self] in
                  guard let self = self else { return  }
                  self.removeProgressView()
                  switch exportSession.status {
                  case .completed:
                    print("completed export with url: \(exportURL)")
                      guard UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(exportURL.relativePath) else { return }
                       
                       // 3
                      UISaveVideoAtPathToSavedPhotosAlbum(exportURL.relativePath, self, #selector(self.video(_:didFinishSavingWithError:contextInfo:)),nil)
                      
                  default:
                    print("Something went wrong during export.")
                    print(exportSession.error ?? "unknown error")
                    break
                  }
                }

            }
        }
    }
    
    @objc func video(
      _ videoPath: String,
      didFinishSavingWithError error: Error?,
      contextInfo info: AnyObject
    ) {
        if error == nil {
            let successMessageViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SuccessMessageViewController") as! SuccessMessageViewController
            if UIDevice.current.userInterfaceIdiom == .phone {
                successMessageViewController.modalPresentationStyle = .fullScreen
            }
            self.present(successMessageViewController, animated: true)
        }
        else {
            let alert = UIAlertController(
              title: "Error",
              message: "Video failed to save please try again",
              preferredStyle: .alert)
            alert.addAction(UIAlertAction(
              title: "OK",
              style: UIAlertAction.Style.cancel,
              handler: nil))
            present(alert, animated: true, completion: nil)
        }

    }
    
    func addPlayerToTop() {
        //add as a childviewcontroller
        addChild(playerController)

         // Add the child's View as a subview
         self.view.addSubview(playerController.view)

        playerController.view.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            playerController.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            playerController.view.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            playerController.view.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor),
            playerController.view.bottomAnchor.constraint(equalTo: self.dashboardContainerView.topAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
        
         // tell the childviewcontroller it's contained in it's parent
        playerController.didMove(toParent: self)
//        self.playerController.player?.play()
    }

    
    private func compositionLayerInstruction(for track: AVCompositionTrack, assetTrack: AVAssetTrack, videoSize: CGSize, isPortrait: Bool) async -> AVMutableVideoCompositionLayerInstruction {
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let transform = try! await assetTrack.load(.preferredTransform)
        instruction.setTransform(transform, at: .zero)

        if isPortrait {
            var newTransform = CGAffineTransform(translationX: 0, y: 0)
            newTransform = newTransform.rotated(by: CGFloat(90 * Double.pi / 180))
            newTransform = newTransform.translatedBy(x: 0, y: -videoSize.width)
            instruction.setTransform(newTransform, at: .zero)
        }
        else {
            instruction.setTransform(transform, at: .zero)
        }

        return instruction
    }
    
    // MARK: - UI
    func setNavigationItems() {
        let exportButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(tryToExportVideo))
    
        navigationItem.rightBarButtonItems = [exportButton]
    }
    func showBlackTransparentOverlay() {
        self.navigationController!.view.addSubview(blackTransparentOverlay)
        blackTransparentOverlay.translatesAutoresizingMaskIntoConstraints = false

        let constraints = [
            blackTransparentOverlay.topAnchor.constraint(equalTo: navigationController!.view.topAnchor),
            blackTransparentOverlay.leftAnchor.constraint(equalTo: navigationController!.view.leftAnchor),
            blackTransparentOverlay.rightAnchor.constraint(equalTo: navigationController!.view.rightAnchor),
            blackTransparentOverlay.bottomAnchor.constraint(equalTo: navigationController!.view.bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func hideBlackTransparentOverlay() {
        blackTransparentOverlay.removeFromSuperview()
    }
    
    func showUsingProFeaturesAlertView() {
        usingProFeaturesAlertView.updateStatus(usingSlider: UserDataManager.usingSpeedSlider,
                                               usingLoops: UserDataManager.usingLoops,
                                               soundOn: UserDataManager.soundOn)
        usingProFeaturesAlertView.layer.opacity = 0
        self.navigationController!.view.addSubview(usingProFeaturesAlertView)
        usingProFeaturesAlertView.translatesAutoresizingMaskIntoConstraints = false
        usingProFeaturesAlertView.onCancel = { [weak self] in
            self?.hideProFeatureAlert()
        }
        usingProFeaturesAlertView.onContinue = { [weak self] in
            self?.showPurchaseViewController()
            self?.hideProFeatureAlert()
        }
        let constraints = [
            usingProFeaturesAlertView.heightAnchor.constraint(equalToConstant: 300),
            usingProFeaturesAlertView.widthAnchor.constraint(equalToConstant: 340),
            usingProFeaturesAlertView.centerXAnchor.constraint(equalTo: navigationController!.view.safeAreaLayoutGuide.centerXAnchor),
            usingProFeaturesAlertView.centerYAnchor.constraint(equalTo: navigationController!.view.safeAreaLayoutGuide.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.usingProFeaturesAlertView.layer.opacity = 1
        }
        
    }
    func hideUsingProFeaturesAlertView() {
        usingProFeaturesAlertView.removeFromSuperview()
    }
    
    func showProFeatureAlert() {
        showBlackTransparentOverlay()
        showUsingProFeaturesAlertView()
    }
    
    func hideProFeatureAlert() {
        self.hideBlackTransparentOverlay()
        self.hideUsingProFeaturesAlertView()
    }
    
    func createProButton() -> UIButton {
        let proButton = UIButton(type: .roundedRect)
        proButton.tintColor = .systemBlue
        proButton.backgroundColor = .white
        proButton.setTitle("Pro Version", for: .normal)
        proButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        proButton.addTarget(self, action: #selector(proButtonTapped), for: .touchUpInside)
        proButton.layer.cornerRadius = 8
        proButton.layer.borderWidth = 1
        proButton.layer.borderColor = UIColor.lightGray.cgColor
        return proButton
    }
    
    func showProButtonIfNeeded() {
        guard SpidProducts.store.userPurchasedProVersion() == nil else {return}
        let businessModelType = RemoteConfig.remoteConfig().configValue(forKey: "business_model_type").numberValue.intValue
        let businessModel = BusinessModelType(rawValue: businessModelType)
        guard businessModel == .allowedReverseExport  else {return}
        
        if UserDataManager.main.usingProFeatures() {
            self.showProButton()
        }
        else {
            self.hideProButton()
        }
    }
    func showProButton() {
        self.view.addSubview(proButton)
        proButton.translatesAutoresizingMaskIntoConstraints = false

        let constraints = [
            proButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            proButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            proButton.widthAnchor.constraint(equalToConstant: 100),
            proButton.heightAnchor.constraint(equalToConstant: 34)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    func hideProButton() {
        proButton.removeFromSuperview()
    }
    // MARK: - Actions
    @IBAction func soundStateChanged(_ switch: UISwitch) {
        Task {
            await reloadComposition()
        }
    }
    // MARK: - Sections Logic
    func addSection(sectionVC: SectionViewController) {
        addChild(sectionVC)
        sectionContainerView.addSubview(sectionVC.view)
        sectionVC.view.translatesAutoresizingMaskIntoConstraints = false

        let constraints = [
            sectionVC.view.topAnchor.constraint(equalTo: sectionContainerView.topAnchor),
            sectionVC.view.leftAnchor.constraint(equalTo: sectionContainerView.leftAnchor),
            sectionVC.view.rightAnchor.constraint(equalTo: sectionContainerView.rightAnchor),
            sectionVC.view.bottomAnchor.constraint(equalTo: sectionContainerView.bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
        
        sectionVC.didMove(toParent: self)
    }
    
    func addSpeedSection() {
        speedSectionVC = SpeedSectionVC()
        
        speedSectionVC.sliderValueChange = { [weak self] (speed: Float) -> () in
//            self?.showProButtonIfNeeded()
        }
        
        speedSectionVC.speedDidChange = { [weak self] (speed: Float) -> () in
            self?.speed = speed
           
            Task {
              await self?.reloadComposition()
            }
        }
        
        addSection(sectionVC: speedSectionVC)
    }
    
    func addLoopSection() {
        loopSectionVC = LoopSectionVC()
        loopSectionVC.loopSettingsChanged = { [weak self] (numberOfLoops,loopStartingPoint) in
            self?.loopStartingPoint = loopStartingPoint
            self?.numberOfLoops = numberOfLoops
//            self?.showProButtonIfNeeded()
            
            Task {
              await self?.reloadComposition()
            }
        }
        
        
        addSection(sectionVC: loopSectionVC)
    }
    
    func addSoundSection() {
        soundSectionVC = SoundSectionVC()
        soundSectionVC.soundStateDidChange = {[weak self] soundOn in
            self?.soundOn = soundOn
//            self?.showProButtonIfNeeded()
            Task {
              await self?.reloadComposition()
            }
        }
        
        addSection(sectionVC: soundSectionVC)
    }
    
    func showSpeedSection() {
        speedSectionVC.view.isHidden = false
        loopSectionVC.view.isHidden = true
        soundSectionVC.view.isHidden = true
    }
    
    func showLoopSection() {
        speedSectionVC.view.isHidden = true
        loopSectionVC.view.isHidden = false
        soundSectionVC.view.isHidden = true

    }

    func showSoundSection() {
        speedSectionVC.view.isHidden = true
        loopSectionVC.view.isHidden = true
        soundSectionVC.view.isHidden = false

    }
    
    func showProgreeView() {
        view.addSubview(progressIndicatorView)
        progressIndicatorView.translatesAutoresizingMaskIntoConstraints = false

        let constraints = [
            progressIndicatorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressIndicatorView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            progressIndicatorView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            progressIndicatorView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
        progressIndicatorView.progressView.progress = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let progress = self?.exportSession?.progress else { return }
            self?.progressIndicatorView.progressView.progress = progress
        }

    }
    
    func removeProgressView() {
        timer?.invalidate()
        timer = nil
        progressIndicatorView.removeFromSuperview()
    }
    @objc func proButtonTapped() {
         showPurchaseViewController()
     }
    
    // MARK: - Custom Logic
    @objc func tryToExportVideo() {
        
        guard let _ = SpidProducts.store.userPurchasedProVersion() else {
            InterstitialAd.manager.showAd(controller: self) { [weak self] in
                    self?.playerController.player?.play()
                    self?.exportVideo()
            }
            return
        }

        exportVideo()
//        let businessModelType = RemoteConfig.remoteConfig().configValue(forKey: "business_model_type").numberValue.intValue
//        let businessModel = BusinessModelType(rawValue: businessModelType)
//        switch businessModel {
//        case .onlyProVersionExport:
//            guard let _ = SpidProducts.store.userPurchasedProVersion() else {
//                showPurchaseViewController()
//                return
//            }
//
//            exportVideo()
//        case .allowedReverseExport:
//           guard let _ = SpidProducts.store.userPurchasedProVersion() else {
//               if !UserDataManager.main.usingProFeatures() {
//                   self.playerController.player?.pause()
//                   InterstitialAd.manager.showAd(controller: self) { [weak self] in
//                       self?.playerController.player?.play()
//                       self?.exportVideo()
//                   }
//               }
//               else {
//                   showProFeatureAlert()
//               }
//               return
//            }
//
//            exportVideo()
//        case .none:
//            fatalError()
//        }

    }
    
    @objc func updateExportProgress() {
        guard let progress = exportSession?.progress else { return }
        progressIndicatorView.progressView.progress = progress
    }

    func showPurchaseViewController() {
        let purchaseViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PurchaseViewController") as! PurchaseViewController
        
        purchaseViewController.onDismiss = { [weak self] in
            if let _ = SpidProducts.store.userPurchasedProVersion() {
                self?.hideProButton()
            }
        }
        if UIDevice.current.userInterfaceIdiom == .phone {
            purchaseViewController.modalPresentationStyle = .fullScreen
        }
        else if UIDevice.current.userInterfaceIdiom == .pad {
            purchaseViewController.modalPresentationStyle = .formSheet
        }

        self.present(purchaseViewController, animated: true)
    }
    
    func showNoTracksError() {
        let alert = UIAlertController(
          title: "Error",
          message: "Couldn't find video tracks",
          preferredStyle: .alert)
        alert.addAction(UIAlertAction(
          title: "OK",
          style: UIAlertAction.Style.cancel,
          handler: { [weak self] _ in
              self?.navigationController?.popViewController(animated: true)
          }))
        present(alert, animated: true, completion: nil)
    }
    
    func loopVideo() {
      NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { [weak self] notification in
          self?.playerController.player?.seek(to: .zero)
          self?.playerController.player?.play()
      }
    }
}


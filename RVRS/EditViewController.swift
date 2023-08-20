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

class EditViewController: UIViewController {
    var playerController: AVPlayerViewController!
    var asset: AVAsset!
    var reversedAsset: AVAsset!
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
    
    lazy var loadingView: LoadingView = {
        loadingView = LoadingView()
        return loadingView
    }()
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    lazy var progressIndicatorView: ProgressIndicatorView = {
        progressIndicatorView = ProgressIndicatorView()
        return progressIndicatorView
    }()
    
    
    @IBOutlet weak var dashboardContainerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
                
        showSpeedSection()
        asset = AVAsset(url: assetUrl)
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let fileExtension = "mov"
         let videoName = UUID().uuidString
         let outputURL = URL(fileURLWithPath: NSTemporaryDirectory())
           .appendingPathComponent(videoName)
           .appendingPathExtension(fileExtension)
        
        Task {
            showLoading()
            let session = await AssetReverseSession(asset: self.asset, outputFileURL: outputURL)
            let reversedAsset = try await session.reverse()
            hideLoading()
            let playerItem = AVPlayerItem(asset: reversedAsset)
            playerItem.audioTimePitchAlgorithm = .spectral
            let player = AVPlayer(playerItem: playerItem)
            self.playerController = AVPlayerViewController()
            self.playerController.player = player
            self.addPlayerToTop()
            self.loopVideo()
        }
    }
    
//    func reverseAsset(completion: @escaping (AVAsset?) -> ()) {
//        reverseVideo { [weak self] reversedVideo in
//            guard let self = self else {return}
//            guard let reversedVideo = reversedVideo else {
//                return completion(nil)
//            }
//            
//            Task {
//                if let audioFileURL = await self.extractAudioTrackToFileIfExists(asset: self.asset),
//                   let reversedAudioUrl = self.reverseAudio(fromUrl: audioFileURL) {
//                    let reversedAudio = AVAsset(url: reversedAudioUrl)
//                    
//                    // combine reversed audio asset to video
//                    let reversedAsset = await self.integrate(reversedVideo: reversedVideo, reversedAudio: reversedAudio)
//                    if reversedAsset != nil {
//                        self.reversedAsset = reversedAsset
//                        completion(reversedAsset)
//                    }
//                    else {
//                        completion(nil)
//                    }
//                }
//                else {
//                    self.reversedAsset = reversedVideo
//                    completion(reversedVideo)
//                }
//            }
//        }
//    }

    
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
        
//    func reverseVideo(completion: @escaping (AVAsset?) -> ()) {
//        Task {
//            let assetReader = try! AVAssetReader(asset: asset)
//            guard let videoTrack = try? await asset.loadTracks(withMediaType: .video).first else {
//                return completion(nil)
//            }
//            let trackDuration = try! await asset.load(.duration)
//            let naturalSize = try! await videoTrack.load(.naturalSize)
//            let outputSettings: [String: NSNumber] = [
//                                           String(kCVPixelBufferWidthKey): NSNumber(value: naturalSize.width),
//                                           String(kCVPixelBufferHeightKey): NSNumber(value: naturalSize.height)]
//            
//            
//
//            let dispatchGroup = DispatchGroup()
//            dispatchGroup.enter()
//
//            let videoTrackOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: outputSettings)
//            var audioTrackOutput: AVAssetReaderTrackOutput?
//            assetReader.add(videoTrackOutput)
//            assetReader.timeRange = CMTimeRange(start: .zero, duration: trackDuration)
//
//            let success = assetReader.startReading()
//            if !success {
//                return print("start reading failed: \(assetReader.status)")
//            }
//            
//            var buffers = [CMSampleBuffer]()
//            while let nextBuffer = videoTrackOutput.copyNextSampleBuffer() {
//                buffers.append(nextBuffer)
//            }
//            
//            var audionSampleBuffers = [CMSampleBuffer]()
//            if let audioTrackOutput = audioTrackOutput {
//                while let nextBuffer = audioTrackOutput.copyNextSampleBuffer() {
//                    audionSampleBuffers.append(nextBuffer)
//                }
//            }
//           
//            
//            let status = assetReader.status
//            guard status == .completed else { return }
//            
//            let fileExtension = "mov"
//            let videoName = UUID().uuidString
//            let writeURL = URL(fileURLWithPath: NSTemporaryDirectory())
//              .appendingPathComponent(videoName)
//              .appendingPathExtension(fileExtension)
//            
//            let compressionVideoSettings: [String:Any] = [
//                        AVVideoCodecKey : AVVideoCodecType.h264,
//                        AVVideoWidthKey : naturalSize.width,
//                        AVVideoHeightKey: naturalSize.height,
//            ]
//            
//            guard let assetWriter = try? AVAssetWriter(url: writeURL, fileType: .mov) else { return }
//
//            let writerVideoInput: AVAssetWriterInput
//            if let formatDescription = try? await videoTrack.load(.formatDescriptions).first {
//                writerVideoInput = AVAssetWriterInput(mediaType: .video, outputSettings: compressionVideoSettings, sourceFormatHint: formatDescription)
//            } else {
//                writerVideoInput = AVAssetWriterInput.init(mediaType: .video, outputSettings: compressionVideoSettings)
//            }
//            
//            let preferredTransform = try! await videoTrack.load(.preferredTransform)
//            let (orientation, _) = VideoHelper.orientation(from: preferredTransform)
//            writerVideoInput.transform = VideoHelper.getVideoTransform(orientation: orientation)
//            let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerVideoInput, sourcePixelBufferAttributes: nil)
//            
//                        
//            assetWriter.add(writerVideoInput)
//            assetWriter.shouldOptimizeForNetworkUse = true
//            assetWriter.startWriting()
//            assetWriter.startSession(atSourceTime: .zero)
//
//            
//            var currentSampleIndex = 0
//            writerVideoInput.requestMediaDataWhenReady(on: DispatchQueue.main) {
//                for i in currentSampleIndex..<buffers.count {
//                    currentSampleIndex = i
//                    guard writerVideoInput.isReadyForMoreMediaData else {return}
//                    
//                    let presentationTime = CMSampleBufferGetPresentationTimeStamp(buffers[i])
//                    guard let imageBuffer = CMSampleBufferGetImageBuffer(buffers[buffers.count - i - 1]) else {
//                        print("VideoWriter reverseVideo: warning, could not get imageBuffer from SampleBuffer...")
//                        continue
//                    }
//                    if !pixelBufferAdaptor.append(imageBuffer, withPresentationTime: presentationTime) {
//                        print("VideoWriter reverseVideo: warning, could not append imageBuffer...")
//                    }
//                }
//                
//                writerVideoInput.markAsFinished()
//                dispatchGroup.leave()
//            }
//            
//            
//            dispatchGroup.notify(queue: DispatchQueue.main) {
//                Task {
//                    await assetWriter.finishWriting()
//                    if assetWriter.status != .completed {
//                        print("VideoWriter reverseVideo: error - \(String(describing: assetWriter.error))")
//                    } else {
//                         let reversedVideo = AVAsset(url: writeURL)
//                         completion(reversedVideo)
//                    }
//                }
//            }
//        }
//    }
    
    
    func createCompositionWith(speed: Float, fps: Int32, soundOn: Bool) async -> (composition: AVMutableComposition, videoComposition: AVMutableVideoComposition)? {
        let composition = AVMutableComposition(urlAssetInitializationOptions: nil)

        let compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: 1)!
        
        if let audioTracks = try? await reversedAsset.loadTracks(withMediaType: .audio),
           soundOn && audioTracks.count > 0 {
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
        guard let (composition, videoComposition) = await createCompositionWith(speed: speed, fps: fps, soundOn: soundOn) else {
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
        let theComposition = composition.copy() as! AVComposition
        let videoComposition = videoComposition.copy() as! AVVideoComposition
        
        guard let exportSession = AVAssetExportSession(
          asset: theComposition,
          presetName: AVAssetExportPresetHighestQuality)
          else {
            print("Cannot create export session.")
            return
        }
        
        self.exportSession = nil
        self.exportSession = exportSession
        
        let fileExtension = fileType == .mov ? "mov" : "mp4"
        let videoName = UUID().uuidString
        let exportURL = URL(fileURLWithPath: NSTemporaryDirectory())
          .appendingPathComponent(videoName)
          .appendingPathExtension(fileExtension)
        
        exportSession.videoComposition = videoComposition
        exportSession.outputFileType = fileType
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
              message: "Video failed to save",
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
        self.playerController.player?.play()
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
    
    
    // MARK: - Actions
    
    // MARK: - Sections Logic
    func addSection(sectionVC: SectionViewController) {
        addChild(sectionVC)
        dashboardContainerView.addSubview(sectionVC.view)
        sectionVC.view.translatesAutoresizingMaskIntoConstraints = false

        let constraints = [
            sectionVC.view.topAnchor.constraint(equalTo: dashboardContainerView.topAnchor),
            sectionVC.view.leftAnchor.constraint(equalTo: dashboardContainerView.leftAnchor),
            sectionVC.view.rightAnchor.constraint(equalTo: dashboardContainerView.rightAnchor),
            sectionVC.view.bottomAnchor.constraint(equalTo: dashboardContainerView.bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
        
        sectionVC.didMove(toParent: self)
    }
    
    
    func showSpeedSection() {

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
    
    
    // MARK: - Custom Logic
    @objc func updateExportProgress() {
        guard let progress = exportSession?.progress else { return }
        progressIndicatorView.progressView.progress = progress
    }

    func showPurchaseViewController() {
        let purchaseViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PurchaseViewController") as! PurchaseViewController
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


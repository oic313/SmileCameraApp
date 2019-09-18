//
//  ViewController.swift
//  CameraTest
//
//  Created by K.N on 2019/09/16.
//  Copyright © 2019 K.N. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate{
    
    var captureSession: AVCaptureSession? = nil
    var videoDevice: AVCaptureDevice?
    var previewLayer: AVCaptureVideoPreviewLayer? = nil
    // DISMISS_COUNT に1回画像処理 （captureの実行)
    var counter = 0
    let DISMISS_COUNT = 10
    var startFlag: Bool = false
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var reverseButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.setupCaptureSession(withPosition: .back)
        self.view.bringSubviewToFront(reverseButton)
        self.view.bringSubviewToFront(startButton)

        //プレビューの表示
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        self.previewLayer?.frame = self.view.bounds
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.view.layer.addSublayer(self.previewLayer!)
        
    }
    
    @IBAction func startButtonPushed(_ sender: Any) {
        if startFlag == false{
            startFlag = true
            startButton.setTitle("撮影中", for: .normal)
            startButton.setTitleColor(UIColor.red, for: .normal)
        }else{
            startFlag = false
            startButton.setTitle("撮影", for: .normal)
            startButton.setTitleColor(UIColor.blue, for: .normal)
        }
    }
    
    @IBAction func reverseCamera(_ sender: Any) {
        self.reverseCameraPosition()
    }
    
    func setupCaptureSession(withPosition cameraPosition: AVCaptureDevice.Position) {
        self.videoDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: cameraPosition)
        
        self.captureSession = AVCaptureSession()
        
        //セッションにInPutするデバイスを登録
        let videoInput = try! AVCaptureDeviceInput(device: self.videoDevice!)
        self.captureSession?.addInput(videoInput)
        
        //フレーム毎に呼び出すデリゲート登録
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable as! String : Int(kCVPixelFormatType_32BGRA)]
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        //セッションにOutput情報を追加
        self.captureSession?.addOutput(videoDataOutput)
        //スタート
        self.captureSession?.startRunning()
    }

    func reverseCameraPosition() {
        //セッションの終了
        self.captureSession?.stopRunning()
        self.captureSession?.inputs.forEach { input in
            self.captureSession?.removeInput(input)
        }
        self.captureSession?.outputs.forEach { output in
            self.captureSession?.removeOutput(output)
        }
        //新しいセッションを
        let newCameraPosition: AVCaptureDevice.Position = self.videoDevice?.position == .front ? .back : .front
        self.setupCaptureSession(withPosition: newCameraPosition)
        let newVideoLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession!)
        newVideoLayer.frame = self.view.bounds
        newVideoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        //プレビューの入れ替え
        self.view.layer.replaceSublayer(self.previewLayer!, with: newVideoLayer)
        self.previewLayer = newVideoLayer
    }

    //新しいキャプチャの追加で呼ばれる関数
    func captureOutput(_ captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if (self.counter % self.DISMISS_COUNT) == 0, self.startFlag == true{
            let image = imageFromSampleBuffer(sampleBuffer: sampleBuffer)
            if self.smileDecision(image: image){
                
            }
        }
        self.counter += 1
    }
    
    
    // SampleBufferからUIImageの作成
    private func imageFromSampleBuffer(sampleBuffer :CMSampleBuffer) -> UIImage {
        
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        
        // イメージバッファのロック
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        // 画像情報を取得
        let base = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)!
        let bytesPerRow = UInt(CVPixelBufferGetBytesPerRow(imageBuffer))
        let width = UInt(CVPixelBufferGetWidth(imageBuffer))
        let height = UInt(CVPixelBufferGetHeight(imageBuffer))
        
        // ビットマップコンテキスト作成
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitsPerCompornent = 8
        let bitmapInfo = CGBitmapInfo(rawValue: (CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue) as UInt32)
        let newContext = CGContext(data: base, width: Int(width), height: Int(height), bitsPerComponent: Int(bitsPerCompornent), bytesPerRow: Int(bytesPerRow), space: colorSpace, bitmapInfo: bitmapInfo.rawValue)! as CGContext
        
        // イメージバッファのアンロック
        CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        // 画像作成
        let imageRef = newContext.makeImage()!
        let image = UIImage(cgImage: imageRef, scale: 1.0, orientation: UIImage.Orientation.right)
        
        return image
    }

    //笑顔判定
    private func smileDecision(image :UIImage) -> Bool{
        var saveFlag = false

        //ciImage変換(向き情報消失)
        let ciImage = CIImage(image: image)!
        let detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options:  [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        //デバイスの向き判定
        let orientation = setCIDetectorImageOrientation()
        //画像判定
        if let features = detector?.features(in: ciImage, options: [CIDetectorSmile: true, CIDetectorEyeBlink : true, CIDetectorImageOrientation : orientation]){
            
            if features.count > 0{ saveFlag = true }
            (features as? [CIFaceFeature])?.forEach{
                if $0.hasSmile{
//                    print("------------------smile---------------------")
                }else{
//                    print("<<<<<<<<<<<<smile nothing>>>>>>>>>>>>>>>>>>>>>")
                    saveFlag = false
                }
//                print($0.leftEyeClosed)
//                print($0.rightEyeClosed)
                if $0.leftEyeClosed||$0.rightEyeClosed{
                    saveFlag = false
                }
            }
            
            if saveFlag == true{
                // アルバムに追加
                UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
                captureSession?.stopRunning()
                //数秒処理を止める
                Thread.sleep(forTimeInterval: 5.0)
                captureSession?.startRunning()
            }
        }
        return saveFlag

    }
    
    private func setCIDetectorImageOrientation() -> Int{
        var orientation = 6
        if self.videoDevice?.position == .back{
            switch UIDevice.current.orientation{
            case .portrait:
                orientation = 6
            case .portraitUpsideDown:
                orientation = 8
            case .landscapeLeft:
                orientation = 1
            case .landscapeRight:
                orientation = 3
            default:
                orientation = 6
            }
        }else if self.videoDevice?.position == .front{
            switch UIDevice.current.orientation{
            case .portrait:
                orientation = 6
            case .portraitUpsideDown:
                orientation = 8
            case .landscapeLeft:
                orientation = 3
            case .landscapeRight:
                orientation = 1
            default:
                orientation = 6
            }
        }
        return orientation
    }

}

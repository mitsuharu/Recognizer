//
//  ViewController.swift
//  RecogApp
//
//  Created by Mitsuharu Emoto on 2017/08/31.
//  Copyright © 2017年 Seesaa inc. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let imageClassifierModel = ImageClassifier()
    let charaKeys: [String] = ["KagamiharaNadeshiko",
                               "ShimaRin",
                               "OogakiChiaki",
                               "InuyamaAoi",
                               "SaitoEna"]
    let charaNameDict: [String:String] = ["KagamiharaNadeshiko":"各務原なでしこ",
                                          "InuyamaAoi":"犬山あおい",
                                          "ShimaRin":"志摩リン",
                                          "SaitoEna":"斉藤恵那",
                                          "OogakiChiaki":"大垣千明"]
 
    var observations:[VNClassificationObservation]? = nil
    var hasCaptureDeviceAuth: Bool = false
    let session = AVCaptureSession()
    var device: AVCaptureDevice?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var connection : AVCaptureConnection?
    var alert: UIAlertController? = nil
    var isComputing:Bool = false
    var isPausing:Bool = false
    
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var detectedImageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let clearedWhiteColor:UIColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0.6)
        self.resultView.backgroundColor = UIColor.clear
        self.pauseButton.backgroundColor = clearedWhiteColor
        self.tableView.backgroundColor = clearedWhiteColor
        self.resultLabel.backgroundColor = clearedWhiteColor
        
        self.requestCaptureDeviceAuth { (auth) in
            DLOG("auth: " + String(auth))
            self.hasCaptureDeviceAuth = auth
            if auth == true{
                self.setupVideoCapture()
                self.startSession()
            }else{
                self.showAlert(title: "エラー", message: "カメラにアクセスできません")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.hasCaptureDeviceAuth {
            self.startSession()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.hasCaptureDeviceAuth {
            stopSession()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }
    
    @IBAction func didTapPauseButton(sender:UIButton?){
        self.isPausing = !self.isPausing
        
        if let button:UIButton = sender{
            var str = "動作中"
            if self.isPausing {
                str = "停止中"
            }
            button.setTitle(str, for: UIControlState.normal)
        }
    }
}

// MARK: - setup video
extension ViewController{
    
    func showAlert(title:String?, message:String?) -> Void {
        
        if let av = self.alert{
            av.dismiss(animated: false, completion: nil)
        }
        self.alert = nil
        
        self.alert = UIAlertController(title: title,
                                       message: message,
                                       preferredStyle: UIAlertControllerStyle.alert)
        if let av = self.alert{
            av.addAction(UIAlertAction(title: "OK",
                                       style: .default,
                                       handler: nil))
            self.present(av, animated: true, completion: nil)
        }
    }
}

// MARK: - setup video
extension ViewController{
    
    /**
     カメラアクセスの許可リクエスト
     */
    func requestCaptureDeviceAuth(completion:((_ authorized:Bool) -> Void )?) -> Void {
        let mediaType = AVMediaType.video
        let status =  AVCaptureDevice.authorizationStatus(for: mediaType)
        if status == AVAuthorizationStatus.authorized {
            completion?(true)
        } else if status == AVAuthorizationStatus.notDetermined {
            AVCaptureDevice.requestAccess(for: mediaType,
                                          completionHandler: { (result) in
                                            DispatchQueue.main.async {
                                                completion?(result)
                                            }
            })
        }else if status == AVAuthorizationStatus.restricted || status == AVAuthorizationStatus.denied  {
             completion?(false)
        }
    }
    
    
    private var isActualDevice: Bool {
        return TARGET_OS_SIMULATOR != 1
    }
    
    private func startSession() {
        print("startSession")
        
        guard isActualDevice else { return }
        if !session.isRunning {
            session.startRunning()
        }
    }
    
    private func stopSession() {
        print("stopSession")
        guard isActualDevice else { return }
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    func setupVideoCapture() {
        DLOG()
        
        guard isActualDevice else { return }
        
        let device = AVCaptureDevice.default(for: AVMediaType.video)!
        self.device = device
        session.sessionPreset = AVCaptureSession.Preset.inputPriority
        device.formats.forEach { (format) in
            print(format)
        }
        print("format:",device.activeFormat)
        print("min duration:", device.activeVideoMinFrameDuration)
        print("max duration:", device.activeVideoMaxFrameDuration)
        
        do {
            try device.lockForConfiguration()
        } catch {
            fatalError()
        }
        device.activeVideoMaxFrameDuration = CMTimeMake(1, 3)
        device.activeVideoMinFrameDuration = CMTimeMake(1, 3)
        device.unlockForConfiguration()
        

        // Input
        let deviceInput: AVCaptureDeviceInput
        do {
            deviceInput = try AVCaptureDeviceInput(device: device)
        } catch {
            fatalError()
        }
        guard session.canAddInput(deviceInput) else {
            fatalError()
        }
        session.addInput(deviceInput)
        
        // Preview:
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.layer.bounds
        previewLayer.contentsGravity = kCAGravityResizeAspectFill
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.insertSublayer(previewLayer, at: 0)
        self.previewLayer = previewLayer
        
        // Output
        let output = AVCaptureVideoDataOutput()
        let key = kCVPixelBufferPixelFormatTypeKey as String
        let val = kCVPixelFormatType_32BGRA as NSNumber
        output.videoSettings = [key: val]
        output.alwaysDiscardsLateVideoFrames = true
        let queue = DispatchQueue(label: Bundle.main.bundleIdentifier!) // DispatchQueue(label: "net.kenmaz.momomind")
        output.setSampleBufferDelegate(self, queue: queue)
        guard session.canAddOutput(output) else {
            fatalError()
        }
        session.addOutput(output)
        
        self.connection = output.connection(with: AVMediaType.video)

    }
 
}

// MARK: - Video Capture

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection)
    {
        if connection.videoOrientation != .portrait {
            connection.videoOrientation = .portrait
            return
        }
        
        if self.isPausing {
            
        }else if self.isComputing == false {
            self.isComputing = true

            let image = uiImageFromCMSamleBuffer(buffer: sampleBuffer)
            self.detectFaces(image: image,
                             completion: { (result) in
//                self.isComputing = false
            })

        }
    }
}

//MARK: - detect and recognize faces

extension ViewController{
    
    // CMSampleBufferをUIImageに変換する
    func uiImageFromCMSamleBuffer(buffer:CMSampleBuffer)-> UIImage {
        let pixelBuffer:CVImageBuffer = CMSampleBufferGetImageBuffer(buffer)!
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        let pixelBufferWidth = CGFloat(CVPixelBufferGetWidth(pixelBuffer))
        let pixelBufferHeight = CGFloat(CVPixelBufferGetHeight(pixelBuffer))
        let imageRect:CGRect = CGRect(x: 0, y:0, width:pixelBufferWidth, height: pixelBufferHeight)
        let ciContext = CIContext()
        let cgimage = ciContext.createCGImage(ciImage, from: imageRect )
        
        let image = UIImage(cgImage: cgimage!)
        return image
    }
    
    // 顔認識
    func detectFaces(image:UIImage, completion:((_ authorized:Bool) -> Void )?) -> Void {
        
        image.detectFaces { (detect_faces, error) in
            var result:Bool = false;
            if let faces = detect_faces{
                // 作り上，検出された顔領域の１つだけを使う
                if let value = faces.first{
                    let faceImage = image.croppedImage(value.cgRectValue)
                    self.predicate(image: faceImage!)
                    DispatchQueue.main.async {
                        self.detectedImageView.image = faceImage
                    }
                    result = true;
                    
                    if let cmp = completion{
                        cmp(result)
                    }
                }
            }
            if result == false{
                self.isComputing = false
                if let cmp = completion{
                    cmp(result)
                }
            }
        }
    }
    
    // 予測
    func predicate(image: UIImage) {
        
        let image = CIImage(cgImage: image.cgImage!)
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            let model = try VNCoreMLModel(for: self.imageClassifierModel.model)
            let req = VNCoreMLRequest(model: model, completionHandler: self.handleClassification)
            try handler.perform([req])
        } catch {
            self.isComputing = false
            print(error)
        }
    }
    
    // 推定結果
    private func handleClassification(request: VNRequest, error: Error?) {
        
        guard let observations = request.results as? [VNClassificationObservation] else { fatalError() }
        guard let best = observations.first else { fatalError() }
        
        DispatchQueue.main.async {
            print("best identifier: " + best.identifier + ", prob: " + String(best.confidence*100))

            let name:String = self.charaNameDict[best.identifier]!
            
            var strLabel:String = ""
            let rate = best.confidence*100
            if rate > 80{
                strLabel = " " + name + " ぞい"
            }else if rate > 60{
                strLabel = " " + name + " かも"
            }
            
            self.observations = observations
            self.tableView.reloadData()
            self.resultLabel.text = strLabel
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.isComputing = false
            }
        }
    }
    

}
        
extension ViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.charaKeys.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let h = tableView.frame.height/CGFloat(self.charaKeys.count)
        return CGFloat(ceilf(Float(h)))
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell",
                                             for: indexPath)
        cell.backgroundColor = self.tableView.backgroundColor
        
        let rcell:ResultCell = cell as! ResultCell
        let key = charaKeys[indexPath.row]
        
        rcell.backgroundColor = self.tableView.backgroundColor
        rcell.nameLabel.text = self.charaNameDict[key]
        rcell.progressbar.progress = 0.0
        
        if let obs = self.observations{
            for ob in obs{
                if ob.identifier == key{
                    rcell.progressbar.progress = ob.confidence
                }
            }
        }

        return cell
    }
    
    
    
    
    
}

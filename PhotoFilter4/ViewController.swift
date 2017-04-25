//
//  ViewController.swift
//  PhotoFilter4
//
//  Created by kin on 01.09.16.
//  Copyright © 2016 kin. All rights reserved.
//

import UIKit
import Photos
import AVFoundation
import AssetsLibrary





class ViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var cameraView: UIView!
    
    
    var imagePhoto: UIImage!{
        didSet(photoWasSaved) {
            performSegue(withIdentifier: "imageToCellVC", sender: AnyObject?.self)
        }
    }
    
    
    let picker = UIImagePickerController()
    var captureSession = AVCaptureSession()
    var sessionOutput = AVCaptureStillImageOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    var activeInput: AVCaptureDeviceInput!
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
        setupSession()
        setupPreview()
        startSession()
        
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let connection =  self.previewLayer.connection  {
            
            let currentDevice: UIDevice = UIDevice.current
            
            let orientation: UIDeviceOrientation = currentDevice.orientation
            
            let previewLayerConnection : AVCaptureConnection = connection
            
            if previewLayerConnection.isVideoOrientationSupported {
                
                switch (orientation) {
                case .portrait: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                
                    break
                    
                case .landscapeRight: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
                
                    break
                    
                case .landscapeLeft: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
                
                    break
                    
                case .portraitUpsideDown: updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
                
                    break
                    
                default: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                
                    break
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Custom Camera ///
    
    
    // MARK: - Setup session
    
    func setupSession() {
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        let camera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                activeInput = input
            }
        } catch {
            print("Error setting device input: \(error)")
        }
        
        sessionOutput.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
        if captureSession.canAddOutput(sessionOutput) {
            captureSession.addOutput(sessionOutput)
        }
        
    }
    
    // MARK: - Setup preview
    
    
    func setupPreview() {
        
        // Configure previewLayer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = cameraView.bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        cameraView.layer.addSublayer(previewLayer)
        
    }
    
    // MARK: - Start Stop Session
    
    func startSession() {
        if !captureSession.isRunning {
            videoQueue().async {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        if captureSession.isRunning {
            videoQueue().async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func videoQueue() -> DispatchQueue {
        //return DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)??????
        return DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
        
        
    }
    
    // SwitchCamera
    
    @IBAction func switchCamera(_ sender: UIBarButtonItem) {
        // Make sure the device has more than 1 camera.
        if AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo).count > 1 {
            // Check which position the active camera is.
            var newPosition: AVCaptureDevicePosition!
            if activeInput.device.position == AVCaptureDevicePosition.back {
                newPosition = AVCaptureDevicePosition.front
            } else {
                newPosition = AVCaptureDevicePosition.back
            }
            
            // Get camera at new position.
            var newCamera: AVCaptureDevice!
            let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
            for device in devices! {
                if (device as AnyObject).position == newPosition {
                    newCamera = device as! AVCaptureDevice
                }
            }
            
            // Create new input and update capture session.
            do {
                let input = try AVCaptureDeviceInput(device: newCamera)
                captureSession.beginConfiguration()
                // Remove input for active camera.
                captureSession.removeInput(activeInput)
                // Add input for new camera.
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                    activeInput = input
                } else {
                    captureSession.addInput(activeInput)
                }
                captureSession.commitConfiguration()
            } catch {
                print("Error switching cameras: \(error)")
            }
        }
        
    }
    
    // MARK:     Take Photo
    
    @IBAction func takePhoto(_ sender: UIButton) {
        let connection = sessionOutput.connection(withMediaType: AVMediaTypeVideo)
        if (connection?.isVideoOrientationSupported)! {
            connection?.videoOrientation = currentVideoOrientation()
            
        }
        sessionOutput.captureStillImageAsynchronously(from: connection) { (sampleBuffer, error ) in
            if sampleBuffer != nil {
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                let image = UIImage(data: imageData!)
                let orimage = image?.fixedOrientation()
                self.imagePhoto = orimage
            } else {
                print("Error capturing photo: \(error?.localizedDescription)")
            }
        }
    }
    
    
    func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        layer.videoOrientation = orientation
        previewLayer.frame = self.view.bounds
        
    }
    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation
        
        switch UIDevice.current.orientation {
        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait
        case .landscapeRight:
            orientation = AVCaptureVideoOrientation.landscapeLeft
        case .portraitUpsideDown:
            orientation = AVCaptureVideoOrientation.portraitUpsideDown
        default:
            orientation = AVCaptureVideoOrientation.landscapeRight
            
        }
        
        return orientation
    }
    
    
    // Open Library
    
    @IBAction func openPhotoLibarary(_ sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
            let photoImageView = UIImagePickerController()
            photoImageView.delegate = self
            photoImageView.sourceType = UIImagePickerControllerSourceType.photoLibrary
            photoImageView.allowsEditing = true
            self.present(photoImageView, animated: true, completion: nil)
            
        }
        
    }
    
    // Choose Image Library
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismiss(animated: false, completion: nil)
        imagePhoto = image
        print(image.size)
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "imageToCellVC" {
            if let destinationVC = segue.destination as? CellVC {
                
                destinationVC.selectedImage = imagePhoto
                
            }
        }
        
    }
    
    
    
    
    
}


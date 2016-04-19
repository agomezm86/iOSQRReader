//
//  QRViewController.swift
//  iOSQRReader
//
//  Created by Alejandro Gomez Mutis on 4/19/16.
//  Copyright © 2016 Alejandro Gomez Mutis. All rights reserved.
//

import UIKit
import AVFoundation

protocol QRViewControllerDelegate {
    func QRCodeDidReceived(message: String)
}

class QRViewController: UIViewController {

    @IBOutlet weak var QRCodePreview: UIView!
    
    var delegate: QRViewControllerDelegate?
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        startReading()
    }
    
    func startReading() {
        let captureDevice: AVCaptureDevice? = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        let input: AVCaptureDeviceInput?
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession = AVCaptureSession()
            captureSession!.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession!.addOutput(captureMetadataOutput)
            
            let queue = dispatch_queue_create("myQueue", nil)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: queue)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer!.frame = QRCodePreview.layer.bounds
            
            QRCodePreview.layer.addSublayer(videoPreviewLayer!)
            
            orientationChanged()
            
            NSNotificationCenter.defaultCenter().addObserver(self,
                                                             selector: Selector("orientationChanged"),
                                                             name: UIDeviceOrientationDidChangeNotification,
                                                             object: nil)
            
            captureSession!.startRunning()
            
        } catch {
            print(error)
        }
    }
    
    func stopReading() {
        captureSession!.stopRunning()
        captureSession = nil
        videoPreviewLayer!.removeFromSuperlayer()
    }
    
    func orientationChanged() {
        let deviceOrientation = UIDevice.currentDevice().orientation
        switch deviceOrientation {
        case .PortraitUpsideDown:
            videoPreviewLayer!.connection.videoOrientation = .PortraitUpsideDown
        case .Portrait:
            videoPreviewLayer!.connection.videoOrientation = .Portrait
        case .LandscapeLeft:
            videoPreviewLayer!.connection.videoOrientation = .LandscapeLeft
        default:
            videoPreviewLayer!.connection.videoOrientation = .LandscapeRight
        }
    }
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        performSelectorOnMainThread(Selector("stopReading"),
                                    withObject: nil,
                                    waitUntilDone: false)
        dispatch_async(dispatch_get_main_queue(), {
            self.navigationController!.popViewControllerAnimated(false)
        })
    }
}

extension QRViewController: AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        var message: String? = nil
        if let metadataObjects = metadataObjects {
            if metadataObjects.count > 0 {
                let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
                if metadataObj.type == AVMetadataObjectTypeQRCode {
                    message = metadataObj.stringValue!
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    performSelectorOnMainThread(Selector("stopReading"),
                                                withObject: nil,
                                                waitUntilDone: false)
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            self.delegate!.QRCodeDidReceived(message!)
            self.navigationController!.popViewControllerAnimated(false)
        })
    }
}

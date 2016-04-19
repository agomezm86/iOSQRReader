//
//  ViewController.swift
//  iOSQRReader
//
//  Created by Alejandro Gomez Mutis on 4/19/16.
//  Copyright © 2016 Alejandro Gomez Mutis. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var messageLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBarHidden = true
        messageLabel.hidden = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToQRView" {
            let controller = segue.destinationViewController as! QRViewController
            controller.delegate = self
        }
    }
}

extension ViewController: QRViewControllerDelegate {
    func QRCodeDidReceived(message: String) {
        messageLabel.hidden = false
        messageLabel.text = message
    }
}


//
//  ViewController.swift
//  TestBed
//
//  Created by Chris Searle on 06/12/2016.
//  Copyright © 2016 Chris Searle. All rights reserved.
//

import UIKit
import DJISDK

class ViewController: UIViewController, DJISDKManagerDelegate {

    @IBOutlet weak var logText: UITextView!
    
    var gimbal : DJIGimbal?
    var queue : NSOperationQueue?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    
        logText.text = logText.text.stringByAppendingString("Registering\n")
        
        DJISDKManager.registerApp("543cf12e0b70f66c6ea4c356", withDelegate: self)
    }
    

    func sdkManagerDidRegisterAppWithError(error: NSError?) {
        logText.text = logText.text.stringByAppendingString("Registered\n")
        
        if let error = error {
            logText.text = logText.text.stringByAppendingString("Registered with error \(error.localizedDescription)\n")
        } else {
            logText.text = logText.text.stringByAppendingString("Connecting\n")

            DJISDKManager.startConnectionToProduct()
        }
    }
    
    func sdkManagerProductDidChangeFrom(oldProduct: DJIBaseProduct?, to newProduct: DJIBaseProduct?) {
        if let product = newProduct {
            logText.text = logText.text.stringByAppendingString("Saw \(newProduct?.model)\n")
            
            if (product is DJIAircraft) {
                self.gimbal = (product as! DJIAircraft).gimbal
            } else if (product is DJIHandheld) {
                self.gimbal = (product as! DJIHandheld).gimbal
            }
        } else {
            logText.text = logText.text.stringByAppendingString("Disconnected\n")
        }
    }

    @IBAction func cancel(sender: AnyObject) {
        if let queue = self.queue {
            queue.cancelAllOperations()
        }
    }
    
    @IBAction func runTest(sender: AnyObject) {
        guard let gimbal = self.gimbal else {
            logText.text = logText.text.stringByAppendingString("No gimbal to test\n")

            return
        }
        
        queue = NSOperationQueue()
        queue!.name = "Test Queue"
        queue!.maxConcurrentOperationCount = 1
        
        let operation = AttitudeOperation(gimbal: gimbal, pitch: 10.5, roll: 9.8, yaw: 12.2)

        operation.completionBlock = {
            self.logText.text = self.logText.text.stringByAppendingString("Attitude operation completed\n")
            
            if operation.cancelled {
                self.logText.text = self.logText.text.stringByAppendingString("Attitude operation was cancelled\n")
            } else {
                self.logText.text = self.logText.text.stringByAppendingString("Attitude operation completed\n")
            }
        }
        
        
        let dummyOperation = NSBlockOperation { 
            self.logText.text = self.logText.text.stringByAppendingString("This represents a follow-on operation being performed\n")
        }
        
        operation.addDependency(dummyOperation)
        
        logText.text = logText.text.stringByAppendingString("Adding attitude operation\n")

        queue!.addOperations([operation, dummyOperation], waitUntilFinished: false)
    }
}


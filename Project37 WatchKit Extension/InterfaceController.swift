//
//  InterfaceController.swift
//  Project37 WatchKit Extension
//
//  Created by Dan on 5/1/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import Foundation
import WatchKit
import WatchConnectivity //R1

class InterfaceController: WKInterfaceController, WCSessionDelegate { //R3
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    } //S2
    
    @IBOutlet var welcomeText: WKInterfaceLabel!
    @IBOutlet var hideButton: WKInterfaceButton!
    @IBOutlet var resetButton: WKInterfaceButton!
    
    @IBAction func hideWelcomeText() {
        welcomeText.setHidden(true)
        hideButton.setHidden(true)
    } //S1
    
    @IBAction func deactivate() {
        hideButton.setHidden(false)
  
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }//R2

        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
       WKInterfaceDevice().play(.success)
        WKInterfaceDevice().play(.click)

    } //S3

}

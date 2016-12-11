//
//  InterfaceController.swift
//  weul8 Extension
//
//  Created by Marten Saflund on 2016-12-08.
//  Copyright © 2016 Far East Asia Development Co. Ltd. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    
    var gameScene: GameScene!

    @IBOutlet var skInterface: WKInterfaceSKScene!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        
        // load data
        //
        let graph = DataController.sharedInstance.nextGraph()
        graph?.printGraph()
        
        // Load the SKScene from 'GameScene.sks'
        if let scene = GameScene(fileNamed: "GameScene") {
            
            gameScene = scene
            
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            self.skInterface.presentScene(scene)
            
            // Use a value that will maintain a consistent frame rate
            self.skInterface.preferredFramesPerSecond = 30
        }
    }
    
    @IBAction func handleSingleTap(tapGesture: WKTapGestureRecognizer) {
        print("Tap")
        WKInterfaceDevice.current().play(.click)

        var tm = CGAffineTransform.identity
        let sx = gameScene.frame.size.width/WKInterfaceDevice.current().screenBounds.size.width
        let sy = gameScene.frame.size.height/WKInterfaceDevice.current().screenBounds.size.height
        let ox = self.contentFrame.origin.x
        let oy = self.contentFrame.origin.y
        
        tm = tm.scaledBy(x: sx, y: -sy)
        tm = tm.translatedBy(x: (gameScene.frame.origin.x + ox) / sx, y: (gameScene.frame.origin.y + oy) / sy)
        
        print("screenBounds: \(WKInterfaceDevice.current().screenBounds)")
        print("content frame: \(self.contentFrame)")
        print("gameScene frame: \(gameScene.frame)")
        print("anchor: \(gameScene.anchorPoint)")
        
        print("Transform: \(tm)")

        gameScene.didTap(tapGesture: tapGesture, tm: tm)
    }
    
    @IBAction func handleSwipeRight(swipeGesture: WKSwipeGestureRecognizer) {
        print("Swipe right")
        WKInterfaceDevice.current().play(.click)
        
        gameScene.didSwipe(swipeGesture: swipeGesture)
    }
    
    @IBAction func handleSwipeLeft(swipeGesture: WKSwipeGestureRecognizer) {
        print("Swipe left")
        WKInterfaceDevice.current().play(.click)
        
        gameScene.didSwipe(swipeGesture: swipeGesture)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}

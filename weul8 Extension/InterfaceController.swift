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
    var tm = CGAffineTransform.identity

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
            
            // Set transform for converting into scene coordinates
            let sx = fmin(gameScene.frame.size.width/contentFrame.size.width, gameScene.frame.size.height/contentFrame.size.height)
            let sy = sx
            tm = tm.translatedBy(x: gameScene.frame.origin.x-contentFrame.origin.x, y: -gameScene.frame.origin.y-contentFrame.origin.y).scaledBy(x: sx, y: -sy)
            
            // Present the scene
            self.skInterface.presentScene(scene)
            
            // Use a value that will maintain a consistent frame rate
            self.skInterface.preferredFramesPerSecond = 30
        }
    }
    
    @IBAction func handleSingleTap(tapGesture: WKTapGestureRecognizer) {
        print("\nTap")
        WKInterfaceDevice.current().play(.click)
        
        print("GameScene tapped: \(tapGesture.locationInObject())")
        print("\ttranslated: \(tapGesture.locationInObject().applying(tm))")
        print("screenBounds: \(WKInterfaceDevice.current().screenBounds)")
        print("content frame: \(contentFrame)")
        print("gameScene frame: \(gameScene.frame)")
        print("anchor: \(gameScene.anchorPoint)")
        print("tm: \(tm)")
        
        gameScene.tapped(location: tapGesture.locationInObject().applying(tm))

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

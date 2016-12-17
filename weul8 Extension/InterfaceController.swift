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
        
        // Load the SKScene from 'GameScene.sks'
        if let scene = GameScene(fileNamed: "GameScene") {
            
            gameScene = scene
            
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Set transform for converting into scene coordinates
            let sx = fmin(gameScene.frame.size.width/contentFrame.size.width, gameScene.frame.size.height/contentFrame.size.height)
            let sy = sx
            tm = tm.translatedBy(x: gameScene.frame.origin.x-contentFrame.origin.x, y: -gameScene.frame.origin.y-contentFrame.origin.y).scaledBy(x: sx, y: -sy)
            
            print("\n\(#function)")
            print("\tscreenBounds: \(WKInterfaceDevice.current().screenBounds)")
            print("\tcontent frame: \(contentFrame)")
            print("\tgameScene frame: \(gameScene.frame)")
            print("\tanchor: \(gameScene.anchorPoint)")
            print("\ttm: \(tm)")
            
            // Have scene display graph
            scene.displayGraph(contentFrame: contentFrame)
            
            // Present the scene
            self.skInterface.presentScene(scene)
            
            // Use a value that will maintain a consistent frame rate
            self.skInterface.preferredFramesPerSecond = 30
        }
    }
    
    @IBAction func handleSingleTap(tapGesture: WKTapGestureRecognizer) {
        print("\nTap: \(tapGesture.locationInObject())")
        print("\tconverted: \(tapGesture.locationInObject().applying(tm))")
        WKInterfaceDevice.current().play(.click)
        
        gameScene.didTap(location: tapGesture.locationInObject().applying(tm))

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

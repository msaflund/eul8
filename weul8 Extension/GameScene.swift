//
//  GameScene.swift
//  weul8 Extension
//
//  Created by Marten Saflund on 2016-12-08.
//  Copyright © 2016 Far East Asia Development Co. Ltd. All rights reserved.
//

import SpriteKit
import WatchKit

class GameScene: SKScene {
    
    var label: SKLabelNode!
    
    override func sceneDidLoad() {
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func didSwipe(swipeGesture: WKSwipeGestureRecognizer) {
        if swipeGesture.direction == .right {
            print("GameScene swiped right")
            moveSomeNode(who: label, amount: 100)
        } else if swipeGesture.direction == .left {
            print("GameScene swiped left")
            moveSomeNode(who: label, amount: -100)
        }
    }
    
    func moveSomeNode(who: SKNode, amount: CGFloat) {
        let move = SKAction.moveBy(x: amount, y: 0, duration: 1)
        move.timingMode = .easeOut
        
        who.run(move)
    }
}

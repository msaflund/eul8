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
    var testNode: SKSpriteNode!
    
    override func sceneDidLoad() {
        
        // Get nodes from scene and store for use later
        if let aLabel = self.childNode(withName: "//helloLabel") as? SKLabelNode {
            self.label = aLabel
        }
        else {
            self.label = SKLabelNode()
        }
        if let aNode = self.childNode(withName: "//testNode") as? SKSpriteNode {
            self.testNode = aNode
        }
        else {
            self.testNode = SKSpriteNode()
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func tapped(location: CGPoint) {
        
        let move = SKAction.move(to: location, duration: 0.2)
        move.timingMode = .easeOut
        
        if testNode.contains(location) {
            print("\t--> testNode hit")
        }
        
        self.testNode.run(move)
    }
    
    func didTap(tapGesture: WKTapGestureRecognizer, tm: CGAffineTransform) {
        let location = tapGesture.locationInObject()
        print("GameScene tapped: \(location)")
        print("\ttranslated: \(location.applying(tm))")
   
        let move = SKAction.move(to: location.applying(tm), duration: 0.25)
        move.timingMode = .easeOut
        
        self.testNode.run(move)
    }
    
    func didSwipe(swipeGesture: WKSwipeGestureRecognizer) {
        if swipeGesture.direction == .right {
            print("GameScene swiped right")
            moveSomeNode(who: label, amount: 100)
        }
        else if swipeGesture.direction == .left {
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

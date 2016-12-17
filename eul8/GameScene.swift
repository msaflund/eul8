//
//  GameScene.swift
//  eul8
//
//  Created by Marten Saflund on 2016-12-08.
//  Copyright © 2016 Far East Asia Development Co. Ltd. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var testNode: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        
        // Get nodes from scene and store for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        if let aNode = self.childNode(withName: "//testNode") as? SKSpriteNode {
            self.testNode = aNode
        }
        else {
            self.testNode = SKSpriteNode()
        }
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        
        if testNode.contains(pos) {
            print("\t--> testNode hit")
            if let node = self.testNode {
                node.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
            }
        }
        else {
            let move = SKAction.move(to: pos, duration: 0.2)
            move.timingMode = .easeOut
            
            self.testNode.run(move)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

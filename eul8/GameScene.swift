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
    private var pinTag: SKSpriteNode?
    private var graphNode: SKShapeNode?
    private var nodes: Set<Node> = Set()
    private var bridges: Set<Bridge> = Set()
    private var graph: Graph?
    private var here: Node?
    private var graphTransform = CGAffineTransform.identity
    private var locked = false
    
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
        if let tag = self.childNode(withName: "//pinTag") as? SKSpriteNode {
            tag.isHidden = true
            tag.zPosition = 1.0
            self.pinTag = tag
        }
        
        loadGame()
    }
    
    func loadGame(replay: Bool = false) {
        
        // if there's an old node, move off screen, remove from parent
        if let oldNode = self.graphNode {
            
            nodes.removeAll()
            bridges.removeAll()
            
            let moveUp = SKAction.moveBy(x: 0.0, y: self.view!.frame.size.height*2, duration: 0.25)
            moveUp.timingMode = .easeIn
            let remove = SKAction.removeFromParent()
            
            oldNode.run(SKAction.sequence([moveUp, remove]))
            
            
            
            self.here = nil
        }
        
        let sceneScale = fmin(size.width/self.view!.frame.size.width,
                              size.height/self.view!.frame.size.height)
        
        // Get Graph
        if let aGraph = DataController.sharedInstance.graph(increment: !replay) {
            self.graph = aGraph
            
            let gBounds = aGraph.bounds
            
            // Create transform
            self.graphTransform = CGAffineTransform.identity
            let sx = fmin(sceneScale*self.view!.frame.size.width/(gBounds.size.width+2*maxVertexRadius),
                          sceneScale*self.view!.frame.size.height/(gBounds.size.height+2*maxVertexRadius))
            let tx = -gBounds.size.width/2 - gBounds.origin.x
            let ty = -gBounds.size.height/2 - gBounds.origin.y
            graphTransform = graphTransform.scaledBy(x: sx, y: sx).translatedBy(x: tx, y: ty)
            
            print("\n\(#function)")
            print("\tsceneScale: \(sceneScale)")
            print("\tcontentFrame: \(self.view!.frame)")
            print("\tgBounds: \(gBounds)")
            print("\tgraphTransform: \(graphTransform)")
            
            // make node
            let newNode = makeGraphNode(with: aGraph)
            
            newNode.position = CGPoint(x: newNode.position.x, y: newNode.position.y - self.view!.frame.size.height*2)
            self.addChild(newNode)
            
            let moveIn = SKAction.moveBy(x: 0.0, y: self.view!.frame.size.height*2, duration: 0.25)
            moveIn.timingMode = .easeOut
            let wait = SKAction.wait(forDuration: 0.15)
            
            newNode.run(SKAction.sequence([wait, moveIn]))
            
            self.graphNode = newNode
            self.locked = false
        }
    }
    
    func makeGraphNode(with graph: Graph) -> SKShapeNode {
        
        self.graph = graph
        
        let gn = SKShapeNode()
        
        // add vertex shapes
        for vi in graph.vertices {
            let n = Node(v: vi, radius: maxVertexRadius, transform: self.graphTransform)
            nodes.insert(n)
            gn.addChild(n.shape!)
        }
        
        // add edge shapes
        for ei in graph.edges {
            let b = Bridge(e: ei, width: 6.0, transform: self.graphTransform)
            bridges.insert(b)
            gn.addChild(b.shape)
        }
        
        return gn
    }
    
    // MARK: - Operations
    
    func neighborNodes(_ n1: Node, _ n2: Node) -> Bool {
        return graph!.adjacent(n1.vertex, n2.vertex)
    }
    
    func bridgePassed(_ b: Bridge) -> Bool {
        return b.edge.flag
    }
    
    func passBridge(_ b: Bridge) {
        b.toggleFlag()
    }
    
    func bridgeAvailable(n1: Node?, n2: Node?) -> Bridge? {
        guard n1 != nil && n2 != nil else {
            return nil
        }
        
        for b in bridges {
            if b.isBridge(between: n1!, n2!) && !bridgePassed(b) {
                return b
            }
        }
        
        return nil
    }
    
    func eulerPath(g: Graph) -> Bool {
        for e in g.edges {
            if !e.flag {
                return false
            }
        }
        return true
    }
    
    func moveNode(who: SKNode, to p: CGPoint) {
        let move = SKAction.move(to: p, duration: 0.5)
        move.timingMode = .easeOut
        
        who.run(move)
    }
    
    func moveNode(who: SKNode, by p: CGPoint) {
        let move = SKAction.moveBy(x: p.x, y: p.y, duration: 0.5)
        move.timingMode = .easeIn
        
        who.run(move)
    }
    
    func tryBridge(from a: Node, to b: Node) {
        
        // move if there's an available bridge
        if let bridge = bridgeAvailable(n1: a, n2: b) {
            passBridge(bridge)
            
            self.here = b
            
            if let pin = self.pinTag as SKSpriteNode! {
                pin.isHidden = false
                moveNode(who: pin, to: here!.position)
            }
            //                            shape.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
            
            // evaluate
            if eulerPath(g: self.graph!) {
                print("\t--> path complete")
                self.locked = true
                self.pinTag?.isHidden = true
                loadGame()
            }
        }
    }
    
    // MARK: - Actions
    
    func didTap(location: CGPoint) {
        guard !self.locked else { return }
        
        for node in self.nodes {
            if let shape = node.shape {
                
                if shape.contains(location) {
                    print("\t--> node hit")
                    
                    // special case before starting point chosen
                    if self.here != nil {
                        tryBridge(from: self.here!, to: node)
                    }
                    else {
                        
                        self.here = node
                        
                        if let pin = self.pinTag as SKSpriteNode! {
                            pin.position = here!.position
                            pin.isHidden = false
                        }
                        //                        shape.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
                        
                    }
                }
            }
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
        
        didTap(location: pos)
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

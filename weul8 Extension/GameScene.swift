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
    var pinTag: SKSpriteNode?
    private var graph: Graph!
    private var graphNode: SKShapeNode!
    private var nodes: Set<Node> = Set()
    private var bridges: Set<Bridge> = Set()
    private var contentFrame: CGRect!
    private var graphTransform = CGAffineTransform.identity
    private var locked: Bool = false
    private var here: Node?
    
    override func sceneDidLoad() {
        // Get nodes from scene and store for use later
        if let aLabel = self.childNode(withName: "//helloLabel") as? SKLabelNode {
            self.label = aLabel
        }
        else {
            self.label = SKLabelNode()
        }
        if let tag = self.childNode(withName: "//pinTag") as? SKSpriteNode {
            tag.isHidden = true
            tag.zPosition = 1.0
            self.pinTag = tag
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    // MARK: - Graph Nodes
    
    func displayGame(contentFrame: CGRect) {
        
        self.contentFrame = contentFrame
        
        loadGame()
    }
    
    func loadGame(replay: Bool = false) {
        
        // if there's an old node, move off screen, remove from parent
        if let oldNode = self.graphNode {
            
            nodes.removeAll()
            bridges.removeAll()
            
            let moveUp = SKAction.moveBy(x: 0.0, y: self.contentFrame.size.height*2, duration: 0.25)
            moveUp.timingMode = .easeIn
            let remove = SKAction.removeFromParent()
            
            oldNode.run(SKAction.sequence([moveUp, remove]))
            
            
            
            self.here = nil
        }
        
        let sceneScale = fmin(size.width/contentFrame.size.width,
                              size.height/contentFrame.size.height)
        
        // Get Graph
        if let aGraph = DataController.sharedInstance.graph(increment: !replay) {
            self.graph = aGraph
            
            let gBounds = graph.bounds
            
            // Create transform
            self.graphTransform = CGAffineTransform.identity
            let sx = fmin(sceneScale*contentFrame.size.width/(gBounds.size.width+2*maxVertexRadius),
                          sceneScale*contentFrame.size.height/(gBounds.size.height+2*maxVertexRadius))
            let tx = -gBounds.size.width/2 - gBounds.origin.x
            let ty = -gBounds.size.height/2 - gBounds.origin.y
            graphTransform = graphTransform.scaledBy(x: sx, y: sx).translatedBy(x: tx, y: ty)
            
            print("\n\(#function)")
            print("\tsceneScale: \(sceneScale)")
            print("\tcontentFrame: \(contentFrame)")
            print("\tgBounds: \(gBounds)")
            print("\tgraphTransform: \(graphTransform)")
            
            // make node
            let newNode = makeGraphNode(with: self.graph)
            
            newNode.position = CGPoint(x: newNode.position.x, y: newNode.position.y - self.contentFrame.size.height*2)
            self.addChild(newNode)
            
            let moveIn = SKAction.moveBy(x: 0.0, y: self.contentFrame.size.height*2, duration: 0.25)
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
        return graph.adjacent(n1.vertex, n2.vertex)
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
    
    // MARK: - Actions
    
    func didTap(location: CGPoint) {
        guard !self.locked else { return }
        
        for node in self.nodes {
            if let shape = node.shape {
                
                if shape.contains(location) {
                    print("\t--> node hit")
                    
                    // special case before starting point chosen
                    if self.here != nil {
                        
                        // move if there's an available bridge
                        if let b = bridgeAvailable(n1: self.here, n2: node) {
                            passBridge(b)
                            
                            self.here = node
                            
                            if let pin = self.pinTag as SKSpriteNode! {
                                pin.isHidden = false
                                moveNode(who: pin, to: here!.position)
                            }
//                            shape.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
                            
                            // evaluate
                            if eulerPath(g: self.graph) {
                                print("\t--> path complete")
                                self.locked = true
                                self.pinTag?.isHidden = true
                                loadGame()
                            }
                        }
                        
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
    
    func didFinishGame(replay: Bool) {
        self.locked = true
        self.pinTag?.isHidden = true
        loadGame(replay: replay)
    }
    
    func moveSomeNode(who: SKNode, amount: CGFloat) {
        let move = SKAction.moveBy(x: amount, y: 0, duration: 0.5)
        move.timingMode = .easeOut
        
        who.run(move)
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
}

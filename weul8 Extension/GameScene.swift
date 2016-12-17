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
    private var graph: Graph!
    private var graphNode: SKShapeNode!
    private let nodes = NSMutableSet()
    private let bridges = NSMutableSet()
    private var contentFrame: CGRect!
    private var graphTransform = CGAffineTransform.identity
    private var locked: Bool = false
    
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
    
    // MARK: - Graph Nodes
    
    func displayGraph(contentFrame: CGRect) {
        
        self.contentFrame = contentFrame
        let sceneScale = fmin(size.width/contentFrame.size.width,
                              size.height/contentFrame.size.height)
        
        // Get Graph
        if let aGraph = DataController.sharedInstance.graph(withIndex: 0) {
            self.graph = aGraph
            
            let gBounds = graph.bounds
            
            // Create transform
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
            self.graphNode = makeGraphNode(with: self.graph)
            self.addChild(self.graphNode)
        }
    }
    
    func makeGraphNode(with graph: Graph) -> SKShapeNode {
        
        // if there's an old node, move off screen, remove from parent
        // empty vertex set
        nodes.removeAllObjects()
        
        // add vertices to vertex set
        // create node with path
        self.graph = graph
        
        let gn = SKShapeNode.init(path: graphPath(graph))
        
        // set drawing specifics
        //
        gn.fillColor = UIColor.clear
        gn.strokeColor = UIColor.lightGray
        gn.lineWidth = 2.0
        
        // add vertex shapes
        //
        for vi in graph.vertices {
            let n = Node(v: vi, radius: maxVertexRadius, transform: self.graphTransform)
            nodes.add(n)
            gn.addChild(n.shape!)
        }
        
        return gn
    }
    
    func graphPath(_ graph: Graph) -> CGPath {
        
        // Create path for edges and placeholder vertices
        //
        let path = CGMutablePath()
        edgePath(path, graphTransform)
//        verticesPath(path, graphTransform)
        
        return path
    }
    
    /**
     Draw edges
     - parameter path:  Path to populate
     - parameter tm:    Affine transform to apply
     */
    func edgePath(_ path: CGMutablePath, _ tm: CGAffineTransform) {
        if graph != nil {
            for ei in graph!.edges {
                
                let p1 = ei.v1.position.applying(tm)
                let p2 = ei.v2.position.applying(tm)
                
                let a = abs(p2.y - p1.y)
                let b = abs(p2.x - p1.x)
                let hyp = sqrt(a*a + b*b)
                
                let v1Radius: CGFloat = maxVertexRadius*tm.a
                let v2Radius: CGFloat = maxVertexRadius*tm.d
                
                // if nodes do not intersect
                if hyp > (v2Radius + v1Radius) {
                    let alpha = asin(a/hyp)
                    var xprim = p1.x
                    var yprim = p1.y
                    var xbis  = p2.x
                    var ybis  = p2.y
                    
                    xprim = (xprim <= xbis)  ?	xprim + v1Radius * cos(alpha)	:	xprim - v1Radius * cos(alpha)
                    yprim = (yprim <= ybis)  ?	yprim + v1Radius * sin(alpha)	:	yprim - v1Radius * sin(alpha)
                    xbis  = (xprim <= xbis)	 ?	 xbis - v2Radius * cos(alpha)   :	 xbis + v2Radius * cos(alpha)
                    ybis  = (yprim <= ybis)  ?	 ybis - v2Radius * sin(alpha)	:	 ybis + v2Radius * sin(alpha)
                    
                    path.move(to: CGPoint(x: xprim, y: yprim)) 
                    path.addLine(to: CGPoint(x: xbis, y: ybis))
                }
            }
        }
    }
    
    //
    // draw a placeholder circle at the place of the vertex
    //
    func verticesPath(_ path: CGMutablePath, _ tm: CGAffineTransform) {
        if graph != nil {
            for vi in graph!.vertices {
                
                path.addEllipse(in: CGRect(x: vi.position.x - maxVertexRadius, y: vi.position.y - maxVertexRadius, width: 2*maxVertexRadius, height: 2*maxVertexRadius), transform: tm)
            }
        }
    }
    
    // MARK: - Actions
    
    func didTap(location: CGPoint) {
        
        if testNode.contains(location) {
            print("\t--> testNode hit")
            if let node = self.testNode {
                node.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
            }
        }
        else {
            let move = SKAction.move(to: location, duration: 0.2)
            move.timingMode = .easeOut
            self.testNode.run(move)
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
    
    func moveSomeNode(who: SKNode, amount: CGFloat) {
        let move = SKAction.moveBy(x: amount, y: 0, duration: 0.5)
        move.timingMode = .easeOut
        
        who.run(move)
    }
}

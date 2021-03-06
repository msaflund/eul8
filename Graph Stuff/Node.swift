//
//  Node.swift
//  Color-8
//
//  Created by Marten Saflund on 2015-10-13.
//  Copyright © 2015 Far East Asia Development Co. Ltd. All rights reserved.
//
//  Abstract
//  Node is the UI element representing a vertex in a view.
//  The affine transform is applied to the node's position.
//

import UIKit
import SpriteKit

class Node: Hashable {
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: Node, rhs: Node) -> Bool {
        return lhs.vertex == rhs.vertex
    }

    var shape: SKShapeNode?
    var radius: CGFloat
    var vertex: Vertex
    private var transform: CGAffineTransform?
    var color: Int {
        get {
            return vertex.color
        }
    }
    var origin: CGPoint {
        get {
            return vertex.position.applying(transform!)
        }
    }
    var position: CGPoint {
        get {
            return shape!.position
        }
        set(newPosition) {
            shape?.position = newPosition
        }
    }
    var hashValue: Int {
        return 1
    }
    
    init (v: Vertex!, radius: CGFloat = maxVertexRadius, transform: CGAffineTransform = CGAffineTransform.identity) {
        let n = SKShapeNode(ellipseOf: CGSize(width: 2*maxVertexRadius, height: 2*maxVertexRadius).applying(transform))
        shape = n

        self.vertex = v
        self.radius = radius - 1.0
        self.transform = transform
        self.position = v.position.applying(transform)
        
        n.fillColor = colorIndex(v.color)
//        n.glowWidth = 1.5
        n.lineWidth = 2.0
        n.strokeColor = UIColor.white
    }
    
    func colorIndex(_ idx: Int) -> UIColor {
        
        switch idx {
        case 0:
            return UIColor.red
        case 1:
            return UIColor.green
        case 2:
            return UIColor.yellow
        case 3:
            return UIColor.blue
        case 4:
            return UIColor.orange
        case 5:
            return UIColor.magenta
        case 6:
            return UIColor.cyan
        default:
            return UIColor.gray
        }
    }
    
    func setTransform(_ tm: CGAffineTransform) {
        transform = tm
        position = vertex.position.applying(tm)
    }
    
    // MARK: Operations
    
    //
    // visual feedback when moving node
    //
    func accentuate(_ expand: Bool) {
        let scale : CGFloat = expand ? 2.50 : 1.0
        shape?.run(SKAction.scale(to: scale, duration:0.15))
    }
    
    // MARK: Queries
    
    func isHit(_ location: CGPoint) -> Bool {
        if let s = shape {
            return s.contains(location)
        }
        return false
    }
}

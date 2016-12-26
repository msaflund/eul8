//
//  Bridge.swift
//  eul8
//
//  Created by Marten Saflund on 2016-12-23.
//  Copyright © 2016 Far East Asia Development Co. Ltd. All rights reserved.
//

import Foundation
import SpriteKit

class Bridge: Hashable {
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: Bridge, rhs: Bridge) -> Bool {
        return lhs.edge == rhs.edge
    }

    var shape = SKShapeNode()
    var width: CGFloat
    var edge: Edge
    private var transform: CGAffineTransform?
    var color: UIColor {
        get {
            return edge.flag ? UIColor.lightGray : UIColor.orange
        }
    }
    var position: CGPoint {
        get {
            return shape.position
        }
        set(newPosition) {
            shape.position = newPosition
        }
    }
    var hashValue: Int {
        return 1
    }
    
    init (e: Edge!, width: CGFloat = 3.0, transform: CGAffineTransform = CGAffineTransform.identity) {
        
        self.edge = e
        self.width = width
        self.transform = transform
        
        let n = SKShapeNode(path: makePath(edge: e, tm: transform))
        n.fillColor = color
        n.lineWidth = 3.0
        n.strokeColor = n.fillColor
//        n.glowWidth = 1.5
        
        self.shape = n
    }
    
    func toggleFlag() {
        self.edge.flag = !self.edge.flag
        self.shape.fillColor = color
        self.shape.strokeColor = color
    }
    
    func makePath(edge ei: Edge, tm: CGAffineTransform) -> CGMutablePath {
        
        let path = CGMutablePath()
        let radius = maxVertexRadius + 1.0
        
        let p1 = ei.v1.position.applying(tm)
        let p2 = ei.v2.position.applying(tm)
        
        let a = abs(p2.y - p1.y)
        let b = abs(p2.x - p1.x)
        let hyp = sqrt(a*a + b*b)
        
        let v1Radius: CGFloat = radius*tm.a
        let v2Radius: CGFloat = radius*tm.d
        
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
        
        return path
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
    
    // MARK: Queries
    
    func isHit(_ location: CGPoint) -> Bool {
        return shape.contains(location)
    }
    
    func isBridge(between n1: Node, _ n2: Node) -> Bool {
        let v1 = n1.vertex
        let v2 = n2.vertex
        
        return (edge.v1 == v1 && edge.v2 == v2) || (edge.v1 == v2 && edge.v2 == v1)
    }
}


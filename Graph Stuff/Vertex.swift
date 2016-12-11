//
//  Vertex.swift
//  Color-8
//
//  Created by Marten Saflund on 2015-10-13.
//  Copyright © 2015 Far East Asia Development Co. Ltd. All rights reserved.
//
//  Abstract:
//  An undirected graph G = (V, E)
//  Vertex has a fixed position and a default color, and the topology of the graph is never changed.
//  The coordinate position can change if the graph's geometry is manipulated with a transformation matrix.
//  Vertex can change color, swapping with an adjacent vertex, but storing it's original, default color.
//  Unique id of a vertex is it's object id. vi == vj iff vi === vj
//

import UIKit

class Vertex: Hashable {
    var color: Int
    let defaultColor: Int
    var adjList = NSMutableSet()
    // geometry
    private let pos: CGPoint
    var position: CGPoint {
        get {
            return pos
        }
    }
    var hashValue: Int {
        return 1
    }
    
    init(color: Int, position pos: CGPoint) {
        self.defaultColor = color
        self.color = color
        self.pos = pos
    }
    
    //
    // undirected connect
    //
    func connect(_ v: Vertex) {
        self.adjList.add(v)
        v.adjList.add(self)
    }
}

// MARK: Convenience

func == (lhs: Vertex, rhs: Vertex) -> Bool {
    return lhs === rhs
}

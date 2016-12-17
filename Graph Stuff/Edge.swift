//
//  Edge.swift
//  Color-8
//
//  Created by Marten Saflund on 2015-10-15.
//  Copyright © 2015 Far East Asia Development Co. Ltd. All rights reserved.
//
//  Abstract:
//  An undirected graph G = (V, E)
//  Edge is undirected, (vi, vj) is equal to (vj, vi)
//

import Foundation

class Edge: Hashable {
    let v1: Vertex
    let v2: Vertex
    var flag: Bool = false
    var hashValue:Int {
        return 1
    }
    
    init(v1: Vertex, v2: Vertex) {
        self.v1 = v1
        self.v2 = v2
        flag = (v1.color % 2) == 0
    }
}

// MARK: Convenience

func == (lhs: Edge, rhs: Edge) -> Bool {
    if lhs.v1 == rhs.v1 {
        return lhs.v2 == rhs.v2
    }
    if lhs.v1 == rhs.v2 {
        return lhs.v2 == rhs.v1
    }
    return false
}

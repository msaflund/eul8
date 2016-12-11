//
//  Graph.swift
//  Color-8
//
//  Created by Marten Saflund on 2015-10-13.
//  Copyright © 2015 Far East Asia Development Co. Ltd. All rights reserved.
//
//  Abstract:
//  Manage the graph G = (V, E)
//  Topology of G is defined by each vertex' adjacency list.
//  G is geometry agnostic. The only geometrical information (coordinates) for
//  the graph are the positions of each vertex.
//

import UIKit

let minVertexRadius: CGFloat = 12.5
let maxVertexRadius: CGFloat = 20
let accentuateFactor: CGFloat = 0.3
let maxColors = 4

class Graph {
    var vertices = [Vertex]()       // v0, .., vn     order is important, required to map configurations to vertices
    var edges = Set<Edge>()         // (vi, vj), .., (vm, vn)
    var xg: Int?
    var minMoves: Int?
    var bounds: CGRect {
        get {
            var xmin = CGFloat.greatestFiniteMagnitude
            var ymin = CGFloat.greatestFiniteMagnitude
            var xmax = CGFloat.leastNormalMagnitude
            var ymax = CGFloat.leastNormalMagnitude
            for vi in vertices {
                let p = vi.position
                xmin = fmin(p.x, xmin);
                ymin = fmin(p.y, ymin);
                xmax = fmax(p.x, xmax);
                ymax = fmax(p.y, ymax);
            }
            return CGRect(x: xmin, y: ymin, width: xmax-xmin, height: ymax-ymin)
        }
    }
    
    init(vertexArray: [Vertex]) {
        vertices.append(contentsOf: vertexArray)
    }
    
    init(graphData: GraphData) {
        
        self.xg = graphData.xg
        self.minMoves = graphData.minMoves
        
        let vArray = NSMutableArray()
        for i in 0 ... graphData.v.count-1 {
            let px = CGFloat(((graphData.v[i] )[0] as NSString).floatValue)
            let py = CGFloat(((graphData.v[i] )[1] as NSString).floatValue)
            let v = Vertex(color: graphData.startConfig[i] , position: CGPoint(x: px, y: py))
            add(v)
            vArray.add(v)
        }
        
        for i in 0 ... graphData.e.count-1 {
            let v1 = graphData.e[i][0] as Int
            let v2 = graphData.e[i][1] as Int
            connect(vArray[v1] as! Vertex, vArray[v2] as! Vertex)
        }
    }
    
    // MARK: Operations
    
    func add(_ v: Vertex) {
        vertices.append(v)
    }
    
    //
    // connect v1 and v2 iff v1, v2 belong to G. O(2n)
    //
    func connect(_ v1: Vertex, _ v2: Vertex) {
        if vertices.contains(where: {$0 === v1}) && vertices.contains(where: {$0 === v2}) {
            v1.connect(v2)
            edges.insert(Edge(v1: v1, v2: v2))
        }
        else {
            fatalError("trying to connect vertices not in graph")
        }
    }
    
    //
    // swap colors
    //
    func swapColors(_ v1: Vertex, _ v2: Vertex) {
        let tmpColor = v1.color
        v1.color = v2.color
        v2.color = tmpColor
    }
    
    // MARK: Queries
    
    //
    // are v1 and v2 neigbours? O(n)
    //
    func adjacent(_ v1: Vertex, _ v2: Vertex) -> Bool {
        for vi in v1.adjList {
            if vi as! Vertex == v2 {
                return true
            }
        }
        return false
    }
    
    //
    // true iff G is graph colored. O(n)
    //
    func graphColoring() -> Bool {
        for ei in edges {
            if ei.v1.color == ei.v2.color {
                return false
            }
        }
        return true
    }
    
    // MARK: Debug
    
    func printGraph() {
        print("\n#### Graph:")
        print("\t|V| = \(vertices.count)")
        print("\t|E| = \(edges.count)")
        print("\tXg: \(xg)")
        print("\tV:")
        for vi in vertices {
            print("\tcolor \(vi.color)", separator: "", terminator: "")
            print("\tposition (\(vi.position.x), \t\(vi.position.y))")
        }
        print("\tE:")
        for ei in edges {
            print("\t[(\(ei.v1.position.x), \t\(ei.v1.position.y)), \t(\(ei.v2.position.x), \t\(ei.v2.position.y))]")
        }
    }
}

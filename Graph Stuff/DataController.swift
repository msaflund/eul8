//
//  DataController.swift
//  Color-8
//
//  Created by Marten Saflund on 2015-10-23.
//  Copyright © 2015 Far East Asia Development Co. Ltd. All rights reserved.
//

import Foundation

struct GraphData {
    var name: String
    var v: [[String]]
    var e: [[Int]]
    var xg: Int
    var minMoves: Int
    var startConfig: [Int]
    var eulerPath: [Int]?
}

class SomeManager {
    static let sharedInstance = SomeManager()
}

class DataController {
    
    static let sharedInstance = DataController()
    
    private var graphs = [GraphData]()
    private var currentGraphIndex = 2
    
    init() {
        guard let graphPath = Bundle.main.path(forResource: "Graph", ofType: "plist")   else { fatalError("Cannot find Graph.plist") }
        guard let dataPath = Bundle.main.path(forResource: "Data", ofType: "plist")     else { fatalError("Cannot find Data.plist") }
        guard let graphArr = NSArray(contentsOfFile: graphPath)                         else { fatalError("Cannot read graph data") }
        guard let configDict = NSDictionary(contentsOfFile: dataPath)                   else { fatalError("Cannot read config data") }
        
        for i in 0...graphArr.count-1 {
            let gDict = graphArr[i] as! [String:AnyObject]
            let gName = gDict["Name"] as! String
            if let gConfigs = configDict.object(forKey: gName) as? [[String:AnyObject]] {
                for j in 0...gConfigs.count-1 {
                    let config = gConfigs[j]
                    graphs.append(GraphData(name: gName,
                                            v: gDict["V"] as! [[String]],
                                            e: gDict["E"] as! [[Int]],
                                            xg: gDict["xG"] as! Int,
                                            minMoves: config["MinMoves"] as! Int,
                                            startConfig: config["StartConfig"] as! [Int],
                                            eulerPath: config["EulerPath"] as? [Int])
                    )
                }                
            }
            else {
                print("WARNING: Cannot find configuration dictionary for '\(gName)'")
            }
        }
    }
    
    func graph(withIndex idx: Int) -> Graph? {
        guard idx < graphs.count && idx >= 0 else { return nil }
        self.currentGraphIndex = idx
        
        return Graph(graphData: graphs[idx])
    }
    
    func graph(increment: Bool = true) -> Graph? {
        if increment {
            self.currentGraphIndex = (self.currentGraphIndex + 1) % graphs.count
        }
        
        return Graph(graphData: graphs[self.currentGraphIndex])
    }
    
    func nextGraph() -> Graph? {
        self.currentGraphIndex = (self.currentGraphIndex + 1) % graphs.count
        
        return graph(withIndex: self.currentGraphIndex)
    }
    
    func previousGraph() -> Graph? {
        self.currentGraphIndex = self.currentGraphIndex > 0 ? self.currentGraphIndex - 1 : graphs.count - 1
        
        return graph(withIndex: self.currentGraphIndex)
    }
}

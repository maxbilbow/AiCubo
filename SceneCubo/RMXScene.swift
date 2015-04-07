//
//  RMXScene.swift
//  AiCubo
//
//  Created by Max Bilbow on 07/04/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation
import SceneKit

class RMXScene : SCNScene {
    
    init(named name: String, world: RMSWorld){
        super.init()
        var i:Int = 0
        
        let node = RMXNode().initWithParent(world)
        node.name = name.lastPathComponent.stringByDeletingPathExtension
        let mat = SCNMaterial()
        mat.name = name
        node.geometry?.insertMaterial(mat, atIndex: 0)
        
        self.rootNode.insertChildNode(node, atIndex: i)
        
        world.name = "World"
        self.rootNode.insertChildNode(world, atIndex: i+1)

    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
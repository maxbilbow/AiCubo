//
//  GameView.swift
//  SceneCubo
//
//  Created by Max Bilbow on 05/04/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import SceneKit

class GameView: RMSView ,RMXView {
    
    var world: RMSWorld? {
        return self.interface?.world
    }
    
    var observer: RMXSprite {
        return self.world!.observer
    }
    
    
    var interface: RMXInterface?
    var gvc: RMXViewController?
    
    func initialize(gvc: RMXViewController, interface: RMXInterface){
        self.gvc = gvc
        self.interface = interface
        self.delegate = self.interface
        let height = RMFloatB((observer.geometry! as! SCNCylinder).height)
        let radius = RMFloatB((observer.geometry! as! SCNCylinder).radius)
        let head = RMXModels.getNode(shapeType: ShapeType.SPHERE.rawValue, mode: .KINEMATIC, radius: radius * 1)
        self.observer.node.addChildNode(head)
        head.camera = RMXCamera()
        
        head.position = SCNVector3Make(0, height * 0.9, 0)
        self.observer.addCamera(head)
        self.pointOfView = head
    }
    
        
      
    func setWorld(type: RMXWorldType){
        if self.world!.type != type {
            self.world!.setWorldType(worldType: type)
        }
    }
    
       

    
}

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
    var interface: RMXInterface?
    var gvc: RMXViewController?
    
    func initialize(gvc: RMXViewController, interface: RMXInterface){
        self.gvc = gvc
        self.interface = interface
        self.delegate = self.interface
    }
    
        
      
    func setWorld(type: RMXWorldType){
        if self.world!.worldType != type {
            self.world!.setWorldType(worldType: type)
        }
    }
    
    var camera: RMXCamera {
        return self.world!.activeCamera
    }
    

    
}

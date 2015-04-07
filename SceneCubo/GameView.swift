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
    
    
    
override func mouseDown(theEvent: NSEvent) {
        /* Called when a mouse click occurs */
        
        // check what nodes are clicked
        let p = self.convertPoint(theEvent.locationInWindow, fromView: nil)
        if let hitResults = self.hitTest(p, options: nil) {
            // check that we clicked on at least one object
            if hitResults.count > 0 {
                // retrieved the first clicked object
                let result: AnyObject = hitResults[0]
                
                // get its material
                let material = result.node!.geometry!.firstMaterial!
                if let node = result.node as? RMXNode {
                    self.world?.observer.actions.grabItem(item: node)
                    RMXLog(node.label)
                }
                
                // highlight it
                SCNTransaction.begin()
                SCNTransaction.setAnimationDuration(0.5)
                
                // on completion - unhighlight
                SCNTransaction.setCompletionBlock() {
                    SCNTransaction.begin()
                    SCNTransaction.setAnimationDuration(0.5)
                    
                    material.emission.contents = NSColor.blackColor()
                    
                    SCNTransaction.commit()
                }
                
                material.emission.contents = NSColor.redColor()
                
                SCNTransaction.commit()
            }
        }
        
        super.mouseDown(theEvent)
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

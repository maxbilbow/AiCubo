//
//  GameView.swift
//  SceneCubo
//
//  Created by Max Bilbow on 05/04/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import SceneKit

class GameView: SCNView ,RMXView{
    
    var world: RMSWorld! = nil
    
    
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
    
    var viewMatrix: GLKMatrix4 {
        return self.camera.modelViewMatrix
    }
    

    var projectionMatrix: GLKMatrix4 {
        return self.camera.getProjectionMatrix(Float(self.bounds.size.width), height: Float(self.bounds.size.height))
    }
  
    func setWorld(type: RMXWorldType){
        if self.world.worldType != type {
            self.world.setWorldType(worldType: type)
        }
    }
    
    var camera: RMXCamera {
        return self.world.activeCamera
    }
    

    override func keyDown(theEvent: NSEvent) {
        
    }
}
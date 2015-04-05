//
//  RMXMetalView.swift
//  InstancedDrawing
//
//  Created by Max Bilbow on 05/04/2015.
//  Copyright (c) 2015 Metal By Example. All rights reserved.
//

import Foundation
import Metal
import UIKit


class MBEMetalView : UIView {

    var currentTouch:UITouch! = nil
    
    override class func layerClass() -> AnyClass {
//        super.layerClass()
        return CAMetalLayer().classForCoder
    }
    
    var metalLayer: CAMetalLayer {
        return self.layer as CAMetalLayer
    }
        
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.currentTouch = touches.anyObject() as UITouch
    }
    
    override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
        self.currentTouch = nil
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        self.currentTouch = nil;
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        self.currentTouch = touches.anyObject() as UITouch
    }
    
    func setFrame(frame:CGRect) {
        super.frame = frame
    
        // During the first layout pass, we will not be in a view hierarchy, so we guess our scale
        var scale:CGFloat = UIScreen.mainScreen().scale
    
        // If we've moved to a window by the time our frame is being set, we can take its scale as our own
        if self.window != nil {
            scale = self.window!.screen.scale
        }
        
        var drawableSize:CGSize = self.bounds.size
        
        // Since drawable size is in pixels, we need to multiply by the scale to move from points to pixels
        drawableSize.width *= scale;
        drawableSize.height *= scale;
        
        self.metalLayer.drawableSize = drawableSize
    }
}
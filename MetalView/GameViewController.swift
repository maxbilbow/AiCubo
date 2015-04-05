//
//  RMXViewController.swift
//  InstancedDrawing
//
//  Created by Max Bilbow on 05/04/2015.
//  Copyright (c) 2015 Metal By Example. All rights reserved.
//

import Foundation
import UIKit
import Metal

class RMTLViewController : UIViewController {
    static let MBERotationSpeed:Float = 3 // radians per second
    
    

    var renderer: MBERenderer
    var displayLink: CADisplayLink
    var angularVelocity: Float
    
    override func viewDidLoad() {
    super.viewDidLoad()
    
    self.renderer = RMXRenderer(self.metalView.metalLayer)
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self
    selector:@selector(displayLinkDidFire:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    
    var metalView: RMXMetalView {
        return self.view as RMXMetalView
    }
    
    - (BOOL)prefersStatusBarHidden
    {
    return YES;
    }
    
    - (void)updateMotion
    {
    self.renderer.frameDuration = self.displayLink.duration;
    
    UITouch *touch = self.metalView.currentTouch;
    
    if (touch)
    {
    CGRect bounds = self.view.bounds;
    float rotationScale = (CGRectGetMidX(bounds) - [touch locationInView:self.view].x) / bounds.size.width;
    
    self.renderer.velocity = 2;
    self.renderer.angularVelocity = rotationScale * MBERotationSpeed;
    }
    else
    {
    self.renderer.velocity = 0;
    self.renderer.angularVelocity = 0;
    }
    }
    
    - (void)displayLinkDidFire:(id)sender
    {
    [self updateMotion];
    
    [self.renderer draw];
    }
    
    
}
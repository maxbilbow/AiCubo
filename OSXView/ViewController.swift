//
//  ViewController.swift
//  Rattle Physics Beta
//
//  Created by Max Bilbow on 18/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
        
        
        
        //    override func awakeFromNib(){
        //        // create a new scene
        //       /* let scene = SCNScene()
        //
        //        // create and add a camera to the scene
        //        let cameraNode = SCNNode()
        //        cameraNode.camera = SCNCamera()
        //        scene.rootNode.addChildNode(cameraNode)
        //
        //        // place the camera
        //        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        //
        //        // create and add a light to the scene
        //        let lightNode = SCNNode()
        //        lightNode.light = SCNLight()
        //        lightNode.light!.type = SCNLightTypeOmni
        //        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        //        scene.rootNode.addChildNode(lightNode)
        //
        //        // create and add an ambient light to the scene
        //        let ambientLightNode = SCNNode()
        //        ambientLightNode.light = SCNLight()
        //        ambientLightNode.light!.type = SCNLightTypeAmbient
        //        ambientLightNode.light!.color = NSColor.darkGrayColor()
        //        scene.rootNode.addChildNode(ambientLightNode)
        //
        //        // retrieve the ship node
        //        let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
        //
        //        // animate the 3d object
        //        let animation = CABasicAnimation(keyPath: "rotation")
        //        animation.toValue = NSValue(SCNVector4: SCNVector4(x: CGFloat(0), y: CGFloat(1), z: CGFloat(0), w: CGFloat(M_PI)*2))
        //        animation.duration = 3
        //        animation.repeatCount = MAXFLOAT //repeat forever
        //        ship.addAnimation(animation, forKey: nil)
        //
        //        // set the scene to the view
        //        self.view!.scene = scene
        //
        //        // allows the user to manipulate the camera
        //        self.view!.allowsCameraControl = true
        //
        //        // show statistics such as fps and timing information
        //        self.gameView!.showsStatistics = true
        //
        //        // configure the view
        //        self.gameView!.backgroundColor = NSColor.blackColor() */
        //    }
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            RMXGLProxy.run()
            // Do any additional setup after loading the view.
        }
        
        override var representedObject: AnyObject? {
            didSet {
                // Update the view, if already loaded.
            }
        }
        
        
        @IBAction func launchGame(sender: AnyObject?) {
            
            autoreleasepool {
                RMXGLProxy.run()
            }
        }
}

class Menu : NSMenu {
    override func awakeFromNib() {
        super.awakeFromNib()
         RMXGLProxy.run()
    }
}

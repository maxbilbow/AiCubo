//
//  GameViewController.swift
//  SceneCubo
//
//  Created by Max Bilbow on 05/04/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import SceneKit
import QuartzCore
//, world: self.gameView.world!)
#if iOS
    typealias ViewController = UIViewController
//    typealias NSColor = UIColor
    #elseif OSX
    typealias ViewController = NSViewController
    #endif

class GameViewController: ViewController, RMXViewController, SCNSceneRendererDelegate {
    #if iOS
    weak var gameView: GameView? {
        return self.view as? GameView
    }
    #elseif OSX
    @IBOutlet weak var gameView: GameView?
    #endif
    
    
    lazy var interface: RMXInterface? = RMX.Controller(self,  scene: SCNScene(named: "art.scnassets/ship.dae")!)
    
    var world: RMSWorld? {
        return self.interface!.world
    }
   
    override func awakeFromNib(){
        // create a new scene
        #if iOS
        
        self.view = GameView(frame: self.view.bounds)
        #endif
        self.gameView!.initialize(self, interface: self.interface!)
        self.world?.setWorldType()
        let scene = self.world!.scene
        
        // create and add a camera to the scene
        let cameraNode = self.gameView!.world!.activeCamera

        self.gameView?.pointOfView = cameraNode
        
        // create and add a light to the scene
        let lightNode = self.gameView!.world!.sun.node
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeOmni

        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = NSColor.darkGrayColor()
        scene.rootNode.addChildNode(ambientLightNode)
        
       
        
        // retrieve the ship node
        
        
        let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
        ship.removeFromParentNode()
        lightNode.addChildNode(ship)
//        world?.addChildNode(ship)
        ship.transform = SCNMatrix4Translate(ship.transform,0,-1,0)
        ship.scale = SCNVector3Make(0.1,0.1,0.1)

        
        // animate the 3d object
        #if OSX
        let animation = CABasicAnimation(keyPath: "rotation")
        animation.toValue = NSValue(SCNVector4: SCNVector4(x: CGFloat(0), y: CGFloat(1), z: CGFloat(0), w: CGFloat(M_PI)*2))
        animation.duration = 10
        animation.repeatCount = MAXFLOAT //repeat forever
        ship.addAnimation(animation, forKey: nil)
            #elseif iOS
        ship.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 1, z: 0, duration: 10)))
            #endif
        
//        scene.rootNode.addChildNode(self.world!.node)
        // set the scene to the view
        self.gameView!.scene = scene
        
        // allows the user to manipulate the camera
        self.gameView!.allowsCameraControl = false
        
        // show statistics such as fps and timing information
        self.gameView!.showsStatistics = true
        
        // configure the view
        self.gameView!.backgroundColor = NSColor.lightGrayColor()
//        self.gameView?.pointOfView
    }
    


}

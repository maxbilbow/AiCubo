//
//  GameViewController.swift
//  SceneCubo
//
//  Created by Max Bilbow on 05/04/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import SceneKit
import QuartzCore

class GameViewController: NSViewController, RMXViewController, SCNSceneRendererDelegate {
    
    @IBOutlet weak var gameView: GameView?
    
    lazy var interface: RMXInterface? = RMSKeys(gvc: self)
    var world: RMSWorld? {
        return self.interface!.world
    }
   
    override func awakeFromNib(){
        // create a new scene
        self.gameView!.initialize(self, interface: self.interface!)
        let scene = SCNScene(named: "art.scnassets/ship.dae")!//, world: self.gameView.world!)
        
        // create and add a camera to the scene
        let cameraNode = self.gameView!.world!.observer
        cameraNode.hasGravity = false
        cameraNode.camera = self.gameView!.world!.activeCamera
        cameraNode.camera?.zFar = 2000
//        scene.rootNode.addChildNode(cameraNode)
        self.gameView?.pointOfView = cameraNode
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        cameraNode.startingPoint = cameraNode.position
        
        // create and add a light to the scene
        let lightNode = self.gameView!.world!.sun
//        lightNode.body?.rotationSpeed = 0.01
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeOmni
//        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
//        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = RMXNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = NSColor.darkGrayColor()
        scene.rootNode.addChildNode(ambientLightNode)
        
       
        
        // retrieve the ship node
        
        
        let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
//        let ship2 = RMXNode()//.initWithParent(self.world!)
//        ship2.geometry = ship.geometry
//        ship2.name = ship.name
//        ship2.physicsBody = ship.physicsBody
//        ship2.skinner = ship.skinner
//        
//        scene.rootNode.addChildNode(ship2)
//        self.world?.insertChildNode(ship2)
        
        // animate the 3d object
        let animation = CABasicAnimation(keyPath: "rotation")
        //animation.toValue = NSValue(SCNVector4: SCNVector4(x: CGFloat(0), y: CGFloat(1), z: CGFloat(0), w: CGFloat(M_PI)*2))
        //animation.duration = 300
        animation.repeatCount = MAXFLOAT //repeat forever
        ship.addAnimation(animation, forKey: nil)

        scene.rootNode.addChildNode(self.world!)
        // set the scene to the view
        self.gameView!.scene = scene
        
        // allows the user to manipulate the camera
        self.gameView!.allowsCameraControl = false
        
        // show statistics such as fps and timing information
        self.gameView!.showsStatistics = true
        
        // configure the view
        self.gameView!.backgroundColor = NSColor.blackColor()
//        self.gameView?.pointOfView
    }
    


}

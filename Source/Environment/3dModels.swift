//
//  3dModels.swift
//  AiCubo
//
//  Created by Max Bilbow on 16/04/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation
import SceneKit
enum ShapeType: Int { case NULL = 0, CUBE = 1 , PLANE = 2, SPHERE = 3, CYLINDER = 4, FLOOR, ROCK, OILDRUM , AUSFB, PONGO, LAST, PILOT, DOG}
class RMXModels {
    
    var rock: SCNGeometry?
    var oilDrum: SCNGeometry?
    var ausfb: SCNGeometry?
    static let pongo = SCNScene(named:"art.scnassets/Pongo/other/The Limited 4.dae")
    static let ausfb = SCNScene(named:"art.scnassets/AUSFB/ausfb.dae")
    static let dog = SCNScene(named:"art.scnassets/Dog/Dog.dae")
    static let pilot = SCNScene(named:"art.scnassets/ArmyPilot/ArmyPilot.dae")
    
    class func getNode(shapeType type: Int, mode: RMXSpriteType = .PASSIVE, radius r: RMFloatB? = nil, scale s: RMXVector3? = nil, color: NSColor! = nil) -> SCNNode {
        var hasColor = false
        var radius = r ?? 1
        var scale = s ?? SCNVector3Make(radius * 2,radius * 2,radius * 2)
        if r == nil {
            radius = RMFloatB(scale.average)
        }
        
        var node: SCNNode
        switch(type){
        case ShapeType.CUBE.rawValue:
            node = SCNNode(geometry: SCNBox(
                width: RMFloat(scale.x),
                height:RMFloat(scale.y),
                length:RMFloat(scale.z),
                chamferRadius:0.0)
            )
            break
        case ShapeType.SPHERE.rawValue:
            node = SCNNode(geometry: SCNSphere(radius: RMFloat(scale.y)))
            hasColor = true
            break
        case ShapeType.CYLINDER.rawValue:
            node = SCNNode(geometry: SCNCylinder(radius: RMFloat(scale.x), height: RMFloat(scale.y)))
            hasColor = true
            break
        case ShapeType.ROCK.rawValue:
            let url = NSBundle.mainBundle().URLForResource("art.scnassets/Rock1", withExtension: "dae")
            let source = SCNSceneSource(URL: url!, options: nil)
            let block = source!.entryWithIdentifier("Cube-mesh", withClass: SCNGeometry.self) as! SCNGeometry
            node = SCNNode(geometry: block)
            node.scale *= 5
            break
        case ShapeType.PLANE.rawValue:
             hasColor = true
            node = SCNNode(geometry: SCNPlane(width: RMFloat(scale.x), height: RMFloat(scale.y)))
            break
        case ShapeType.PONGO.rawValue:
            node = pongo?.rootNode.clone() as! SCNNode
            node.scale *= 0.01
            break
        case ShapeType.OILDRUM.rawValue:
            let url = NSBundle.mainBundle().URLForResource("art.scnassets/oildrum/oildrum", withExtension: "dae")
            let source = SCNSceneSource(URL: url!, options: nil)
            let block = source!.entryWithIdentifier("Cylinder_001-mesh", withClass: SCNGeometry.self) as! SCNGeometry
            node = SCNNode(geometry: block)
            node.scale *= 10
            break
            
        
        case ShapeType.DOG.rawValue:
            node = dog!.rootNode.clone() as! SCNNode
            node.scale *= 8
            break
            
        case ShapeType.AUSFB.rawValue:
            node = ausfb!.rootNode.clone() as! SCNNode
            node.scale *= 0.1
            break

        default:
            node = SCNNode(geometry: SCNBox(
                width: RMFloat(scale.x),
                height:RMFloat(scale.y),
                length:RMFloat(scale.z),
                chamferRadius:0.0)
            )
        }
        
        
        if hasColor && color != nil {
            node.geometry!.firstMaterial!.diffuse.contents = color
            node.geometry!.firstMaterial!.specular.contents = color
        }
        
        switch (mode){
        case .AI, .PLAYER, .PASSIVE:
            node.physicsBody = SCNPhysicsBody.dynamicBody()
            break
        case .WORLD, .BACKGROUND:
            node.physicsBody = SCNPhysicsBody.staticBody()
        default:
            if node.physicsBody == nil {
                node.physicsBody = SCNPhysicsBody.staticBody()
            }
        }
        node.scale *= scale
        node.physicsBody!.mass = CGFloat(radius)
        node.physicsBody!.restitution = 0.1
        return node
    }
    
}
//
//  RMSArt.swift
//  RattleGL
//
//  Created by Max Bilbow on 11/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import GLKit
#if SceneKit
    import SceneKit
    #endif

class RMXArt {
    static let colorBronzeDiff: [Float]  = [ 0.8, 0.6, 0.0, 1.0 ]
    static let colorBronzeSpec: [Float]  = [ 1.0, 1.0, 0.4, 1.0 ]
    static let colorBlue: [RMFloatB]        = [ 0.0, 0.0, 0.1, 1.0 ]
    static let colorNone: [Float]        = [ 0.0, 0.0, 0.0, 0.0 ]
    static let colorRed: [RMFloatB]         = [ 0.1, 0.0, 0.0, 1.0 ]
    static let colorGreen: [RMFloatB]       = [ 0.0, 0.1, 0.0, 1.0 ]
    static let colorYellow: [Float]      = [ 1.0, 0.0, 0.0, 1.0 ]
    static let nillVector: [Float]       = [ 0  ,   0,  0,  0   ]
    
    static let greenVector: RMXVector4 = RMXVector4Make(0.0, 0.1, 0.0, 1.0)
    static let yellowVector: RMXVector4 = RMXVector4Make(1.0, 1.0, 0.0, 1.0)
    static let blueVector: RMXVector4 = RMXVector4Make(0.0, 0.0, 1.0, 1.0)
    static let redVector: RMXVector4 = RMXVector4Make(1.0, 0.0, 0.0, 1.0)
    #if SceneKit
    static let CUBE = SCNBox(
        width: 1.0,
        height:1.0,
        length:1.0,
        chamferRadius:0.0)
    static let PLANE = SCNPlane(
        width: 1.0,
        height:1.0
    )
    
    static let SPHERE = SCNSphere(radius:0.5)
    static let CYLINDER = SCNCylinder(radius:0.5, height:1.0)
    
    static let greenMat: SCNMaterial = SPHERE.firstMaterial!.copy() as! SCNMaterial
    static let redMat: SCNMaterial = SPHERE.firstMaterial!.copy() as! SCNMaterial
    static let blueMat: SCNMaterial = SPHERE.firstMaterial!.copy() as! SCNMaterial
    
    #endif
    
    class func initializeTestingEnvironment(world: RMSWorld, withAxis drawAxis: Bool = true, withCubes noOfShapes: RMFloatB = 1000, radius: RMFloatB? = nil) -> RMSWorld {
        
        RMXArt.drawPlane(world)
        if drawAxis {
            RMXArt.drawAxis(world)
        }
        if noOfShapes > 0 {
            RMXArt.randomObjects(world, noOfShapes: noOfShapes, radius: radius)
        }
        return world
    }
    
    
    class func drawPlane(world: RMSWorld) {
        #if SceneKit

        let plane = SCNNode()
        plane.physicsBody = SCNPhysicsBody.staticBody()
        plane.geometry = RMXArt.PLANE
        plane.scale = world.node.scale
        plane.eulerAngles.x = 90 * PI_OVER_180
        plane.geometry!.firstMaterial!.doubleSided = true
        plane.geometry!.firstMaterial!.diffuse.contents =  NSColor.yellowColor()
        world.node.addChildNode(plane)
        #else
        
        let ZX = RMXSprite().initWithParent(world).setAsShape(type: .PLANE)
        ZX.body!.setRadius(world.body!.radius)
        ZX.body!.setPhi(upDownRadians: 90 * PI_OVER_180)
            ZX.setColor(self.yellowVector)
        ZX.isAnimated = false
        #if OPENGL_ES
            ZX.initPosition(startingPoint: RMXVector3Make(ZX.position.x, -ZX.radius, ZX.position.z))
            #endif
        world.insertChildNode(ZX)
        #endif
    }
    
    class func drawAxis(world: RMSWorld) {//xCol y:(float*)yCol z:(float*)zCol{
        
        
        func drawAxis(axis: String) {
            var point =  -world.radius
            #if !SceneKit
            var color: RMXVector4
                #else
                var color: NSColor
                #endif
            var scale: RMXVector3 = RMXVector3Make(10,10,10)
            switch axis {
            case "x":
                #if !SceneKit
                color = self.redVector
                    #else
                scale.x = world.node.scale.x
                    color = NSColor.redColor()
                    #endif
                break
            case "y":
                #if !SceneKit
                color = self.greenVector
                    #else
                scale.y = world.node.scale.y
                    color = NSColor.greenColor()
                    #endif
                break
            case "z":
                    #if !SceneKit
                color = self.blueVector
                        #else
                scale.z = world.node.scale.z
                        color = NSColor.blueColor()
                        #endif
                break
            default:
                fatalError(__FUNCTION__)
            }
            #if SceneKit
                let node:SCNNode = SCNNode()
                node.geometry = RMXArt.CUBE.copy() as? SCNGeometry
                node.geometry!.firstMaterial! = (RMXArt.CUBE.firstMaterial!.copy() as? SCNMaterial)!
                node.geometry!.firstMaterial!.diffuse.contents = color
                node.geometry!.firstMaterial!.specular.contents = color
                node.physicsBody = SCNPhysicsBody.staticBody()
                node.scale = scale
                world.node.addChildNode(node)
                println("axis: \(axis), scale: \(scale.print)")
                #else
                for (var i: RMFloatB = 0; i < shapesPerAxis; ++i){
                    let position = RMXVector3Make(axis == "x" ? point : 0, axis == "y" ? point : shapeRadius, axis == "z" ? point : 0)
                    point += step
                    let object:RMXSprite = RMXSprite().initWithParent(world).setAsShape(type: .CUBE)
                    object.hasGravity = false
                    object.body!.setRadius(shapeRadius)
                    object.setColor(color)
                    
                    object.isAnimated = false
                    object.initPosition(startingPoint: position)
                    object.startingPoint = position
                    world.insertChildNode(object)
                }
            #endif
            
            
        }
        
        #if !ScneneKit
        let shapeRadius: RMFloatB = 5
        let axisLength = world.radius * 2
        let shapesPerAxis: RMFloatB = 1//axisLenght / (shapeRadius * 3)
        let step: RMFloatB = axisLength / shapesPerAxis
        #endif
        
        drawAxis("x")
        drawAxis("y")
        drawAxis("z")
    }
    
    class func randomObjects(world: RMSWorld, noOfShapes: RMFloatB = 100, radius r: RMFloatB? = nil)    {
    //int max =100, min = -100;
    //BOOL gravity = true;
        let radius = r ?? world.radius
        for(var i: RMFloatB = -noOfShapes / 2; i < noOfShapes / 2; ++i) {
            var randPos: [RMFloatB]
            var X: RMFloatB = 0; var Y: RMFloatB = 0; var Z: RMFloatB = 0
            func thisRandom(inout x: RMFloatB, inout y: RMFloatB, inout z: RMFloatB) -> [RMFloatB] {
                do {
                    let points = RMX.doASum(radius, count: i, noOfShapes: noOfShapes )
                    x = points.x
                    y = points.y
                    z = points.z
                } while RMXVector3Distance(RMXVector3Make(x,y,z), RMXVector3Zero) > radius && y > 0
                return [ x, y, z ]
            }
            randPos = thisRandom(&X,&Y,&Z)
            let chance = 1//(rand() % 6 + 1);
        randPos[1] = randPos[1] + 50
        
        //gravity = !gravity;
            let object: RMXSprite = RMXSprite.new(parent: world)
//            if(false){//(rand() % 10000) == 1) {
//                object.shape.makeAsSun(rDist: 0, isRotating:false)
//            }
        
        if(random() % 50 == 1) {
            object.setShape(type: .SPHERE)
        } else if(random() % 5 == 1){
            object.setShape(type: .CYLINDER)
        } else {
            object.setShape(type: .CUBE)
        }
        
        object.hasGravity = false //(rand()% 100) == 1
        object.setRadius(RMFloatB(random() % 9 + 2))
        object.initPosition(startingPoint:RMXVector3Make(randPos[0], randPos[1], randPos[2]))
        object.node.physicsBody!.mass = RMFloat(random()%15+1)/10;
//        object.body!.dragC = RMFloatB(random() % 99+1)/100;
        object.setColor(RMXRandomColor())
        
        }
    }
    
    
    class func randomColor() -> RMXVector4 {
    //float rCol[4];
        var rCol = RMXVector4Make(
            RMFloatB(random() % 800)/500,
            RMFloatB(random() % 800)/500,
            RMFloatB(random() % 800)/500,
        1)

    return rCol
    }
   
}
func RMXVector3Random(max: Int = 100, div: Int = 1, min: Int = 0) -> RMXVector3 {
    return RMXVector3Make(
        RMFloatB((random() % max + min)/div),
        RMFloatB((random() % max + min)/div),
        RMFloatB((random() % max + min)/div)
    )

}

func RMXRandomColor() -> RMXVector4 {
    //float rCol[4];
    return RMXVector4Make(
        RMFloatB(random() % 800)/500,
        RMFloatB(random() % 800)/500,
        RMFloatB(random() % 800)/500,
        1.0)
}
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
    
    class func initializeTestingEnvironment(world: RMSWorld, withAxis drawAxis: Bool = true, withCubes noOfShapes: RMFloatB = 1000) -> RMSWorld {
        RMXArt.drawSun(world)
        
        RMXArt.drawPlane(world)
        if drawAxis {
            RMXArt.drawAxis(world)
        }
        if noOfShapes > 0 {
            RMXArt.randomObjects(world, noOfShapes: noOfShapes)
        }
        return world
    }
    
    class func drawSun(world: RMSWorld) {
        world.sun.isRotating = true
        world.sun.body!.setRadius(100)
    }
    
    class func drawPlane(world: RMSWorld) {
        let ZX = RMXNode().initWithParent(world).setAsShape(type: .PLANE)
        ZX.body!.setRadius(world.body!.radius)
//        ZX.body!.addTheta(leftRightRadians: 90 * RMFloatB(PI_OVER_180))
//        ZX.body!.setPhi(upDownRadians: 180 * PI_OVER_180)
        ZX.transform = RMXMatrix4Rotate(ZX.transform,90 * PI_OVER_180,1,0,0)
        #if SceneKit
        ZX.geometry!.firstMaterial!.doubleSided = true
//        ZX.body!.addTheta(leftRightRadians: 90 * RMFloatB(PI_OVER_180))
            #endif
        ZX.setColor(color: NSColor.greenColor())
//        ZX.geometry?.firstMaterial!.doubleSided = true
        ZX.isAnimated = false
        ZX.startingPoint = ZX.position
//        ZX.position = RMXVector3Make(ZX.position.x, -ZX.radius, ZX.position.z)
        world.insertChildNode(ZX)
    }
    class func drawAxis(world: RMSWorld) {//xCol y:(float*)yCol z:(float*)zCol{
        let shapeRadius: RMFloatB = 5
        let axisLenght = world.radius * 2
        let shapesPerAxis: RMFloatB = axisLenght / (shapeRadius * 3)
        let step: RMFloatB = axisLenght / shapesPerAxis
        
        func drawAxis(axis: String) {
            var point =  -world.radius
            var color: NSColor
            switch axis {
            case "x":
                color = NSColor.redColor()
                break
            case "y":
                color = NSColor.greenColor()
                break
            case "z":
                color = NSColor.blueColor()
                break
            default:
                fatalError(__FUNCTION__)
            }
            for (var i: RMFloatB = 0; i < shapesPerAxis; ++i){
                let position = RMXVector3Make(axis == "x" ? point : 0, axis == "y" ? point : shapeRadius, axis == "z" ? point : 0)
                point += step
                let object:RMXNode = RMXNode().initWithParent(world).setAsShape(type: .CUBE)
                object.hasGravity = false
                object.body!.setRadius(shapeRadius)
                object.setColor(color: color)
                
                object.isAnimated = false
                object.transform = RMXMatrix4Translate(object.transform, position)
                object.startingPoint = position
                world.insertChildNode(object)
            }
            
            
        }
        drawAxis("x")
        drawAxis("y")
        drawAxis("z")
    }
    
    class func randomObjects(world: RMSWorld, noOfShapes: RMFloatB = 100 )    {
    //int max =100, min = -100;
    //BOOL gravity = true;
        
        for(var i: RMFloatB = -noOfShapes / 2; i < noOfShapes / 2; ++i) {
            var randPos: [RMFloatB]
            var X: RMFloatB = 0; var Y: RMFloatB = 0; var Z: RMFloatB = 0
            func thisRandom(inout x: RMFloatB, inout y: RMFloatB, inout z: RMFloatB) -> [RMFloatB] {
                do {
                    let points = RMX.doASum(world.radius, count: i, noOfShapes: noOfShapes )
                    x = points.x
                    y = points.y
                    z = points.z
                } while RMXVector3Distance(RMXVector3Make(x,y,z), RMXVector3Zero) > world.radius && y > 0
                return [ x, y, z ]
            }
            randPos = thisRandom(&X,&Y,&Z)
            let chance = 1//(rand() % 6 + 1);
        randPos[1] = randPos[1] + 50
        
        //gravity = !gravity;
            let object: RMXNode = RMXNode().initWithParent(world)
//            if(false){//(rand() % 10000) == 1) {
//                object.shape.makeAsSun(rDist: 0, isRotating:false)
//            }
        
        if(random() % 50 == 1) {
            object.setAsShape(type: .SPHERE)
        } else if(random() % 5 == 1){
            object.setAsShape(type: .CYLINDER)
        } else {
            object.setAsShape(type: .CUBE)
        }
        
        object.hasGravity = false //(rand()% 100) == 1
        object.body!.setRadius(RMFloatB(random() % 9 + 2))
        object.transform = RMXMatrix4Translate(object.transform, RMXVector3Make(randPos[0], randPos[1], randPos[2]))
        object.startingPoint = object.position
        object.body!.mass = RMFloat(random()%15+1)/10;
        object.body!.dragC = RMFloatB(random() % 99+1)/100;
        object.setColor(RMXRandomColor())
        world.insertChildNode(object)
        
        
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
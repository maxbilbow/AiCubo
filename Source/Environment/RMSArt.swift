//
//  RMSArt.swift
//  RattleGL
//
//  Created by Max Bilbow on 11/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import GLKit

class RMXArt {
    static let colorBronzeDiff: [Float]  = [ 0.8, 0.6, 0.0, 1.0 ]
    static let colorBronzeSpec: [Float]  = [ 1.0, 1.0, 0.4, 1.0 ]
    static let colorBlue: [Float]        = [ 0.0, 0.0, 0.1, 1.0 ]
    static let colorNone: [Float]        = [ 0.0, 0.0, 0.0, 0.0 ]
    static let colorRed: [Float]         = [ 0.1, 0.0, 0.0, 1.0 ]
    static let colorGreen: [Float]       = [ 0.0, 0.1, 0.0, 1.0 ]
    static let colorYellow: [Float]      = [ 1.0, 0.0, 0.0, 1.0 ]
    static let nillVector: [Float]       = [ 0  ,   0,  0,  0   ]
    
    
    class func initializeTestingEnvironment(world: RMSWorld, withAxis drawAxis: Bool = true, withCubes noOfShapes: RMFloat = 1000) -> RMSWorld {
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
        world.sun.body!.radius = 100
    }
    
    class func drawPlane(world: RMSWorld) {
        let ZX = RMXNode(parent: world)
        ZX.body!.radius = world.body!.radius
        ZX.shape.type = .CUBE
        ZX.body!.addTheta(leftRightRadians: 90 * RMFloat(PI_OVER_180))
        //        ZX.body.addPhi(upDownRadians: GLKMathDegreesToRadians(90))
        ZX.body!.addTheta(leftRightRadians: 90 * RMFloat(PI_OVER_180))
        ZX.body!.addPhi(upDownRadians: 270 * RMFloat(PI_OVER_180))
        ZX.shape.color = GLKVector4Make(1.0,1.0,1.0,1.0)
        ZX.isAnimated = false
        //#if OPENGL_ES
            ZX.position = RMXVector3Make(ZX.position.x, -ZX.radius, ZX.position.z)
        //#endif
        world.insertChildNode(ZX)
    }
    class func drawAxis(world: RMSWorld) {//xCol y:(float*)yCol z:(float*)zCol{
        let shapeRadius: RMFloat = 5
        let axisLenght = world.radius * 2
        let shapesPerAxis: RMFloat = axisLenght / (shapeRadius * 3)
        let step: RMFloat = axisLenght / shapesPerAxis
        
        func drawAxis(axis: String) {
            var point =  -world.radius
            var color: [Float]
            switch axis {
            case "x":
                color = self.colorRed
                break
            case "y":
                color = self.colorGreen
                break
            case "z":
                color = self.colorBlue
                break
            default:
                fatalError(__FUNCTION__)
            }
            for (var i: RMFloat = 0; i < shapesPerAxis; ++i){
                let position = RMXVector3Make(axis == "x" ? point : 0, axis == "y" ? point : shapeRadius, axis == "z" ? point : 0)
                point += step
                let object:RMXNode = RMXNode(parent: world)
                object.addInitCall( {
                    object.hasGravity = false
                    object.body!.radius = shapeRadius
                    object.position = position
                    object.shape.isVisible = true
                    object.shape.type = .CUBE
            
                    object.shape.color = GLKVector4Make(color[0], color[1], color[2], color[3])
                    object.isAnimated = false
                })
                world.insertChildNode(object)
            }
            
            
        }
        drawAxis("x")
        drawAxis("y")
        drawAxis("z")
    }
    
    class func randomObjects(world: RMSWorld, noOfShapes: RMFloat = 100 )    {
    //int max =100, min = -100;
    //BOOL gravity = true;
        
        for(var i: RMFloat = -noOfShapes / 2; i < noOfShapes / 2; ++i) {
            var randPos: [RMFloat]
            var X: RMFloat = 0; var Y: RMFloat = 0; var Z: RMFloat = 0
            func thisRandom(inout x: RMFloat, inout y: RMFloat, inout z: RMFloat) -> [RMFloat] {
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
            let object: RMXNode = RMXNode(parent: world)
//            if(false){//(rand() % 10000) == 1) {
//                object.shape.makeAsSun(rDist: 0, isRotating:false)
//            }
        
        if(random() % 50 == 1) {
            object.shape.type = .SPHERE
        } else {
            object.shape.type = .CUBE
        }
        
        object.hasGravity = false //(rand()% 100) == 1
        object.body!.radius = RMFloat(random() % 9 + 2)
        object.position = RMXVector3Make(randPos[0], randPos[1], randPos[2])
        object.body!.mass = RMFloat(random()%15+1)/10;
        object.body!.dragC = RMFloat(random() % 99+1)/100;
        object.shape.color = RMXRandomColor()
        world.insertChildNode(object)
        
        
        }
    }
    
    
    class func randomColor() -> RMXVector4 {
    //float rCol[4];
        var rCol = RMXVector4Make(
            RMFloat(random() % 800)/500,
            RMFloat(random() % 800)/500,
            RMFloat(random() % 800)/500,
        1)

    return rCol
    }

}
func RMXVector3Random(max: Int = 100, div: Int = 1, min: Int = 0) -> RMXVector3 {
    return RMXVector3Make(
        RMFloat((random() % max + min)/div),
        RMFloat((random() % max + min)/div),
        RMFloat((random() % max + min)/div)
    )

}

func RMXRandomColor() -> GLKVector4 {
    //float rCol[4];
    return GLKVector4Make(
        Float(random() % 800)/500,
        Float(random() % 800)/500,
        Float(random() % 800)/500,
        1.0)
}
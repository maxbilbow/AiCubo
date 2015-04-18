//
//  RMSArt.swift
//  RattleGL
//
//  Created by Max Bilbow on 11/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import GLKit

    import SceneKit

class RMXArt {
    static let colorBronzeDiff: [Float]  = [ 0.8, 0.6, 0.0, 1.0 ]
    static let colorBronzeSpec: [Float]  = [ 1.0, 1.0, 0.4, 1.0 ]
    static let colorBlue: [RMFloatB]        = [ 0.0, 0.0, 0.1, 1.0 ]
    static let colorNone: [Float]        = [ 0.0, 0.0, 0.0, 0.0 ]
    static let colorRed: [RMFloatB]         = [ 0.1, 0.0, 0.0, 1.0 ]
    static let colorGreen: [RMFloatB]       = [ 0.0, 0.1, 0.0, 1.0 ]
    static let colorYellow: [Float]      = [ 1.0, 0.0, 0.0, 1.0 ]
    static let nillVector: [Float]       = [ 0  ,   0,  0,  0   ]
    
    static let greenVector: GLKVector4 = GLKVector4Make(0.0, 0.1, 0.0, 1.0)
    static let yellowVector: GLKVector4 = GLKVector4Make(1.0, 1.0, 0.0, 1.0)
    static let blueVector: GLKVector4 = GLKVector4Make(0.0, 0.0, 1.0, 1.0)
    static let redVector: GLKVector4 = GLKVector4Make(1.0, 0.0, 0.0, 1.0)
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
        
        //RMXArt.drawPlane(world)
        if drawAxis {
            RMXArt.drawAxis(world,radius: radius)
        }
        if noOfShapes > 0 {
            RMXArt.randomObjects(world, noOfShapes: noOfShapes, radius: radius)
        }
        return world
    }
    
    
    class func drawPlane(world: RMSWorld) {
        #if SceneKit

            let plane = SCNNode(geometry: SCNPlane(
                width: RMFloat(world.radius),
                height:RMFloat(world.radius)
                )
)
//        plane.geometry = RMXArt.PLANE
//        plane.scale = world.node.scale
       plane.eulerAngles.x = 90 * PI_OVER_180
        plane.geometry!.firstMaterial!.doubleSided = true
        plane.geometry!.firstMaterial!.diffuse.contents =  NSColor.yellowColor()
            plane.physicsBody = SCNPhysicsBody.staticBody()
            plane.physicsBody!.mass = 0
            plane.physicsBody!.restitution = 0.0
        world.scene.rootNode.addChildNode(plane)
            
        #else
        
        let ZX = RMXSprite.new(parent: world).asShape(radius: world.radius, shape: .CUBE)
        
            ZX.setColor(self.yellowVector)
        ZX.isAnimated = false
        ZX.initPosition(startingPoint: RMXVector3Make(ZX.position.x, -ZX.radius, ZX.position.z))
        
        world.insertChild(ZX)
        #endif
    }
    
    class func drawAxis(world: RMSWorld, radius: RMFloatB?) {//xCol y:(float*)yCol z:(float*)zCol{
        
        
        func drawAxis(axis: String) {
            var point =  -world.radius
            #if !SceneKit
            var color: GLKVector4
                #else
                var color: NSColor
                #endif
            var scale: RMXVector3 = RMXVector3Make(10,10,10)
            switch axis {
            case "x":
                #if !SceneKit
                color = self.redVector
                    #else
                scale.x = radius ?? world.radius
                    color = NSColor.redColor()
                    #endif
                break
            case "y":
                #if !SceneKit
                color = self.greenVector
                    #else
                scale.y = radius ?? world.radius
                    color = NSColor.greenColor()
                    #endif
                break
            case "z":
                    #if !SceneKit
                color = self.blueVector
                        #else
                scale.z = radius ?? world.radius
                        color = NSColor.blueColor()
                        #endif
                break
            default:
                fatalError(__FUNCTION__)
            }
         #if SceneKit
                let node:SCNNode = SCNNode( geometry: (RMXArt.CUBE.copy() as? SCNGeometry)!)
                node.geometry!.firstMaterial! = (RMXArt.CUBE.firstMaterial!.copy() as? SCNMaterial)!
                node.geometry!.firstMaterial!.diffuse.contents = color
                node.geometry!.firstMaterial!.specular.contents = color
//                node.physicsBody = SCNPhysicsBody.staticBody()
                node.scale = scale
           
                world.scene.rootNode.addChildNode(node)
                println("axis: \(axis), scale: \(scale.print)")
            #else
            let sprite = RMXSprite(node: RMXModels.getNode(shapeType: ShapeType.CUBE.rawValue, scale: scale))
            sprite.shapeType = .CUBE
            world.insertChild(sprite)
            #endif
            
        }
        
        
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
                func drawCondition(x:RMFloatB, y:RMFloatB, z:RMFloatB) -> Bool{
                    let position = RMXVector3Make(x,y,z)
                    let distance = RMXVector3Distance(position, RMXVector3Zero)
                    var test: Bool
                    test = fabs(Float(y)) > Float(world.radius)
                    
                    return distance > radius && test
                }
                do {
                    let points = RMX.doASum(radius, count: i, noOfShapes: noOfShapes )
                    x = points.x
                    y = points.y
                    z = points.z
                } while drawCondition(x,y,z)
                return [ x, y, z ]
            }
            randPos = thisRandom(&X,&Y,&Z)
            let chance = 1//(rand() % 6 + 1);
            let size = RMFloatB(random() % 5 + 2)
            var scale = RMXVector3Make(size,size,size)
            var shape: ShapeType
            var geo: SCNGeometry
            var type: RMXSpriteType

            let switcher = random() % ShapeType.LAST.rawValue
            let colorVector = RMXRandomColor()
            #if OSX
                let color = NSColor(calibratedRed: colorVector.x, green: colorVector.y, blue: colorVector.z, alpha: colorVector.w)
                #elseif iOS
                let color = UIColor(red: RMFloat(colorVector.x), green: RMFloat(colorVector.y), blue: RMFloat(colorVector.z), alpha: RMFloat(colorVector.w))
            #endif
        
            let node = RMXModels.getNode(shapeType: switcher, scale: scale, color: color)

                
                node.position = RMXVector3Make(randPos[0], randPos[1], randPos[2])
            
                    
             
            #if SceneKit
                world.scene.rootNode.addChildNode(node)
            #else
                let sprite = RMXSprite(node: node)
                sprite.setColor(RMXArt.randomColor())
                world.insertChild(sprite)
            #endif
//            let object: RMXSprite = RMXSprite.new(parent: world, nodeOnly: true)
//            object.hasGravity = false
//            object.setRadius(RMFloatB(random() % 9 + 2))
//            object.initPosition(startingPoint:RMXVector3Make(randPos[0], randPos[1], randPos[2]))
//            object.node.physicsBody!.mass = RMFloat(random()%15+1)/10
//            object.setColor(color)
//            #endif
        
        }
    }
    
    
    class func randomColor() -> GLKVector4 {
    //float rCol[4];
        var rCol = GLKVector4Make(
            Float(random() % 800)/500,
            Float(random() % 800)/500,
            Float(random() % 800)/500,
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



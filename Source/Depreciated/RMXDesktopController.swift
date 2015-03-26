//
//  RMXGyro.swift
//  OC to Swift oGL
//
//  Created by Max Bilbow on 17/02/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation
//import CoreMotion
//import UIKit



class RMXDesktopController : RMXController {
    var hRotation:Float = 0.0   //Horizontal angle
    var vRotation:Float = 0.0   //Vertical rotation angle of the camera
    var cameraMovementSpeed:Float = 0.02
    var dataIn: String = "No Data"
    var gameView: RMXViewController
    var scene: RMXWorld? {
        return gameView.world
    }

    init(gameView: GameViewController){
        self.gameView = gameView
        self.viewDidLoad()
    }

    
    func log(message: String,sender: String = __FUNCTION__) {
        self.dataIn += "  \(sender): \(message)"
    }
    
    func viewDidLoad(){
        let w = gameView.view.bounds.size.width
        let h = gameView.view.bounds.size.height
    
        
    }
    
    var i: Int = 0
    func update() {
        gameView.
        if dataIn != ""{
            println("\(dataIn)")
            self.log("\n x\(leftPanData.x.toData()), y\(leftPanData.y)",sender: "LEFT")
            self.log("x\(rightPanData.x.toData()), y\(rightPanData.y.toData())",sender: "RIGHT")
        }
        dataIn = ""
    }
    
    func handleDoubleTap(recognizer: UITapGestureRecognizer) {
        //self.world!.reInit();
        println("Double Tap")
        gameView.world.modelMatrix = Matrix4()
        gameView.world.modelMatrix.translate(0.0, y: 0.0, z: -7.0)
        gameView.world.modelMatrix.rotateAroundX(Matrix4.degreesToRad(25), y: 0.0, z: 0.0)
    }
   
    
    
    //The event Le method
    func handlePanLeftSide(recognizer: UIPanGestureRecognizer) {
        let point = recognizer.velocityInView(gameView.view);
        let speed:Float = -0.001
        gameView.world.modelMatrix.translate(Float(point.x)*speed, y: 0, z: Float(point.y)*speed)
    }
    
    
    //The event handling method
    func handlePanRightSide(recognizer: UIPanGestureRecognizer) {
        let point = recognizer.velocityInView(gameView.view);
        let speed:Float = 0.0001
        
        gameView.world.modelMatrix.rotateAroundX(Float(point.y)*speed, y: Float(point.x)*speed, z: 0)
    }
    
    

}







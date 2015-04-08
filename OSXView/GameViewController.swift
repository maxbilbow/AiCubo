//
//  GameViewController.swift
//  AiCubo
//
//  Created by Max Bilbow on 03/04/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation


class GameViewController : NSViewController, RMXViewController {
    var timer: NSTimer?
    @IBOutlet weak var gameView: GameView? = nil
    lazy var interface: RMXInterface? = RMX.Controller(self)
    
    var world: RMSWorld? {
        return self.interface?.world
    }
    func resetGame() {//type: RMXWorldType = GameViewController.worldType) -> UIView {
        if self.gameView == nil || self.gameView !== self.view {
            self.gameView = GameView(frame: self.view.bounds)

            self.view = self.gameView!
        }
        
        
        self.gameView!.setWorld(RMSWorld.TYPE)
       
        //        GameView.worldType = .TESTING_ENVIRONMENT
        //        return self.view
    }
    /*
    required init(coder aDecoder: NSCoder) {
    let value = aDecoder.valueForKeyPath("test")
    print(value)
    super.init(coder: aDecoder)
    }
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = GameView(frame: self.view.bounds)
        self.gameView = self.view as? GameView
        self.resetGame()
        
        //self.preferredFramesPerSecond = 30
        
        self.setUpTimers()
    }
    
    func setUpTimers(){
//        timer = CADisplayLink(target: self.interface, selector: Selector("update"))
//        timer!.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
//        //        timer!.frameInterval =
//        let stateTimer = CADisplayLink(target: self, selector: Selector("resetGame"))
//        //        stateTimer.frameInterval = 100
//        stateTimer.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    
    
}
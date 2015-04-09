//
//  GameViewController.swift
//  RattleGLES
//
//  Created by Max Bilbow on 23/03/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//
import Foundation
import GLKit
#if OPENGL_ES
    import UIKit
    #elseif OPENGL_OSX
    import OpenGL
    import GLUT
#endif

class ViewController : UIViewController {
    
//    @IBOutlet weak var gvc: GameViewController! = GameViewController()
    
    @IBAction func playFetch(sender: AnyObject) {
//        RMSWorld.TYPE = .FETCH

    }
    
    @IBAction func testingEnvironment(sender: AnyObject) {
        
//        RMSWorld.TYPE = .TESTING_ENVIRONMENT
    }

}
class GameViewController : GLKViewController, RMXViewController {
   
    
    lazy var interface: RMXInterface? = RMX.Controller(self)
    var timer: CADisplayLink?
    var world: RMSWorld? {
        return self.interface?.world
    }
    
    @IBOutlet var gameView: GameView?
    
    
    @IBAction func setWorld(button: UIButton){
        println(__FUNCTION__)
    }

    
    func resetGame() {
        if self.gameView == nil {
            self.gameView = GameView(frame: self.view.bounds)
        }
        self.view = self.gameView
    }

    
    override func viewDidLoad() {
        self.view = self.gameView
        self.gameView!.initialize(self, interface: self.interface!)
        super.viewDidLoad()
//        self.preferredFramesPerSecond = 30
        self.resetGame()

        
        
    }
    func setUpTimers(){
//        timer = CADisplayLink(target: self.interface, selector: Selector("update"))
//        timer!.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)

        
    }
    
    override func glkView(view: GLKView!, drawInRect rect: CGRect) {
        super.glkView(view, drawInRect: rect)
        self.interface?.update()
        self.gameView!.update()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    
    
    #if OPENGL_ES
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    #endif

}
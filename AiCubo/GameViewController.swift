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
        RMSWorld.TYPE = .FETCH
    }
    
    @IBAction func testingEnvironment(sender: AnyObject) {
        
        RMSWorld.TYPE = .TESTING_ENVIRONMENT
    }

}
class GameViewController : GLKViewController, RMXViewController {
   
    
    lazy var interface: RMXInterface = RMX.Controller(self)
    var timer: CADisplayLink?
    
    
    @IBOutlet var gameView: GameView! //= GameView(frame: self.view.bounds)
    
    
    @IBAction func setWorld(button: UIButton){
        println(__FUNCTION__)
    }
//    required init(coder aDecoder: NSCoder) {
//        self.gameView = GameView(coder: aDecoder)
//        super.init(coder: aDecoder)
//        self.viewDidLoad()
//    }
    
    func resetGame() {//type: RMXWorldType = GameViewController.worldType) -> UIView {
        if self.gameView == nil {
            self.gameView = GameView(frame: self.view.bounds)
        }

        self.gameView.setWorld(RMSWorld.TYPE)
        self.view = self.gameView
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
        self.preferredFramesPerSecond = 30
//        self.view = self.menuView
        self.resetGame()
        self.setUpTimers()
//        self.view.hidden = true
        
        
    }
    func setUpTimers(){
        timer = CADisplayLink(target: self.interface, selector: Selector("update"))
        timer!.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
//        timer!.frameInterval = 
        let stateTimer = CADisplayLink(target: self, selector: Selector("resetGame"))
//        stateTimer.frameInterval = 100
        stateTimer.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    override func glkView(view: GLKView!, drawInRect rect: CGRect) {
        super.glkView(view, drawInRect: rect)
        self.gameView.update()
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
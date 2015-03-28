//
//  ViewController.swift
//  Rattle Physics Beta
//
//  Created by Max Bilbow on 18/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Cocoa
import SceneKit

public class GameViewController: NSViewController {
    
//    @IBOutlet weak var glView: RMSView! = RMSView()

    
    override public func viewDidLoad() {
        
        super.viewDidLoad()
    

    }
    
    public override func loadView() {
        println(__FUNCTION__)
        super.loadView()
//        RMX.SetUpGLProxy()
    }
    public override func awakeFromNib() {
        println("Awake")
        super.awakeFromNib()
    }

    override public var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
    @IBAction func launchGame(sender: AnyObject?) {
        
            RMX.SetUpGLProxy()
    }
    
}


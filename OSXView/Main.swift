//
//  AppDelegate.swift
//  OSXView
//
//  Created by Max Bilbow on 27/03/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//


//@NSApplicationMain
class Main: NSObject, NSApplicationDelegate {
    
    
    func start(){
        RMSWorld.TYPE = .TESTING_ENVIRONMENT
        RMXGLProxy.run(RMSWorld.TYPE)
        
    }
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        
        
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    
    
}


Main().start()
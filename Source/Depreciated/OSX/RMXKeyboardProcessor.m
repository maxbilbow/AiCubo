//
//  Interface.h
//  OpenGL 2.0
//
//  Created by Max Bilbow on 23/01/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//


@import GLUT;
#import "RMOpenGL.h"
#import <OSXView-Swift.h>
@class RMX, RMXGLProxy;

struct KeyProcessor {
    char forward, back, left, right, up, down, stop, jump;
    bool update;
    bool keyStates[256], keySpecialStates[246];// = new bool[246];

};


struct KeyProcessor keys;// = KeyProcessor();

void initKeys(){
    keys.forward = 'w';
    keys.back = 's',
    keys.left = 'a',
    keys.right = 'd',
    keys.up = 'e',
    keys.down = 'q',
    keys.stop = 'f',
    keys.jump = 32;
    //bool * keyStates[256], * keySpecialStates[246]
}


void RepeatedKeys(){
    if (keys.keyStates['+']) {
        [RMXGLProxy performActionWithSpeed:1.1 action:@"enlargeItem"];
    }
    if (keys.keyStates['_']) {
        [RMXGLProxy performActionWithSpeed:-0.9 action:@"enlargeItem"];
    }
    if (keys.keySpecialStates[GLUT_KEY_UP]) {
        if (keys.keyStates[9])
            return;//[sun lightUp:1];
        

    } else if(keys.keySpecialStates[GLUT_KEY_DOWN]) {
        if (keys.keyStates[9]) {
            return;//[sun lightUp:-1];
        }
    }
}

void movement(float speed, char key){
    //if (keys.keyStates[keys.forward])  [observer accelerateForward:speed];
    if (key == keys.forward) {
            [RMXGLProxy performActionWithSpeed:speed action:@"forward"];
    }
    
    if (key == keys.back) {
            [RMXGLProxy performActionWithSpeed:-speed action:@"forward"];
        //TODO
    }
    
    if (key == keys.left) {
        [RMXGLProxy performActionWithSpeed:speed action:@"left"];
    }
    
    if (key == keys.right) {
        [RMXGLProxy performActionWithSpeed:-speed action:@"left"];
    }
    
    if (key == keys.up) {
        [RMXGLProxy performActionWithSpeed:-speed action:@"up"];
    }
    
    if (key == keys.down) {
        [RMXGLProxy performActionWithSpeed:speed action:@"up"];
    }
    
    if (key == 32) {
        [RMXGLProxy performActionWithSpeed:speed action:@"jump"];
    //TODO
    }

}

void keyDownOperations (int key) {
    keys.keyStates[key] = true;
    movement((float)1.0, key);
}

//template <typename Particle>
void keyUpOperations(int key){

    movement((bool)false, key); //Change to Zero if maintaining velocity
    
    
    switch (key)
    {
        default:

            break;
        case 27:             // ESCAPE key
            //glutSetKeyRepeat(true);
            exit (0);
            break;
        /*case 'l':
            SelectFromMenu(MENU_LIGHTING);
            break;
        case 'p':
            SelectFromMenu(MENU_POLYMODE);
            break;
        case 't':
            SelectFromMenu(MENU_TEXTURING);
            break;*/
        case 'G':
            [RMXGLProxy performActionWithSpeed:1 action:@"toggleAllGravity"];
            break;
        case 'm':
            [RMXGLProxy performActionWithSpeed:1 action:@"toggleMouseLock"];
            break;
        case 'f':
            [RMXGLProxy performActionWithSpeed:1 action:@"toggleFog"];
            break;
        case 32:
    // [observer stop();
//            if (DEBUG) NSLog(@"%i: Space Bar",key);
            break;
        case 9:
            // [observer stop();
//            if (DEBUG) NSLog(@"%i: TAB",key);
            break;
        case 'g':
            [RMXGLProxy performActionWithSpeed:1 action:@"toggleGravity"];
            break;
        case '0':
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
        case '8':
        case '9':
            exit(0);//[sun lightSwitch:key];
            break;
        case 't':
            [RMXGLProxy performActionWithSpeed:1 action:@"switchEnvitonment"];
            break;
        case 'R':
            [RMXGLProxy performActionWithSpeed:1 action:@"reset"];
            break;
        case 6: //cntrl f
            NSLog(@"ERROR: Toggle Full Screen not working");//[window toggleFullScreen];
            break;
    }
    keys.keyStates[key] = false;
    
}
void keySpecialDownOperations(int key) {
    if (key == GLUT_KEY_UP) { // If the left arrow key has been pressed
        [RMXGLProxy performActionWithSpeed:1 action:@"extendArm"];
    }
    
    if (key == GLUT_KEY_DOWN) {
        [RMXGLProxy performActionWithSpeed:-1 action:@"extendArm"];
    }
    
    if (key == GLUT_KEY_LEFT) {
//        if (DEBUG) NSLog(@"%i:LEFT Pressed",key);
    }
    
    if (key == GLUT_KEY_RIGHT) {
//        if (DEBUG) NSLog(@"%i:RIGHT Pressed",key);
        //TODO
    }
    
    
    // Perform 'a' key operations
    
}


void keySpecialUpOperations(char key) {
    switch (key){
        case GLUT_KEY_LEFT:
           // [rmxDebugger cycle:-1];
            break;
        case GLUT_KEY_RIGHT:
            
            break;
        case GLUT_KEY_UP:
            [RMXGLProxy performActionWithSpeed:0 action:@"extendArm"];
            break;
        case GLUT_KEY_DOWN:
            [RMXGLProxy performActionWithSpeed:0 action:@"extendArm"];
            break;
        case 32:
            // [observer stop();
            //[rmxDebugger add:RMX_KEY_PROCESSOR n:@"KeyProcessor" t:[NSString stringWithFormat:@"%i: SPACE BAR Released",key]];
            break;

    }
}




void keySpecialOperations(void) {
    keys.update=true;
    //keySpecialDownOperations();
}

void RMXkeyPressed (unsigned char key, int x, int y) {
    //char kTemp = key;
    //NSString * tmp = [NSString stringWithFormat:@"%c",key];//&kTemp;
    //[rmxDebugger add:RMX_KEY_PROCESSOR n:@"KeyProcessor" t:[NSString stringWithFormat:@"%c: pressed",key]];
    keys.keyStates[key] = true; // Set the state of the current key to pressed
    keyDownOperations(key);
}

void RMXkeyUp (unsigned char key, int x, int y) {
    //string tmp = to_string(key);
   // [rmxDebugger add:RMX_KEY_PROCESSOR n:@"KeyProcessor" t:[NSString stringWithFormat:@"%c: released",key]];
    keyUpOperations(key);
    keys.keyStates[key] = false; // Set the state of the current key to not pressed
}
void RMXkeySpecial (int key, int x, int y) {
  //  [rmxDebugger add:RMX_KEY_PROCESSOR n:@"KeyProcessor" t:[NSString stringWithFormat:@"%i: pressed (special)",key]];
    keys.keySpecialStates[key] = true; // Set the state of the current key to pressed
    keySpecialDownOperations(key);
}

void RMXkeySpecialUp (int key, int x, int y) {
  //  [rmxDebugger add:RMX_KEY_PROCESSOR n:@"KeyProcessor" t:[NSString stringWithFormat:@"%i: released (special)",key]];
    keySpecialUpOperations(key);
    keys.keySpecialStates[key] = false; // Set the state of the current key to not pressed
    
}

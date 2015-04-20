//
//  MouseProcessor.h
//  OpenGL 2.0
//
//  Created by Max Bilbow on 23/01/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//




@import GLUT;
#import "RMOpenGL.h"
#ifdef OPENGL_OSX
#import <OSXView-Swift.h>
#endif

@class Main, RMX, RMXGLProxy, RMXSpriteActions, RMXParticle;
//static BOOL g_bLightingEnabled = TRUE;
//static BOOL g_bFillPolygons = TRUE;
//static BOOL g_bTexture = FALSE;
static BOOL g_bButton1Down = FALSE;
//static GLfloat g_fTeapotAngle = 0.0;

//static GLfloat g_fViewDistance = 3 * VIEWING_DISTANCE_MIN;
//static GLfloat g_nearPlane = 1;
//static GLfloat g_farPlane = 1000;
int g_Width = 600;                          // Initial window width
int g_Height = 600;

static int g_yClick = 0;
void RMGLMouseCenter(){
//
    bool center = true;//observer->hasFocus();
    int x = center ? (glutGet(GLUT_WINDOW_WIDTH) + glutGet(GLUT_WINDOW_X))/2 : RMXGLProxy.mouseX;
    int y = center ? (glutGet(GLUT_WINDOW_HEIGHT) + glutGet(GLUT_WINDOW_Y))/2 :RMXGLProxy.mouseY;

    CGWarpMouseCursorPosition(CGPointMake(x , y ));
  //  pos.x = glutGet(GLUT_WINDOW_X)/2;
  //  pos.y = glutGet(GLUT_WINDOW_Y)/2;
    
}


void MouseButton(int button, int state, int x, int y)
{
    // Respond to mouse button presses.
    // If button1 pressed, mark this state so we know in motion function.

    if ((button == GLUT_LEFT_BUTTON)&&(state==GLUT_UP))
        [RMXGLProxy performAction:@"grab"];//&art.sh);
    if ((button == GLUT_LEFT_BUTTON)&&(state==GLUT_DOWN))
        [RMXGLProxy calibrateView:x y:y];
    if (button == GLUT_LEFT_BUTTON)
    {

        g_bButton1Down = (state == GLUT_DOWN) ? TRUE : FALSE;
        g_yClick = y - 3 * VIEWING_DISTANCE_MIN;
        //art.sh.setAnchor(&observer);
    }
    if ((button == GLUT_RIGHT_BUTTON)&&(state==GLUT_UP)){
        [RMXGLProxy performActionWithSpeed:10 action:@"throw"];
    }
}




void MouseMotion(int x, int y)
{
    
    [RMXGLProxy mouseMotion:x y:y];    
    
}


void MouseFree(int x, int y){
    [RMXGLProxy mouseMotion:x y:y];
//    
//    if (RMXGLProxy.activeSprite.mouse.hasFocus) {
//        [RMXGLProxy.activeSprite.mouse mouse2view:x y:y];// mouse.setView(world.observer,x,y);
//        //world.observer->center();
//        center();
//
//    }
//    else
//        [RMXGLProxy.activeSprite.mouse setMousePos:x y:y];
    
}

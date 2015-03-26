//
//  MouseProcessor.h
//  OpenGL 2.0
//
//  Created by Max Bilbow on 23/01/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//






#import "RattleGLS-Bridging-Header.h"
#import <RattleGL-Swift.h>

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
void center(){
//
    bool center = false;//observer->hasFocus();
    int x = center ? glutGet(GLUT_WINDOW_X)/2 :RMXGLProxy.activeSprite.mouse.x;
    int y = center ? glutGet(GLUT_WINDOW_Y)/2 :RMXGLProxy.activeSprite.mouse.y;

    CGWarpMouseCursorPosition(CGPointMake(x + glutGet(GLUT_WINDOW_X), y + glutGet(GLUT_WINDOW_Y) ));
  //  pos.x = glutGet(GLUT_WINDOW_X)/2;
  //  pos.y = glutGet(GLUT_WINDOW_Y)/2;
    
}


void MouseButton(int button, int state, int x, int y)
{
    // Respond to mouse button presses.
    // If button1 pressed, mark this state so we know in motion function.

    if ((button == GLUT_LEFT_BUTTON)&&(state==GLUT_UP))
        [RMXGLProxy.activeSprite.actions grabItem];//&art.sh);
    if ((button == GLUT_LEFT_BUTTON)&&(state==GLUT_DOWN))
        [RMXGLProxy.activeSprite.mouse calibrateView:x y:y];
    if (button == GLUT_LEFT_BUTTON)
    {

        g_bButton1Down = (state == GLUT_DOWN) ? TRUE : FALSE;
        g_yClick = y - 3 * VIEWING_DISTANCE_MIN;
        //art.sh.setAnchor(&observer);
    }
    if ((button == GLUT_RIGHT_BUTTON)&&(state==GLUT_UP)){
        [RMXGLProxy.activeSprite.actions throwItem:15];
    }
}




void MouseMotion(int x, int y)
{
    if (!RMXGLProxy.activeSprite.mouse.hasFocus) {
        [RMXGLProxy.activeSprite.mouse mouse2view:x y:y];
    }
    else {
        [RMXGLProxy.activeSprite.mouse setMousePos:x y:y];
        //world.observer->calibrateMouse(x,y);
    }
//    if (g_bButton1Down)
//    {
//        window.fViewDistance = (y - g_yClick) / 3.0 ;
//        if (window.fViewDistance < VIEWING_DISTANCE_MIN)
//            window.fViewDistance = VIEWING_DISTANCE_MIN;
//        glutPostRedisplay();
//    }
    
    
}


void MouseFree(int x, int y){
    if (RMXGLProxy.activeSprite.mouse.hasFocus) {
        [RMXGLProxy.activeSprite.mouse mouse2view:x y:y];// mouse.setView(world.observer,x,y);
        //world.observer->center();
        center();

    }
    else
        [RMXGLProxy.activeSprite.mouse setMousePos:x y:y];
    
    //glutWarpPointer(window.getWidth()/2, window.getHeight()/2);
   
}

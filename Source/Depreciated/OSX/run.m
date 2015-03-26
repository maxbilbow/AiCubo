//
//  main.m
//  OpenGL 2.1 (OC)
//
//  Created by Max Bilbow on 15/02/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

//#import "RattleGLS-Bridging-Header.h"
#import <RattleOSX-Swift.h>
#import "RMXMouseProcessor.h"
#import "RMXKeyboardProcessor.h"
@import GLUT;
#define TEXTURE_ID_CUBE 1
@class RMXGLProxy, RMX;
void InitGraphics(void)
{
//    int width, height;
//    int nComponents;
//    void* pTextureImage;
    
    
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);
    glShadeModel(GL_SMOOTH);
    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);
    //glEnable(GL_LIGHT1);
    // Create texture for cube; load marble texture from file and bind it
    //pTextureImage = read_texture("marble.rgb", &width, &height, &nComponents);
    glBindTexture(GL_TEXTURE_2D, TEXTURE_ID_CUBE);
    
    glGenerateMipmap(GL_MAP1_NORMAL);
//    gluBuild2DMipmaps(GL_TEXTURE_2D,     // texture to specify
//                      GL_RGBA,           // internal texture storage format
//                      width,             // texture width
//                      height,            // texture height
//                      GL_RGBA,           // pixel format
//                      GL_UNSIGNED_BYTE,	// color component format
//                      pTextureImage);    // pointer to texture image
    glTexParameterf (GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf (GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,
                     GL_LINEAR_MIPMAP_LINEAR);
    glTexEnvf (GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
}


void display(){
    [RMXGLProxy display];
}
void reshape(int w, int h) {
    [RMXGLProxy reshape:w height:h];
}

void keyPressed (unsigned char key, int x, int y){
    RMXkeyPressed(key, x, y);
}
void keyUp (unsigned char key, int x, int y){
    RMXkeyUp(key, x, y);
}
void keySpecial (int key, int x, int y){
    RMXkeySpecial(key, x, y);
}
void keySpecialUp (int key, int x, int y){
    RMXkeySpecialUp(key, x, y);
}

void mouseButton(int button, int state, int x, int y){
    MouseButton(button, state, x, y);
}
void mouseMotion(int x, int y){
    MouseMotion(x, y);
}
void mouseFree(int x, int y){
    MouseFree(x, y);
}

void idle(){
    [RMXGLProxy animateScene];
}


#ifdef RMX_USE_DEPRECIATED

int RMXRun(int argc, char * argv[])
{
    NSLog(@"Hello");
    
    RMXGlutInit(argc,argv);
    initKeys();
    
    
    RMXGlutInitDisplayMode ( GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH );
    
    
    if (RMX.isFullscreen){//&&glutGameModeGet(GLUT_GAME_MODE_POSSIBLE)){
        RMXGlutEnterGameMode();
    }else {
        NSLog(@"Game Mode Not Possibe");
        RMXGlutMakeWindow(100,100,1280,720,"Window");
    }
    //Setup Display:
    glutDisplayFunc(display);
    glutReshapeFunc(reshape);
    
    // Register callbacks:
    glutKeyboardFunc(keyPressed);
    glutKeyboardUpFunc(keyUp);
    glutSpecialFunc(keySpecial);
    glutSpecialUpFunc(keySpecialUp);
 
    glutMouseFunc(mouseButton);
    glutMotionFunc(mouseMotion);
    glutPassiveMotionFunc(mouseFree);
    
    //Animation
    glutIdleFunc(idle);
    
    InitGraphics();
    
    
    if (RMX.isFullscreen) {
        [RMXGLProxy.activeSprite.mouse toggleFocus];
        glutSetCursor(GLUT_CURSOR_NONE);
        [RMXGLProxy.activeSprite.mouse calibrateView:0 y:0];
        [RMXGLProxy.activeSprite.mouse mouse2view:0 y:0];
    }
    glutMainLoop();
    return 0;
}
#else
int RMXRun(int argc, char * argv[]){
    NSLog(@"RUN should not be called, bitches!");
    return 0;
}

#endif
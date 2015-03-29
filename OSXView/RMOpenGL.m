//
//  RMOpenGL.m
//  AiCubo
//
//  Created by Max Bilbow on 27/03/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

@import Foundation;

@import GLKit;
@import GLUT;
#import "RMOpenGL.h"

void RMGlutSetCursor(bool hasFocus) {
    glutSetCursor(hasFocus ? GLUT_CURSOR_NONE : GLUT_CURSOR_INHERIT);
}

void RMXGLMakeLookAt(GLKVector3 eye, GLKVector3 center, GLKVector3 up){
    gluLookAt(eye.x, eye.y, eye.z,
              center.x, center.y, center.z,
              up.x, up.y, up.z );
}
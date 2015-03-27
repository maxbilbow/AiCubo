//
//  RMOpenGL.h
//  AiCubo
//
//  Created by Max Bilbow on 27/03/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

#ifndef AiCubo_RMOpenGL_h
#define AiCubo_RMOpenGL_h


#endif

#import <Foundation/Foundation.h>


@interface RMGLProxy : NSObject
+ (void)SetUpGL;

@end

class RMOpenGL {
    void SetUpGL(void);
};



int RMXGLMakeLookAt(GLKVector3 eye, GLKVector3 center, GLKVector3 up);
void RMXGLPostRedisplay();
void RMXGLMaterialfv(int32_t a,int32_t b, GLKVector4 color);
void RMXGLTranslate(GLKVector3 v);
void RMXGLShine(int a, int b, GLKVector4 color);
void RMXGLRender(void (*render)(float),float size);
void RMXGLCenter(void (*center)(int,int),int x, int y);
void RMXCGGetLastMouseDelta(int * x, int * y);
GLKVector4 RMXRandomColor();
void RMXGLPostRedisplay();
void RMXGLMakePerspective(float angle, float aspect, float near, float far);
void RMXGlutSwapBuffers();
void RMXGlutInit(int argc, char * argv[]);
void RMXGlutInitDisplayMode(unsigned int mode);
void RMXGlutEnterGameMode();
void RMXGlutMakeWindow(int posx,int posy, int w, int h, const char * name);
void RMXGLRegisterCallbacks(void (*display)(void),void (*reshape)(int,int));
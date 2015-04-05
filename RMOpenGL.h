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
#define FULL_SCREEN 0
//#define OPENGL_OSX
//#import <Foundation/Foundation.h>
@import GLKit;

@interface RMGLProxy
+ (void)SetUpGL;

@end

//class RMOpenGL {
//    void SetUpGL(void);
//};


void RMXGLMakeLookAt(GLKVector3 eye, GLKVector3 center, GLKVector3 up);
void RMXGLPostRedisplay();
void RMXGLMaterialfv(int32_t a,int32_t b, GLKVector4 color);
void RMXGLTranslate(GLKVector3 v);
void RMXGLTranslatef(float x,float y, float z);
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
void RMGlutSetCursor(bool hasFocus);
//void RMGLutWarpPointer(int x, int y);

/**

Shapes
*/

#define VIEWING_DISTANCE_MIN  3.0
//#define TEXTURE_ID_CUBE 1


#define TEXTURE_ID_CUBE 1

void DrawCubeFace(float fSize);
void DrawCubeWithTextureCoords (float fSize);
void DrawSpheree(double r, int lats, int longs);
void RMXDrawSphere(float size);//Particle pCube = Particle();
//void RenderObjects(void);
//void DrawTeapot(float f);
void DrawPlane(float x);
void DrawFog(bool draw);

#ifdef OPENGL_OSX
///Keys

void initKeys();

void RepeatedKeys();

//void movement(float speed, int key);

void keyDownOperations (int key);

//template <typename Particle>
void keyUpOperations(int key);
void keySpecialDownOperations(int key);

void keySpecialUpOperations(char key);

void keySpecialOperations(void);
void RMXkeyPressed (unsigned char key, int x, int y);
void RMXkeyUp (unsigned char key, int x, int y);
void RMXkeySpecial (int key, int x, int y);
void RMXkeySpecialUp (int key, int x, int y);


///Mouse
void RMGLMouseCenter();
void MouseButton(int button, int state, int x, int y);
void MouseMotion(int x, int y);
void MouseFree(int x, int y);


int RMXGLRun(int argc, char * argv[]);
#endif
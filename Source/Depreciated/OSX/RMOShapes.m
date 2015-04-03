//
//  shapes.h
//  OpenGL 2.0
//
//  Created by Max Bilbow on 23/01/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//


@import GLKit;
@import GLUT;

#import "RMOpenGL.h"
#ifdef OPENGL_OSX
#import <OSXView-Swift.h>
#endif
static GLfloat g_fTeapotAngle2 = 0.0;
//static GLfloat g_fViewDistance = 3 * VIEWING_DISTANCE_MIN;
//static GLfloat g_nearPlane = 1;
//static GLfloat g_farPlane = 1000;
//    int g_Width = 600;                          // Initial window width
//    int g_Height = 600;                         // Initial window height


//#import "RattleGL3.0-Bridging-Header.h"

void DrawCubeFace(float fSize)
{
    //fSize /= 2.0;

    glBegin(GL_QUADS);
    
    glVertex3f(-fSize, -fSize, fSize);    glTexCoord2f (0, 0);
    glVertex3f(fSize, -fSize, fSize);   glTexCoord2f (1, 0);
    glVertex3f(fSize, fSize, fSize);     glTexCoord2f (1, 1);
    glVertex3f(-fSize, fSize, fSize);     glTexCoord2f (0, 1);
    glEnd();

}


void DrawCubeWithTextureCoords (float fSize)
{

    glPushMatrix();
    DrawCubeFace (fSize);
    glRotatef (90, 1, 0, 0);
    DrawCubeFace (fSize);
    glRotatef (90, 1, 0, 0);
    DrawCubeFace (fSize);
    glRotatef (90, 1, 0, 0);
    DrawCubeFace (fSize);
    glRotatef (90, 0, 1, 0);
    DrawCubeFace (fSize);
    glRotatef (180, 0, 1, 0);
    DrawCubeFace (fSize);
    glPopMatrix();
    
    const GLfloat verts[] = {
        0.0f,   1.0f,   0.0f,
        -1.0f,  -1.0f,  0.0f,
        1.0f,   -1.0f,  0.0f
    };

    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(3, GL_FLOAT, 0, verts);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 3);
    
}


void DrawSpheree(double r, int lats, int longs)
{

          int i, j;
          for(i = 0; i <= lats; i++) {
                  double lat0 = M_PI * (-0.5 + (double) (i - 1) / lats);
                  double z0  = sin(lat0)*r;
                  double zr0 =  cos(lat0)*r;
        
                  double lat1 = M_PI * (-0.5 + (double) i / lats);
                  double z1 = sin(lat1)*r;
                  double zr1 = cos(lat1)*r;
        
                  glBegin(GL_QUAD_STRIP);
                  for(j = 0; j <= longs; j++) {
                        double lng = 2 * M_PI * (double) (j - 1) / longs;
                          double x = cos(lng) ;
                          double y = sin(lng) ;
            
                          glNormal3f(x * zr0 , y * zr0 , z0  );
                        glVertex3f(x * zr0 , y * zr0 , z0 );
                          glNormal3f(x * zr1, y * zr1, z1);
                          glVertex3f(x * zr1, y * zr1, z1);
                      }
                  glEnd();
        }
 
}

void RMXDrawSphere(float size){
    DrawSpheree(size,20,20);
}



void DrawTeapot(float f){

    glRotatef(g_fTeapotAngle2, 1, 1, 0);

}


void DrawPlane(float x)
{

    const GLfloat verts[] = {
        -x,   -0.001,   -x,
        -x,-0.001,x,
        x,-0.001,x,
        x,-0.001, -x
    };
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(3, GL_FLOAT, 0, verts);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 3);
    

    glPushMatrix();
   
    
    glTranslatef(0, -1, 0);
    glBegin(GL_QUADS);
    glVertex3f( -x,-0.001, -x);
    glVertex3f( -x,-0.001,x);
    glVertex3f(x,-0.001,x);
    glVertex3f(x,-0.001, -x);
    glEnd();

    glPopMatrix();
    
    
  
}

void DrawFog(bool draw){
GLfloat density = 0.0008 * draw;

GLfloat fogColor[4] = {0.9, 0.5, 0.5, 1.0};
    
    glEnable (GL_FOG);
    glFogi (GL_FOG_MODE, GL_EXP2);
    
    glFogfv (GL_FOG_COLOR, fogColor);
    
 
    
    glFogf (GL_FOG_DENSITY, density);
    

    
    glHint (GL_FOG_HINT, GL_NICEST);
    
//    glClearColor (0.0,0.0,0.0,1.0);
    
//    glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    

}
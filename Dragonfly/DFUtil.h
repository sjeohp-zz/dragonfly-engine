//
//  DFUtil.h
//  Dragonfly
//
//  Created by Joseph on 25/11/13.
//  Copyright (c) 2013 Joseph Mark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#define DISTANCE_BETWEEN(Ax, Ay, Bx, By)    sqrtf((Ax - Bx) * (Ax - Bx) + (Ay - By) * (Ay - By))

typedef struct DFPoint {
    GLfloat x;
    GLfloat y;
}   DFPoint;

typedef struct DFLine {
    DFPoint A;
    DFPoint B;
}   DFLine;

typedef struct ColouredVertex {
    GLfloat position[2];
    GLfloat colour[4];
}   ColouredVertex;

typedef struct DFVector3 {
    GLfloat x;
    GLfloat y;
    GLfloat z;
}   DFVector3;

typedef struct DFVector4 {
    GLfloat x;
    GLfloat y;
    GLfloat z;
    GLfloat a;
}   DFVector4;

DFVector3   DFVector3Make(GLfloat x, GLfloat y, GLfloat z);
DFVector4   DFVector4Make(GLfloat x, GLfloat y, GLfloat z, GLfloat a);
GLfloat     DFDistanceFromLineToPoint(DFLine line, DFPoint p);
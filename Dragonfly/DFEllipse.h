//
//  DFEllipse.h
//  Dragonfly
//
//  Created by Joseph on 25/11/13.
//  Copyright (c) 2013 Joseph Mark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "DFUtil.h"

#define ELLIPSE_RESOLUTION  64

typedef struct DFEllipseData {
    ColouredVertex          vertices[ELLIPSE_RESOLUTION];
    GLuint                  arrayObject;
    GLuint                  vertexBuffer;
    GLKVector3              position;
    GLKVector3              scale;
    GLfloat                 rotation;
    struct DFEllipseData*   next;
}   DFEllipseData;

DFEllipseData*      DFEllipseMake(GLfloat x, GLfloat y, GLfloat radius);
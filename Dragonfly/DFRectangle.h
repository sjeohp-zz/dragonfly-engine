//
//  DFRectangle.h
//  Dragonfly
//
//  Created by Joseph on 25/11/13.
//  Copyright (c) 2013 Joseph Mark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "DFUtil.h"

const GLushort RectIndices[] = {
    0, 1, 2,
    2, 3, 0
};

typedef struct DFRectangleData {
    ColouredVertex          vertices[4];
    GLuint                  vertexBuffer;
    GLuint                  indexBuffer;
    GLuint                  arrayObject;
    GLKVector3              position;
    GLKVector3              scale;
    GLfloat                 rotation;
    struct DFRectangleData* next;
}   DFRectangleData;

DFRectangleData*    DFRectangleMake(GLfloat x, GLfloat y, GLfloat width, GLfloat height);
void                DFRectangleFree(DFRectangleData* rect);
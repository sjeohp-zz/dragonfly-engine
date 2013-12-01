//
//  DFCollidable.h
//  Dragonfly
//
//  Created by Joseph on 25/11/13.
//  Copyright (c) 2013 Joseph Mark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "DFUtil.h"

typedef struct DFCollidableData {
    GLfloat                     x;
    GLfloat                     y;
    GLfloat                     radius;
    GLfloat                     width;
    GLfloat                     height;
    struct DFCollidableData*    next;
}   DFCollidableData;

DFCollidableData*   DFCollidableMakeRect(GLfloat x, GLfloat y, GLfloat width, GLfloat height);
DFCollidableData*   DFCollidableMakeCirc(GLfloat x, GLfloat y, GLfloat radius);
GLuint              DFCollidableDistanceFromRectToCirc(DFCollidableData* rect, DFCollidableData* circ);
BOOL                DFCollidableCheckCollisionBetweenCircAndCirc(DFCollidableData* A, DFCollidableData* B);
BOOL                DFCollidableCheckCollisionBetweenRectAndCirc(DFCollidableData* rect, DFCollidableData* circ);
BOOL                DFCollidableCheckCollisionBetweenRectAndRect(DFCollidableData* A, DFCollidableData* B);
void                DFCollidableCollisionBetween(DFCollidableData* objA, DFCollidableData* objB);
void                DFCollidableFree(DFCollidableData* data);
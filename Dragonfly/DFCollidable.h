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
    GLKVector3                  position;
    GLKVector3                  velocity;
    GLfloat                     rotation;
    GLfloat                     rotationalVelocity;
    GLfloat                     radius;
    GLfloat                     width;
    GLfloat                     height;
    BOOL                        didCollide;
    BOOL                        physics;
    DFPoint                     collisionPoint;
    GLfloat                     mass;
    GLfloat                     elasticity;
    struct DFCollidableData*    next;
}   DFCollidableData;

DFCollidableData*   DFCollidableMakeRect(GLfloat x, GLfloat y, GLfloat width, GLfloat height);
DFCollidableData*   DFCollidableMakeCirc(GLfloat x, GLfloat y, GLfloat radius);
void                DFCollidableAddPhysics(DFCollidableData* collidable, GLfloat mass, GLfloat elasticity);
GLuint              DFCollidableDistanceFromRectToCirc(DFCollidableData* rect, DFCollidableData* circ);
BOOL                DFCollidableCheckCollisionBetweenCircAndCirc(DFCollidableData* A, DFCollidableData* B);
BOOL                DFCollidableCheckCollisionBetweenRectAndCirc(DFCollidableData* rect, DFCollidableData* circ);
BOOL                DFCollidableCheckCollisionBetweenRectAndRect(DFCollidableData* A, DFCollidableData* B);
void                DFCollidableCollisionBetween(DFCollidableData* objA, DFCollidableData* objB);
void                DFCollidableFree(DFCollidableData* data);
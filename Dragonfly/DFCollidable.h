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
    GLKVector3                  translation;
    GLKVector3                  translationalVelocity;
    GLKVector3                  translationalAcceleration;
    
    GLfloat                     rotation;
    GLfloat                     rotationalVelocity;
    GLfloat                     rotationalAcceleration;
    
    GLfloat                     radius;
    GLfloat                     width;
    GLfloat                     height;
    
    GLKVector3*                 vertices;
    GLKVector3*                 normals;
    GLushort                    numberOfVertices;
    
    GLfloat                     density;
    GLfloat                     volume;
    
    BOOL                        didCollide;
    
}   DFCollidableData;

DFCollidableData*   DFCollidableMakeRect(GLfloat x, GLfloat y, GLfloat width, GLfloat height);
DFCollidableData*   DFCollidableMakeCirc(GLfloat x, GLfloat y, GLfloat radius);
void                DFCollidableAddPhysics(DFCollidableData* collidable, GLfloat mass, GLfloat elasticity);
BOOL                DFCollidableCheckCollisionBetweenCircAndCirc(DFCollidableData* A, DFCollidableData* B);
BOOL                DFCollidableCheckCollisionBetweenRectAndCirc(DFCollidableData* rect, DFCollidableData* circ);
BOOL                DFCollidableCheckCollisionBetweenRectAndRect(DFCollidableData* A, DFCollidableData* B);
void                DFCollidableCollisionBetween(DFCollidableData* objA, DFCollidableData* objB);
void                DFCollidableFree(DFCollidableData* data);
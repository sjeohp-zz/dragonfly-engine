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
//#import "DFGameObject.h"

typedef struct DFCollidableData {
    
    GLKVector3              translation;
    GLKVector3              translationalVelocity;
    GLKVector3              translationalForce;
    GLfloat                 translationalInertia;
    GLfloat                 translationalDrag;
    GLfloat                 translationalMaxspeed;
    
    GLfloat                 rotation;
    GLfloat                 rotationalVelocity;
    GLfloat                 rotationalForce;
    GLfloat                 rotationalInertia;
    GLfloat                 rotationalDrag;
    GLfloat                 rotationalMaxspeed;
    
    GLfloat                 restitution;
    
    GLfloat                     radius;
    GLfloat                     width;
    GLfloat                     height;
    
    GLKVector3*                 vertices;
    GLKVector3*                 normals;
    GLushort                    numberOfVertices;
    
    BOOL                        didCollide;
    
}   DFCollidableData;

DFCollidableData*   DFCollidableMakeRect(GLfloat x, GLfloat y, GLfloat width, GLfloat height);
DFCollidableData*   DFCollidableMakeCirc(GLfloat x, GLfloat y, GLfloat radius);
void                DFCollidableAddPhysics(DFCollidableData* collidable, GLfloat mass, GLfloat elasticity);
BOOL                DFCollidableCheckCollisionBetweenCircAndCirc(DFCollidableData* A, DFCollidableData* B);
BOOL                DFCollidableCheckCollisionBetweenRectAndCirc(DFCollidableData* rect, DFCollidableData* circ);
BOOL                DFCollidableCheckCollisionBetweenRectAndRect(DFCollidableData* A, DFCollidableData* B);
void                DFCollidableCollisionBetween(DFCollidableData* objA, DFCollidableData* objB);
void                DFCollidableTransformVertices(DFCollidableData* collidable);
void                DFCollidableFree(DFCollidableData* data);
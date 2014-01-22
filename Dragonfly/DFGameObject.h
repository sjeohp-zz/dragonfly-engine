//
//  DFGameObject.h
//  Dragonfly
//
//  Created by Joseph on 25/11/13.
//  Copyright (c) 2013 Joseph Mark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <CoreMotion/CoreMotion.h>

#import "DFRender.h"
#import "DFCollidable.h"
#import "DFUtil.h"
#import "DFQuadtree.h"

typedef struct DFGameObject {
    
    DFRenderableData*       renderableData;
    DFCollidableData*       collidableData;
    
    void                    (* updateWithAttitude)(struct DFGameObject* obj, CMAttitude* attitude, GLfloat dT);
    void                    (* updateWithTarget)(struct DFGameObject* obj, GLKVector3 targetVector, GLfloat dT);
    void                    (* updateWithNothing)(struct DFGameObject* obj, GLfloat dT);
    
    GLKVector3              translation;
    GLKVector3              translationalVelocity;
    GLKVector3              translationalForce;
    
    GLfloat                 volume;
    GLfloat                 density;
    GLfloat                 mass;
    GLfloat                 drag;
    GLfloat                 maxVelocity;
    
    GLfloat                 rotation;
    GLfloat                 rotationalVelocity;
    GLfloat                 rotationalForce;
    
}   DFGameObject;

DFGameObject*       DFGameObjectMake();

void                DFGameObjectAddRenderable(DFGameObject* obj, DFRenderableData* renderable);
void                DFGameObjectAddCollidable(DFGameObject* obj, DFCollidableData* collidable);

void                DFGameObjectUpdateWithAttitude(DFGameObject* obj, CMAttitude* attitude, GLfloat dT);
void                DFGameObjectUpdateWithTarget(DFGameObject* obj, GLKVector3 targetVector, GLfloat dT);
void                DFGameObjectUpdateWithNothing(DFGameObject* obj, GLfloat dT);

void                DFGameObjectFree(DFGameObject* obj);
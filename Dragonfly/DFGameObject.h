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

#import "DFTexture.h"
#import "DFRectangle.h"
#import "DFEllipse.h"
#import "DFCollidable.h"
#import "DFUtil.h"
#import "DFQuadtree.h"

typedef struct DFGameObject {
    DFTextureData*          textureData;
    DFRectangleData*        rectangleData;
    DFEllipseData*          ellipseData;
    DFCollidableData*       collidableData;
    
    void                    (* updateWithAttitude)(struct DFGameObject* obj, CMAttitude* attitude, GLfloat dT);
    void                    (* updateWithTarget)(struct DFGameObject* obj, GLKVector3 targetVector, GLfloat dT);
    void                    (* updateWithNothing)(struct DFGameObject* obj, GLfloat dT);
    
    GLKVector3              translation;
    GLKVector3              translationalVelocity;
    GLKVector3              translationalAcceleration;
    
    GLfloat                 rotation;
    GLfloat                 rotationalVelocity;
    GLfloat                 rotationalAcceleration;
    
    GLfloat                 mass;
    GLfloat                 drag;
    GLfloat                 thrust;
    GLfloat                 elasticity;
    GLuint                  maxSpeed;
}   DFGameObject;


DFGameObject*       DFGameObjectMake();

void                DFGameObjectAddTexture(DFGameObject* obj, DFTextureData* texture);
void                DFGameObjectAddRectangle(DFGameObject* obj, DFRectangleData* rect);
void                DFGameObjectAddEllipse(DFGameObject* obj, DFEllipseData* ellipse);
void                DFGameObjectAddCollidable(DFGameObject* obj, DFCollidableData* collidable);

void                DFGameObjectUpdateWithAttitude(DFGameObject* obj, CMAttitude* attitude, GLfloat dT);
void                DFGameObjectUpdateWithTarget(DFGameObject* obj, GLKVector3 targetVector, GLfloat dT);
void                DFGameObjectUpdateWithNothing(DFGameObject* obj, GLfloat dT);

void                DFGameObjectFree(DFGameObject* obj);
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

typedef struct DFGameObject {
    DFTextureData*          textureData;
    DFRectangleData*        rectangleData;
    DFEllipseData*          ellipseData;
    DFCollidableData*       collidableData;
    GLKVector3              position;
    GLKVector3              velocity;
    GLfloat                 rotation;
    GLfloat                 mass;
    GLfloat                 drag;
    GLfloat                 thrust;
    GLfloat                 elasticity;
    GLuint                  maxspeed;
    void                    (* updateWithAttitude)(struct DFGameObject* obj, CMAttitude* attitude, GLfloat dT);
    void                    (* updateWithTarget)(struct DFGameObject* obj, GLKVector2 target, GLfloat dT);
    void                    (* update)(struct DFGameObject* obj, GLfloat dT);
}   DFGameObject;

DFGameObject*       DFGameObjectMake();
void                DFGameObjectAddTexture(DFGameObject* obj, DFTextureData* texture);
void                DFGameObjectAddRectangle(DFGameObject* obj, DFRectangleData* rect);
void                DFGameObjectAddEllipse(DFGameObject* obj, DFEllipseData* ellipse);
void                DFGameObjectAddCollidable(DFGameObject* obj, DFCollidableData* collidable);
void                DFGameObjectUpdateWithAttitude(DFGameObject* obj, CMAttitude* attitude, GLfloat dT);
void                DFGameObjectUpdateWithTarget(DFGameObject* obj, GLKVector2 target, GLfloat dT);
void                DFGameObjectUpdate(DFGameObject* obj, GLfloat dT);
void                DFGameObjectFree(DFGameObject* obj);
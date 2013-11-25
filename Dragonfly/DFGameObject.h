//
//  DFGameObject.h
//  Dragonfly
//
//  Created by Joseph on 25/11/13.
//  Copyright (c) 2013 Joseph Mark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

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
    DFVector3               position;
    DFVector3               centre;
    DFVector3               scale;
    DFVector4               colour;
}   DFGameObject;

DFGameObject*       DFGameObjectMake();
void                DFGameObjectAddTexture(DFGameObject* obj, DFTextureData* texture);
void                DFGameObjectAddRectangle(DFGameObject* obj, DFRectangleData* rect);
void                DFGameObjectAddEllipse(DFGameObject* obj, DFEllipseData* ellipse);
void                DFGameObjectAddCollidable(DFGameObject* obj, DFCollidableData* collidable);
//
//  DFGameObject.m
//  Dragonfly
//
//  Created by Joseph on 25/11/13.
//  Copyright (c) 2013 Joseph Mark. All rights reserved.
//

#import "DFGameObject.h"

DFGameObject* DFGameObjectMake()
{
    DFGameObject* obj = (DFGameObject*)malloc(sizeof(DFGameObject));
    
    obj->textureData = NULL;
    obj->rectangleData = NULL;
    obj->ellipseData = NULL;
    obj->collidableData = NULL;
    
    obj->updateWithAttitude = NULL;
    obj->updateWithTarget = NULL;
    obj->updateWithNothing = NULL;
    
    obj->translation = GLKVector3Make(0, 0, 0);
    obj->translationalVelocity = GLKVector3Make(0, 0, 0);
    obj->translationalForce = GLKVector3Make(0, 0, 0);
    
    obj->rotation = 0;
    obj->rotationalVelocity = 0;
    obj->rotationalForce = 0;
    
    obj->translationalInertia = 1;
    obj->translationalDrag = 1;
    obj->rotationalInertia = 1;
    obj->rotationalDrag = 1;
    
    obj->elasticity = 1;
    
    obj->translationalMaxspeed = FLT_MAX;
    obj->rotationalMaxspeed = FLT_MAX;
    
    return obj;
}

void DFGameObjectAddTexture(DFGameObject* obj, DFTextureData* texture)
{
    DFTextureData *curr = obj->textureData;
    if (curr == NULL){
        obj->textureData = texture;
    } else {
        while (curr->next != NULL){
            curr = curr->next;
        }
        curr->next = texture;
    }
}

void DFGameObjectAddRectangle(DFGameObject* obj, DFRectangleData* rect)
{
    DFRectangleData *curr = obj->rectangleData;
    if (curr == NULL){
        obj->rectangleData = rect;
    } else {
        while (curr->next != NULL){
            curr = curr->next;
        }
        curr->next = rect;
    }
}

void DFGameObjectAddEllipse(DFGameObject* obj, DFEllipseData* ellipse)
{
    DFEllipseData *curr = obj->ellipseData;
    if (curr == NULL){
        obj->ellipseData = ellipse;
    } else {
        while (curr->next != NULL){
            curr = curr->next;
        }
        curr->next = ellipse;
    }
}

void DFGameObjectAddCollidable(DFGameObject* obj, DFCollidableData* collidable)
{
    obj->collidableData = collidable;
}

void DFGameObjectReadCollisionData(DFGameObject* obj, GLfloat dT)
{
    if (obj == NULL || obj->collidableData == NULL || !obj->collidableData->didCollide){
        return;
    }
    
    DFCollidableData* collision = obj->collidableData;
    
    /*
    GLKVector3 revTranslation = GLKVector3MultiplyScalar(GLKVector3Negate(obj->translationalVelocity), dT*1.1);
    obj->translation = GLKVector3Add(obj->translation, revTranslation);
*/
    //obj->translation = GLKVector3Add(obj->translation, GLKVector3MultiplyScalar(collision->translationalVelocity, dT));
    obj->translationalVelocity = collision->translationalVelocity;// GLKVector3Add(obj->translationalVelocity, GLKVector3MultiplyScalar(collision->translationalForce, 1));
    
    collision->translation = obj->translation;
    //collision->translationalVelocity = GLKVector3Make(0, 0, 0);
    collision->translationalForce = GLKVector3Make(0, 0, 0);
    
    //GLfloat revRotation = -obj->rotationalVelocity * dT;
    //obj->rotation = obj->rotation + revRotation;
    
    obj->rotationalVelocity = collision->rotationalVelocity;
    
    collision->rotation = obj->rotation;
    collision->rotationalForce = 0;
    
    collision->didCollide = NO;
}

void DFGameObjectUpdateRenderData(DFGameObject* obj)
{
    if (obj == NULL){
        return;
    }
    DFTextureData* texture = obj->textureData;
    while (texture != NULL){
        texture->translation = obj->translation;
        texture->rotation = obj->rotation;
        texture = texture->next;
    }
    DFRectangleData* rect = obj->rectangleData;
    while (rect != NULL){
        rect->translation = obj->translation;
        rect->rotation = obj->rotation;
        rect = rect->next;
    }
    DFEllipseData* ellipse = obj->ellipseData;
    while (ellipse != NULL){
        ellipse->translation = obj->translation;
        ellipse->rotation = obj->rotation;
        ellipse = ellipse->next;
    }
}

void DFGameObjectTransform(DFGameObject* obj, GLfloat dT)
{
    GLKVector3 newTV = GLKVector3Add(GLKVector3MultiplyScalar(obj->translationalVelocity, 1 - obj->translationalDrag),
                                           GLKVector3MultiplyScalar(obj->translationalForce, 1 / obj->translationalInertia));
    if (GLKVector3Length(newTV) > obj->translationalMaxspeed){
        newTV = GLKVector3MultiplyScalar(newTV, obj->translationalMaxspeed / GLKVector3Length(newTV));
    }
    obj->translationalVelocity = newTV;
    GLKVector3 curMove = GLKVector3MultiplyScalar(obj->translationalVelocity, dT);
    obj->translation = GLKVector3Add(obj->translation, curMove);
    obj->translationalForce = GLKVector3Make(0, 0, 0);
    
    GLfloat newRV = obj->rotationalVelocity * (1 - obj->rotationalDrag) + obj->rotationalForce / obj->rotationalInertia;
    if (newRV > obj->rotationalMaxspeed) newRV = obj->rotationalMaxspeed;
    if (newRV < -obj->rotationalMaxspeed) newRV = -obj->rotationalMaxspeed;
    obj->rotationalVelocity = newRV;
    obj->rotation += obj->rotationalVelocity * dT;
    obj->rotationalForce = 0;
    
    if (obj->collidableData != NULL){
        
        obj->collidableData->translation = obj->translation;
        obj->collidableData->translationalVelocity = obj->translationalVelocity;
        obj->collidableData->translationalForce = GLKVector3Make(0, 0, 0);
        obj->collidableData->translationalInertia = obj->translationalInertia;
        
        obj->collidableData->rotation = obj->rotation;
        obj->collidableData->rotationalVelocity = obj->rotationalVelocity;
        obj->collidableData->rotationalInertia = obj->rotationalInertia;
        
        DFCollidableTransformVertices(obj->collidableData);
    }
}

void DFGameObjectUpdateWithAttitude(DFGameObject* obj, CMAttitude* attitude, GLfloat dT)
{
    if (obj == NULL || obj->updateWithAttitude == NULL){
        printf("DFGameObjectUpdateWithAttitude error.");
        return;
    }
    DFGameObjectReadCollisionData(obj, dT);
    DFGameObjectUpdateRenderData(obj);
    obj->updateWithAttitude(obj, attitude, dT);
    DFGameObjectTransform(obj, dT);
}

void DFGameObjectUpdateWithTarget(DFGameObject* obj, GLKVector3 targetVector, GLfloat dT)
{
    if (obj == NULL || obj->updateWithTarget == NULL){
        printf("DFGameObjectUpdateWithTarget error.");
        return;
    }
    DFGameObjectReadCollisionData(obj, dT);
    DFGameObjectUpdateRenderData(obj);
    obj->updateWithTarget(obj, targetVector, dT);
    DFGameObjectTransform(obj, dT);
}

void DFGameObjectUpdateWithNothing(DFGameObject* obj, GLfloat dT)
{
    if (obj == NULL || obj->updateWithNothing == NULL){
        printf("DFGameObjectUpdateWithNothing error.");
        return;
    }
    DFGameObjectReadCollisionData(obj, dT);
    DFGameObjectUpdateRenderData(obj);
    obj->updateWithNothing(obj, dT);
    DFGameObjectTransform(obj, dT);
}

void DFGameObjectFree(DFGameObject* obj)
{
    if (obj == NULL){
        return;
    }
    if (obj->textureData != NULL){
        DFTextureFree(obj->textureData);
    }
    if (obj->rectangleData != NULL){
        DFRectangleFree(obj->rectangleData);
    }
    if (obj->ellipseData != NULL){
        DFEllipseFree(obj->ellipseData);
    }
    if (obj->collidableData != NULL){
        DFCollidableFree(obj->collidableData);
    }
    free(obj);
}
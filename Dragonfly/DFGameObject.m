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
    
    obj->renderableData = NULL;
    obj->collidableData = NULL;
    
    obj->updateWithAttitude = NULL;
    obj->updateWithTarget = NULL;
    obj->updateWithNothing = NULL;
    
    obj->translation = GLKVector3Make(0, 0, 0);
    obj->translationalVelocity = GLKVector3Make(0, 0, 0);
    obj->translationalForce = GLKVector3Make(0, 0, 0);
    obj->mass = 1;
    obj->drag = 1;
    obj->maxVelocity = FLT_MAX;
    
    obj->rotation = 0;
    obj->rotationalVelocity = 0;
    obj->rotationalForce = 0;
    
    return obj;
}

void DFGameObjectAddRenderable(DFGameObject* obj, DFRenderableData* renderable)
{
    obj->renderableData = renderable;
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

void DFGameObjectUpdateRenderableData(DFGameObject* obj)
{
    if (obj == NULL){
        return;
    }
    DFRenderableData* data = obj->renderableData;
    data->translation = obj->translation;
    data->rotation = obj->rotation;
}

void DFGameObjectTransform(DFGameObject* obj, GLfloat dT)
{
    GLKVector3 newTransVel = GLKVector3Add(GLKVector3MultiplyScalar(obj->translationalVelocity, 1 - obj->drag),
                                           GLKVector3MultiplyScalar(obj->translationalForce, 1 / obj->mass));
    
    if (GLKVector3Length(newTransVel) > obj->maxVelocity){
        newTransVel = GLKVector3MultiplyScalar(newTransVel, obj->maxVelocity / GLKVector3Length(newTransVel));
    }
    obj->translationalVelocity = newTransVel;
    GLKVector3 curMove = GLKVector3MultiplyScalar(obj->translationalVelocity, dT);
    obj->translation = GLKVector3Add(obj->translation, curMove);
    obj->translationalForce = GLKVector3Make(0, 0, 0);
    
    GLfloat newRV = obj->rotationalVelocity * (1 - obj->drag) + obj->rotationalForce / obj->mass;
    obj->rotationalVelocity = newRV;
    obj->rotation += obj->rotationalVelocity * dT;
    obj->rotationalForce = 0;
    
    if (obj->collidableData != NULL){
        
        obj->collidableData->translation = obj->translation;
        obj->collidableData->translationalVelocity = obj->translationalVelocity;
        obj->collidableData->translationalForce = GLKVector3Make(0, 0, 0);
        obj->collidableData->translationalInertia = obj->mass;
        
        obj->collidableData->rotation = obj->rotation;
        obj->collidableData->rotationalVelocity = obj->rotationalVelocity;
        obj->collidableData->rotationalInertia = obj->mass;
        
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
    DFGameObjectUpdateRenderableData(obj);
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
    DFGameObjectUpdateRenderableData(obj);
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
    DFGameObjectUpdateRenderableData(obj);
    obj->updateWithNothing(obj, dT);
    DFGameObjectTransform(obj, dT);
}

/*
void DFGameObjectFree(DFGameObject* obj)
{
    if (obj == NULL){
        return;
    }
    if (obj->renderableData->texture != NULL){
        DFTextureFree(obj->renderableData->texture);
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
*/
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
    obj->update = NULL;
    obj->position = GLKVector3Make(0, 0, 0);
    obj->velocity = GLKVector3Make(0, 0, 0);
    obj->rotation = 0;
    obj->mass = 1;
    obj->drag = 0;
    obj->thrust = 1;
    obj->elasticity = 1;
    obj->maxspeed = -1;
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
    DFCollidableData *curr = obj->collidableData;
    if (curr == NULL){
        obj->collidableData = collidable;
    } else {
        while (curr->next != NULL){
            curr = curr->next;
        }
        curr->next = collidable;
    }
}

void DFGameObjectUpdateData(DFGameObject* obj)
{
    if (obj == NULL){
        return;
    }
    DFTextureData* texture = obj->textureData;
    while (texture != NULL){
        texture->position = obj->position;
        texture->rotation = obj->rotation;
        texture = texture->next;
    }
    DFRectangleData* rect = obj->rectangleData;
    while (rect != NULL){
        rect->position = obj->position;
        rect->rotation = obj->rotation;
        rect = rect->next;
    }
    DFEllipseData* ellipse = obj->ellipseData;
    while (ellipse != NULL){
        ellipse->position = obj->position;
        ellipse->rotation = obj->rotation;
        ellipse = ellipse->next;
    }
}

void DFGameObjectUpdateWithAttitude(DFGameObject* obj, CMAttitude* attitude, GLfloat dT)
{
    if (obj->updateWithAttitude == NULL){
        printf("obj->updateWithAttitude == NULL");
        return;
    }
    obj->updateWithAttitude(obj, attitude, dT);
    DFGameObjectUpdateData(obj);
}

void DFGameObjectUpdateWithTarget(DFGameObject* obj, GLKVector2 target, GLfloat dT)
{
    if (obj->updateWithTarget == NULL){
        printf("obj->updateWithTarget == NULL");
        return;
    }
    obj->updateWithTarget(obj, target, dT);
    DFGameObjectUpdateData(obj);
}

void DFGameObjectUpdate(DFGameObject* obj, GLfloat dT)
{
    if (obj->update == NULL){
        printf("obj->update == NULL");
        return;
    }
    obj->update(obj, dT);
    DFGameObjectUpdateData(obj);
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
    if (obj->updateWithAttitude != NULL){
        free(obj->updateWithAttitude);
    }
    if (obj->updateWithTarget != NULL){
        free(obj->updateWithTarget);
    }
    if (obj->update != NULL){
        free(obj->update);
    }
    free(obj);
}
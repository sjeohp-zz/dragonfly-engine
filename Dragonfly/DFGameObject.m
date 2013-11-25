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


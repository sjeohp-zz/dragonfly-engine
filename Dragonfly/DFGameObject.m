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
    obj->translationalAcceleration = GLKVector3Make(0, 0, 0);
    
    obj->rotation = 0;
    obj->rotationalVelocity = 0;
    obj->rotationalAcceleration = 0;
    
    obj->mass = 1;
    obj->drag = 0;
    obj->thrust = 1;
    obj->elasticity = 1;
    obj->maxSpeed = -1;
    
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
    
    GLKVector3 revTranslation = GLKVector3MultiplyScalar(GLKVector3Negate(obj->translationalVelocity), dT);
    obj->translation = GLKVector3Add(obj->translation, revTranslation);
            
    obj->translationalVelocity = collision->translationalVelocity;
    obj->translation = GLKVector3Add(obj->translation, GLKVector3MultiplyScalar(obj->translationalVelocity, dT));
    
    collision->translation = obj->translation;
    collision->translationalAcceleration = GLKVector3Make(0, 0, 0);
    
    GLfloat revRotation = -obj->rotationalVelocity * dT;
    obj->rotation = obj->rotation + revRotation;
    
    obj->rotationalVelocity = collision->rotationalVelocity;
    obj->rotation += obj->rotationalVelocity;
    
    collision->rotation = obj->rotation;
    collision->rotationalAcceleration = 0;
    
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

void DFCollidableTransformVertices(DFCollidableData* collidable)
{
    if (collidable->radius != -1){
        return;
    }
    
    GLfloat r = GLKMathDegreesToRadians(collidable->rotation);
    GLfloat sinr = sinf(r);
    GLfloat cosr = cosf(r);
    GLfloat x = collidable->translation.x;
    GLfloat y = collidable->translation.y;
    GLfloat w = collidable->width/2;
    GLfloat h = collidable->height/2;
    
    
    collidable->vertices[0] = GLKVector3Add(GLKVector3Make(cosr * (-w) - sinr * (-h), sinr * (-w) + cosr * (-h), 0),
                                            collidable->translation);
    collidable->vertices[1] = GLKVector3Add(GLKVector3Make(cosr * (w) - sinr * (h), sinr * (-w) + cosr * (-h), 0),
                                            collidable->translation);
    collidable->vertices[2] = GLKVector3Add(GLKVector3Make(cosr * (w) - sinr * (h), sinr * (w) + cosr * (h), 0),
                                            collidable->translation);
    collidable->vertices[3] = GLKVector3Add(GLKVector3Make(cosr * (-w) - sinr * (-h), sinr * (w) + cosr * (h), 0),
                                            collidable->translation);
     
    /*
    collidable->vertices[0] = GLKVector3Make(x - w, y - h, 0);
    collidable->vertices[1] = GLKVector3Make(x + w, y - h, 0);
    collidable->vertices[2] = GLKVector3Make(x + w, y + h, 0);
    collidable->vertices[3] = GLKVector3Make(x - w, y + h, 0);
    */
    collidable->normals[0] = DFGeometryNormal(collidable->vertices[0], collidable->vertices[1]);
    collidable->normals[1] = DFGeometryNormal(collidable->vertices[1], collidable->vertices[2]);
    collidable->normals[2] = DFGeometryNormal(collidable->vertices[2], collidable->vertices[3]);
    collidable->normals[3] = DFGeometryNormal(collidable->vertices[3], collidable->vertices[0]);
}

void DFGameObjectTransform(DFGameObject* obj, GLfloat dT)
{
    /*
    obj->translationalVelocity = GLKVector3Add(obj->translationalVelocity, obj->translationalAcceleration);
    obj->translationalAcceleration = GLKVector3Make(0, 0, 0);
    obj->translation = GLKVector3Add(obj->translation, GLKVector3MultiplyScalar(obj->translationalVelocity, dT));
    
    obj->rotationalVelocity += obj->rotationalAcceleration;
    obj->rotationalAcceleration = 0;
    obj->rotation += obj->rotationalVelocity;
    */
    if (obj->collidableData != NULL){
        obj->collidableData->translation = obj->translation;
        obj->collidableData->translationalVelocity = obj->translationalVelocity;
        obj->collidableData->rotation = obj->rotation;
        obj->collidableData->rotationalVelocity = obj->rotationalVelocity;
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
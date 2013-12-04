//
//  DFQuadtree.m
//  Dragonfly
//
//  Created by Joseph on 25/11/13.
//  Copyright (c) 2013 Joseph Mark. All rights reserved.
//

#import "DFQuadtree.h"

DFQuadtree* DFQuadtreeMake(GLfloat x, GLfloat y, GLfloat width, GLfloat height, GLshort depth)
{
    if (depth <= 0){
        return NULL;
    }
    DFQuadtree *ptr = (DFQuadtree *)malloc(sizeof(DFQuadtree));
    ptr->parent = NULL;
    ptr->depth = 0;
    ptr->x = x;
    ptr->y = y;
    ptr->width = width;
    ptr->height = height;
    ptr->subtrees[0] = DFQuadtreeMakeWithParent(ptr, 0, depth - 1);
    ptr->subtrees[1] = DFQuadtreeMakeWithParent(ptr, 1, depth - 1);
    ptr->subtrees[2] = DFQuadtreeMakeWithParent(ptr, 2, depth - 1);
    ptr->subtrees[3] = DFQuadtreeMakeWithParent(ptr, 3, depth - 1);
    if (depth == 1){
        ptr->leaf = YES;
    } else {
        ptr->leaf = NO;
    }
    ptr->contents = DFLinkedListMake(NULL);
    return ptr;
}

DFQuadtree* DFQuadtreeMakeWithParent(DFQuadtree *parent, short index, GLshort depth)
{
    if (depth <= 0){
        return NULL;
    }
    DFQuadtree *ptr = (DFQuadtree *)malloc(sizeof(DFQuadtree));
    ptr->parent = parent;
    ptr->depth = parent->depth + 1;;
    ptr->width = parent->width/2.0;
    ptr->height = parent->height/2.0;
    if (index == 0){
        ptr->x = parent->x ;//- ptr->width/2.0;
        ptr->y = parent->y ;//- ptr->height/2.0;
    } else if (index == 1){
        ptr->x = parent->x + parent->width/2.0;
        ptr->y = parent->y ;//- ptr->height/2.0;
    } else if (index == 2){
        ptr->x = parent->x + parent->width/2.0;
        ptr->y = parent->y + parent->height/2.0;
    } else if (index == 3){
        ptr->x = parent->x ;//- ptr->width/2.0;
        ptr->y = parent->y + ptr->height/2.0;
    }
    ptr->subtrees[0] = DFQuadtreeMakeWithParent(ptr, 0, depth - 1);
    ptr->subtrees[1] = DFQuadtreeMakeWithParent(ptr, 1, depth - 1);
    ptr->subtrees[2] = DFQuadtreeMakeWithParent(ptr, 2, depth - 1);
    ptr->subtrees[3] = DFQuadtreeMakeWithParent(ptr, 3, depth - 1);
    if (depth == 1){
        ptr->leaf = YES;
    } else {
        ptr->leaf = NO;
    }
    ptr->contents = DFLinkedListMake(NULL);
    return ptr;
}

void DFQuadtreeInsertCollidable(DFQuadtree *qt, DFCollidableData* collidable)
{
    if (collidable->radius != -1){
        if (qt->leaf ||
            collidable->radius >= qt->width/2 ||
            collidable->radius >= qt->height/2){
            qt->contents = DFLinkedListAppendItem(qt->contents, collidable);
        } else {
            BOOL fit = NO;
            for (int i = 0; i < 4; i++){
                if (collidable->translation.x - collidable->radius > qt->subtrees[i]->x &&
                    collidable->translation.x + collidable->radius < qt->subtrees[i]->x + qt->subtrees[i]->width &&
                    collidable->translation.y - collidable->radius > qt->subtrees[i]->y &&
                    collidable->translation.y + collidable->radius < qt->subtrees[i]->y + qt->subtrees[i]->height){
                    fit = YES;
                    DFQuadtreeInsertCollidable(qt->subtrees[i], collidable);
                }
            }
            if (!fit){
                qt->contents = DFLinkedListAppendItem(qt->contents, collidable);
            }
        }
    } else {
        if (qt->leaf ||
            collidable->width >= qt->width/2 ||
            collidable->height >= qt->height/2){
            qt->contents = DFLinkedListAppendItem(qt->contents, collidable);
        } else {
            BOOL fit = NO;
            for (int i = 0; i < 4; i++){
                if (collidable->translation.x - collidable->width/2 > qt->subtrees[i]->x &&
                    collidable->translation.x + collidable->width/2 < qt->subtrees[i]->x + qt->subtrees[i]->width &&
                    collidable->translation.y - collidable->height/2 > qt->subtrees[i]->y &&
                    collidable->translation.y + collidable->height/2 < qt->subtrees[i]->y + qt->subtrees[i]->height){
                    fit = YES;
                    DFQuadtreeInsertCollidable(qt->subtrees[i], collidable);
                }
            }
            if (!fit){
                qt->contents = DFLinkedListAppendItem(qt->contents, collidable);
            }
        }
    }
}

DFLinkedList* DFQuadtreeCheckCollisions(DFQuadtree *qt)
{
    DFLinkedList* objectsFromSubtrees = DFLinkedListMake(NULL);
    
    if (!qt->leaf)
    {
        for (int i = 0; i < 4; i++){
            objectsFromSubtrees = DFLinkedListAppendList(objectsFromSubtrees, DFQuadtreeCheckCollisions(qt->subtrees[i]));
        }
    }
    
    DFLinkedList* contentsCurr;
    DFLinkedList* subtreesCurr;
    DFLinkedList* contentsOther;
    
    contentsCurr = qt->contents;
    
    while (contentsCurr != NULL && contentsCurr->data != NULL){
        
        subtreesCurr = objectsFromSubtrees;
        
        while (subtreesCurr != NULL && subtreesCurr->data != NULL){
            
            DFCollidableData* currA = contentsCurr->data;
            DFCollidableData* currB = subtreesCurr->data;
            
            if (currA->radius != -1){
                if (currB->radius != -1){
                    if (DFCollidableCheckCollisionBetweenCircAndCirc(currA, currB)){
                        DFCollidableCollisionBetween(currA, currB);
                    }
                } else {
                    if (DFCollidableCheckCollisionBetweenRectAndCirc(currB, currA)){
                        DFCollidableCollisionBetween(currA, currB);
                    }
                }
            } else {
                if (currB->radius != -1){
                    if (DFCollidableCheckCollisionBetweenRectAndCirc(currA, currB)){
                        DFCollidableCollisionBetween(currA, currB);
                    }
                } else {
                    if (DFCollidableCheckCollisionBetweenRectAndRect(currA, currB)){
                        DFCollidableCollisionBetween(currA, currB);
                    }
                }
            }
            subtreesCurr = subtreesCurr->next;
        }
        
        contentsOther = contentsCurr->next;
        
        while (contentsOther != NULL && contentsOther->data != NULL){
            
            DFCollidableData* currA = contentsCurr->data;
            DFCollidableData* currB = contentsOther->data;
                
            if (currA->radius != -1){
                if (currB->radius != -1){
                    if (DFCollidableCheckCollisionBetweenCircAndCirc(currA, currB)){
                        DFCollidableCollisionBetween(currA, currB);
                    }
                } else {
                    if (DFCollidableCheckCollisionBetweenRectAndCirc(currB, currA)){
                        DFCollidableCollisionBetween(currA, currB);
                    }
                }
            } else {
                if (currB->radius != -1){
                    if (DFCollidableCheckCollisionBetweenRectAndCirc(currA, currB)){
                        DFCollidableCollisionBetween(currA, currB);
                    }
                } else {
                    if (DFCollidableCheckCollisionBetweenRectAndRect(currA, currB)){
                        DFCollidableCollisionBetween(currA, currB);
                    }
                }
            }
            contentsOther = contentsOther->next;
        }
        contentsCurr = contentsCurr->next;
    }
    
    DFLinkedList* objectsForParent = DFLinkedListAppendList(objectsFromSubtrees, qt->contents);
    return objectsForParent;
}

void DFQuadtreeFree(DFQuadtree *qt)
{
    if (NULL == qt){
        return;
    }
    if (NULL != qt->subtrees[0]){
        for (int i = 0; i < 4; i++){
            DFQuadtreeFree(qt->subtrees[i]);
        }
    }
    if (NULL != qt->contents){
        DFLinkedListFree(qt->contents);
    }
    free(qt);
}

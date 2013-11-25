//
//  DFQuadtree.m
//  Dragonfly
//
//  Created by Joseph on 25/11/13.
//  Copyright (c) 2013 Joseph Mark. All rights reserved.
//

#import "DFQuadtree.h"

struct DFQuadtree * DFQuadtreeMake(GLuint x, GLuint y, GLuint width, GLuint height, GLshort depth)
{
    if (depth == 0){
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

struct DFQuadtree* DFQuadtreeMakeWithParent(DFQuadtree *parent, short index, GLshort depth)
{
    if (depth == 0){
        return NULL;
    }
    DFQuadtree *ptr = (DFQuadtree *)malloc(sizeof(DFQuadtree));
    ptr->parent = parent;
    ptr->depth = parent->depth + 1;;
    ptr->width = parent->width/2.0;
    ptr->height = parent->height/2.0;
    if (index == 0){
        ptr->x = parent->x;
        ptr->y = parent->y;
    } else if (index == 1){
        ptr->x = parent->x + parent->width/2.0;
        ptr->y = parent->y;
    } else if (index == 2){
        ptr->x = parent->x + parent->width/2.0;
        ptr->y = parent->y + parent->height/2.0;
    } else if (index == 3){
        ptr->x = parent->x;
        ptr->y = parent->y + parent->height/2.0;
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

void DFQuadtreeInsertObject(DFQuadtree *qt, DFGameObject* obj)
{
    DFCollidableData* curr = obj->collidableData;
    while (curr != NULL){
        if (curr->radius != -1){
            if (qt->leaf ||
                curr->radius >= qt->width/2 ||
                curr->radius >= qt->height/2){
                qt->contents = DFLinkedListAppendItem(qt->contents, obj);
            } else {
                BOOL fit = NO;
                for (int i = 0; i < 4; i++){
                    if (curr->x - curr->radius > qt->subtrees[i]->x &&
                        curr->x + curr->radius < qt->subtrees[i]->x + qt->subtrees[i]->width &&
                        curr->y - curr->radius > qt->subtrees[i]->y &&
                        curr->y + curr->radius < qt->subtrees[i]->y + qt->subtrees[i]->height){
                        fit = YES;
                        DFQuadtreeInsertObject(qt->subtrees[i], obj);
                    }
                }
                if (!fit){
                    qt->contents = DFLinkedListAppendItem(qt->contents, obj);
                }
            }
        } else {
            if (qt->leaf ||
                curr->width >= qt->width/2 ||
                curr->height >= qt->height/2){
                qt->contents = DFLinkedListAppendItem(qt->contents, obj);
            } else {
                BOOL fit = NO;
                for (int i = 0; i < 4; i++){
                    if (curr->x - curr->width/2 > qt->subtrees[i]->x &&
                        curr->x + curr->width/2 < qt->subtrees[i]->x + qt->subtrees[i]->width &&
                        curr->y - curr->height/2 > qt->subtrees[i]->y &&
                        curr->y + curr->height/2 < qt->subtrees[i]->y + qt->subtrees[i]->height){
                        fit = YES;
                        DFQuadtreeInsertObject(qt->subtrees[i], obj);
                    }
                }
                if (!fit){
                    qt->contents = DFLinkedListAppendItem(qt->contents, obj);
                }
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
    
    contentsCurr = qt->contents;
    
    while (contentsCurr != NULL && contentsCurr->data != NULL){
        
        subtreesCurr = objectsFromSubtrees;
        
        while (subtreesCurr != NULL && subtreesCurr->data != NULL){
            
            DFGameObject* objectA = contentsCurr->data;
            DFGameObject* objectB = subtreesCurr->data;
            
            DFCollidableData* currA = objectA->collidableData;
            
            while (currA != NULL){
                DFCollidableData* currB = objectB->collidableData;
                while (currB != NULL){
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
                    currB = currB->next;
                }
                currA = currA->next;
            }
            subtreesCurr = subtreesCurr->next;
        }
        contentsCurr = contentsCurr->next;
    }
    
    DFLinkedList* objectsForParent = DFLinkedListAppendList(objectsFromSubtrees, qt->contents);
    return objectsForParent;
}

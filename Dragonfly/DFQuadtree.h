//
//  DFQuadtree.h
//  Dragonfly
//
//  Created by Joseph on 25/11/13.
//  Copyright (c) 2013 Joseph Mark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "DFGameObject.h"
#import "DFCollidable.h"
#import "DFLinkedList.h"
#import "DFUtil.h"

typedef struct DFQuadtree
{
    struct DFQuadtree*      parent;
    struct DFQuadtree*      subtrees[4];
    struct DFLinkedList*    contents;
    BOOL                    leaf;
    GLushort                depth;
    GLfloat                 x;
    GLfloat                 y;
    GLfloat                 width;
    GLfloat                 height;
}   DFQuadtree;

struct DFQuadtree*      DFQuadtreeMakeRoot(GLfloat x, GLfloat y, GLfloat width, GLfloat height, GLshort depth);
struct DFQuadtree*      DFQuadtreeMakeWithParent(DFQuadtree* parent, short index, GLshort depth);
void                    DFQuadtreeInsertObject(DFQuadtree* qt, DFGameObject* obj);
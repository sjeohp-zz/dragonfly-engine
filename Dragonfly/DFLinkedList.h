//
//  DFLinkedList.h
//  Dragonfly
//
//  Created by Joseph on 25/11/13.
//  Copyright (c) 2013 Joseph Mark. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct DFLinkedList
{
    void*                   data;
    struct DFLinkedList*    next;
}   DFLinkedList;

struct DFLinkedList*    DFLinkedListMake(void* data);
struct DFLinkedList*    DFLinkedListAppendItem(DFLinkedList* list, void* data);
struct DFLinkedList*    DFLinkedListAppendList(DFLinkedList* list, DFLinkedList* listToAppend);
int                     DFLinkedListSize(DFLinkedList* list);
void                    DFLinkedListFree(DFLinkedList *list);

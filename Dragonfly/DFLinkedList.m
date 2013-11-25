//
//  DFLinkedList.m
//  Dragonfly
//
//  Created by Joseph on 25/11/13.
//  Copyright (c) 2013 Joseph Mark. All rights reserved.
//

#import "DFLinkedList.h"

DFLinkedList* DFLinkedListMake(void *data)
{
    DFLinkedList* ptr = (DFLinkedList*)malloc(sizeof(DFLinkedList));
    ptr->data = data;
    ptr->next = NULL;
    return ptr;
}

DFLinkedList* listAppendItem(DFLinkedList* list, void* data)
{
    if (NULL == list || NULL == list->data){
        return DFLinkedListMake(data);
    }
    DFLinkedList* ptr = (DFLinkedList*)malloc(sizeof(DFLinkedList));
    ptr->data = data;
    ptr->next = NULL;
    DFLinkedList* first = list;
    DFLinkedList* curr = first;
    while (NULL != curr->next){
        curr = curr->next;
    }
    curr->next = ptr;
    return first;
}

DFLinkedList* listAppendList(DFLinkedList* list, DFLinkedList* listToAppend)
{
    if (list == NULL || NULL == list->data){
        return listToAppend;
    }
    DFLinkedList* first = list;
    DFLinkedList* curr = first;
    while (NULL != curr->next){
        curr = curr->next;
    }
    curr->next = listToAppend;
    return first;
}

int listSize(DFLinkedList*list)
{
    DFLinkedList* curr = list;
    int size = 0;
    while (NULL != curr->next){
        curr = curr->next;
        size++;
    }
    return size;
}
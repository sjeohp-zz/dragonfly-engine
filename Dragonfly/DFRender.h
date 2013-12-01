//
//  DFRender.h
//  Dragonfly
//
//  Created by Joseph on 25/11/13.
//  Copyright (c) 2013 Joseph Mark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "DFGameObject.h"
#import "DFRectangle.h"
#import "DFEllipse.h"
#import "DFTexture.h"
#import "DFUtil.h"

void DFRenderRectangle(DFRectangleData* rect, GLKBaseEffect* baseEffect);
void DFRenderEllipse(DFEllipseData* ellipse, GLKBaseEffect* baseEffect);
void DFRenderTexture(DFTextureData* texture, GLKBaseEffect* baseEffect);
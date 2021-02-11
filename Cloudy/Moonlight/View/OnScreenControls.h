//
//  OnScreenControls.h
//  Moonlight
//
//  Created by Diego Waxemberg on 12/28/14.
//  Copyright (c) 2014 Moonlight Stream. All rights reserved.
//

#ifdef NON_APPSTORE

#import <UIKit/UIKit.h>
#import "OnScreenControlsLevel.h"

@class ControllerSupport;
@protocol TouchFeedbackGenerator;
@protocol OnScreenControlsExtension;

@interface OnScreenControls : NSObject

    - (id)initWithView:(UIView *)view
          controllerSup:(ControllerSupport *)controllerSupport
          hapticFeedback:(id <TouchFeedbackGenerator>)hapticFeedbackDelegate
          extensionDelegate:(id <OnScreenControlsExtension>)extensionDelegate;

    - (BOOL)handleTouchDownEvent:(NSSet *)touches;

    - (BOOL)handleTouchUpEvent:(NSSet *)touches;

    - (BOOL)handleTouchMovedEvent:(NSSet *)touches;

    - (void)setLevel:(OnScreenControlsLevel)level;

    - (OnScreenControlsLevel)getLevel;

    - (void)show;

    - (void)cleanup;

    - (void)mixinControllerExtension:(bool)visible;

@end

#endif
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
@class Controller;
@protocol TouchFeedbackGenerator;

@protocol OnScreenControlsExtension

    - (void)drawButtonsIn:(CALayer *__nonnull)layer;

    - (BOOL)handleTouchMovedEvent:(UITouch *__nonnull)touch;

    - (BOOL)handleTouchUpEvent:(UITouch *__nonnull)touches
            controller:(Controller *__nonnull)controller
            controllerSupport:(ControllerSupport *__nonnull)controllerSupport;

    - (BOOL)handleTouchDownEvent:(UITouch *__nonnull)touch
            touchLocation:(CGPoint)touchLocation
            controller:(Controller *__nonnull)controller
            controllerSupport:(ControllerSupport *__nonnull)controllerSupport;

    // TODO fix this, its nasty
    - (void)hideAllHUDButtons;

    // TODO fix this, its nasty
    - (void)unhideAllHUDButtons;

@end

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

    // TODO fix this, its nasty
    - (void)hideAndDisableControllerButtons;

    // TODO fix this, its nasty
    - (void)showAndEnableControllerButtons;
@end

#endif
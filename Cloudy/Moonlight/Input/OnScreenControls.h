//
//  OnScreenControls.h
//  Moonlight
//
//  Created by Diego Waxemberg on 12/28/14.
//  Copyright (c) 2014 Moonlight Stream. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ControllerSupport;
@protocol TouchFeedbackGenerator;

@interface OnScreenControls : NSObject

    typedef NS_ENUM(NSInteger, OnScreenControlsLevel)
    {
        OnScreenControlsLevelOff,
        OnScreenControlsLevelSimple,
        OnScreenControlsLevelFull,

        OnScreenControlsLevelAuto,

        // Internal levels selected by ControllerSupport
        OnScreenControlsLevelAutoGCGamepad,
        OnScreenControlsLevelAutoGCExtendedGamepad,
        OnScreenControlsLevelAutoGCExtendedGamepadWithStickButtons
    };

    - (id)initWithView:(UIView *)view
          controllerSup:(ControllerSupport *)controllerSupport
          hapticFeedback:(id <TouchFeedbackGenerator>)hapticFeedbackDelegate;

    - (BOOL)handleTouchDownEvent:(NSSet *)touches;

    - (BOOL)handleTouchUpEvent:(NSSet *)touches;

    - (BOOL)handleTouchMovedEvent:(NSSet *)touches;

    - (void)setLevel:(OnScreenControlsLevel)level;

    - (OnScreenControlsLevel)getLevel;

    - (void)show;

@end

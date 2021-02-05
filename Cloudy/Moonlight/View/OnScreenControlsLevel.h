// Copyright (c) 2021 Nomad5. All rights reserved.

#import <Foundation/Foundation.h>

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
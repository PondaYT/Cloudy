//
//  ControllerSupport.h
//  Moonlight
//
//  Created by Cameron Gutman on 10/20/14.
//  Copyright (c) 2014 Moonlight Stream. All rights reserved.
//

#ifdef NON_APPSTORE

#import "InputPresenceDelegate.h"
#import "StreamConfiguration.h"
#import "Controller.h"

@class OnScreenControls;
@protocol ControllerDataReceiver;

@interface ControllerSupport : NSObject

    - (id)initWithConfig:(StreamConfiguration *)streamConfig presenceDelegate:(id <InputPresenceDelegate>)delegate controllerDataReceiver:(id <ControllerDataReceiver>)controllerDataReceiverDelegate;

    - (void)initAutoOnScreenControlMode:(OnScreenControls *)osc;

    - (void)cleanup;

    - (Controller *)getOscController;

    - (void)updateLeftStick:(Controller *)controller x:(short)x y:(short)y;

    - (void)updateRightStick:(Controller *)controller x:(short)x y:(short)y;

    - (void)updateLeftTrigger:(Controller *)controller left:(unsigned char)left;

    - (void)updateRightTrigger:(Controller *)controller right:(unsigned char)right;

    - (void)updateTriggers:(Controller *)controller left:(unsigned char)left right:(unsigned char)right;

    - (void)updateButtonFlags:(Controller *)controller flags:(int)flags;

    - (void)setButtonFlag:(Controller *)controller flags:(int)flags;

    - (void)clearButtonFlag:(Controller *)controller flags:(int)flags;

    - (void)updateFinished:(Controller *)controller;

    - (void)rumble:(unsigned short)controllerNumber lowFreqMotor:(unsigned short)lowFreqMotor highFreqMotor:(unsigned short)highFreqMotor;

    + (int)getConnectedGamepadMask:(StreamConfiguration *)streamConfig;

    - (NSUInteger)getConnectedGamepadCount;

@end

#endif
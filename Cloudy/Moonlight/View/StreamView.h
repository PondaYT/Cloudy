//
//  StreamView.h
//  Moonlight
//
//  Created by Cameron Gutman on 10/19/14.
//  Copyright (c) 2014 Moonlight Stream. All rights reserved.
//

#ifdef NON_APPSTORE

#import "UserInteractionDelegate.h"
#import "ControllerSupport.h"
#import "OnScreenControlsLevel.h"
#import "OnScreenControls.h"
#import "StreamConfiguration.h"

@protocol X1KitMouseDelegate;

#if TARGET_OS_TV
@interface StreamView : UIView <X1KitMouseDelegate, UITextFieldDelegate>
#else

@interface StreamView : UIView <X1KitMouseDelegate, UITextFieldDelegate, UIPointerInteractionDelegate>

#endif

    - (void)setupStreamView:(ControllerSupport *)controllerSupport
            interactionDelegate:(id <UserInteractionDelegate>)interactionDelegate
            config:(StreamConfiguration *)streamConfig
            hapticFeedback:(id <TouchFeedbackGenerator>)hapticFeedbackDelegate
            extensionDelegate:(id <OnScreenControlsExtension>)extensionDelegate;

    - (void)showOnScreenControls;

    - (void)updateOnScreenControls;

    - (OnScreenControlsLevel)getCurrentOscState;

    - (void)cleanup;

    // TODO fix this, its nasty
    - (void)hideControllerButtons;

    // TODO fix this, its nasty
    - (void)showControllerButtons;

#if !TARGET_OS_TV

    - (void)updateCursorLocation:(CGPoint)location isMouse:(BOOL)isMouse;

#endif

@end

#endif
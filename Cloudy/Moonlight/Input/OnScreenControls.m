//
//  OnScreenControls.m
//  Moonlight
//
//  Created by Diego Waxemberg on 12/28/14.
//  Copyright (c) 2014 Moonlight Stream. All rights reserved.
//

#import "OnScreenControls.h"
#import "StreamView.h"
#import "ControllerSupport.h"
#import "Controller.h"
#include "Limelight.h"
#import "Log.h"

#define CLAMP(VAL) MAX(-1.0, MIN(1.0, VAL))
#define NO_ANIM(VAL) \
        [CATransaction begin]; \
        [CATransaction setValue:(id) kCFBooleanTrue forKey:kCATransactionDisableActions]; \
        VAL; \
        [CATransaction commit]; \

#define UPDATE_BUTTON(x, y) (buttonFlags = \
(y) ? (buttonFlags | (x)) : (buttonFlags & ~(x)))

@implementation OnScreenControls
    {
        CALayer *_aButton;
        CALayer *_bButton;
        CALayer *_xButton;
        CALayer *_yButton;
        CALayer *_upButton;
        CALayer *_downButton;
        CALayer *_leftButton;
        CALayer *_rightButton;
        CALayer *_leftStickBackground;
        CALayer *_leftStick;
        CALayer *_rightStickBackground;
        CALayer *_rightStick;
        CALayer *_startButton;
        CALayer *_selectButton;
        CALayer *_homeButton;
        CALayer *_r1Button;
        CALayer *_r2Button;
        CALayer *_r3Button;
        CALayer *_l1Button;
        CALayer *_l2Button;
        CALayer *_l3Button;

        UITouch *_aTouch;
        UITouch *_bTouch;
        UITouch *_xTouch;
        UITouch *_yTouch;
        UITouch *_dpadTouch;
        UITouch *_lsTouch;
        CGPoint _lsTouchStart;
        UITouch *_rsTouch;
        CGPoint _rsTouchStart;
        UITouch *_startTouch;
        UITouch *_selectTouch;
        UITouch *_homeTouch;
        UITouch *_r1Touch;
        UITouch *_r2Touch;
        UITouch *_r3Touch;
        UITouch *_l1Touch;
        UITouch *_l2Touch;
        UITouch *_l3Touch;
        
        CALayer *Aim;
        CALayer *Autorun;
        CALayer *Confirm;
        CALayer *Crouch_Down;
        CALayer *Crouch_Up;
        CALayer *Cycle_Weapons_Down;
        CALayer *Cycle_Weapons_Up;
        CALayer *Edit_Crosshair;
        CALayer *Edit_Reset;
        CALayer *Edit;
        CALayer *Emote_Wheel;
        CALayer *Exit;
        CALayer *Floor_Selected;
        CALayer *Floor_Unselected;
        CALayer *Inventory;
        CALayer *Jump;
        CALayer *Mic_Muted;
        CALayer *Mic_Unmuted;
        CALayer *Move_Joystick;
        CALayer *Move_Outer;
        CALayer *Open_Chest;
        CALayer *Open_Door;
        CALayer *Ping;
        CALayer *Pyramid_Selected;
        CALayer *Pyramid_Unselected;
        CALayer *Quick_Chat;
        CALayer *Quick_Heal;
        CALayer *Repair;
        CALayer *Reset;
        CALayer *Rotate;
        CALayer *Shoot_Big;
        CALayer *Shoot;
        CALayer *Stair_Selected;
        CALayer *Stair_Unselected;
        CALayer *Switch_To_Build;
        CALayer *Switch_To_Combat;
        CALayer *Throw;
        CALayer *Use;
        CALayer *Wall_Selected;
        CALayer *Wall_Unselected;
        
        UITouch *AimTouch;
        UITouch *AutorunTouch;
        UITouch *ConfirmTouch;
        UITouch *Crouch_DownTouch;
        UITouch *Crouch_UpTouch;
        UITouch *Cycle_Weapons_DownTouch;
        UITouch *Cycle_Weapons_UpTouch;
        UITouch *Edit_CrosshairTouch;
        UITouch *Edit_ResetTouch;
        UITouch *EditTouch;
        UITouch *Emote_WheelTouch;
        UITouch *ExitTouch;
        UITouch *Floor_SelectedTouch;
        UITouch *Floor_UnselectedTouch;
        UITouch *InventoryTouch;
        UITouch *JumpTouch;
        UITouch *Mic_MutedTouch;
        UITouch *Mic_UnmutedTouch;
        UITouch *Move_JoystickTouch;
        UITouch *Move_OuterTouch;
        UITouch *Open_ChestTouch;
        UITouch *Open_DoorTouch;
        UITouch *PingTouch;
        UITouch *Pyramid_SelectedTouch;
        UITouch *Pyramid_UnselectedTouch;
        UITouch *Quick_ChatTouch;
        UITouch *Quick_HealTouch;
        UITouch *RepairTouch;
        UITouch *ResetTouch;
        UITouch *RotateTouch;
        UITouch *Shoot_BigTouch;
        UITouch *ShootTouch;
        UITouch *Stair_SelectedTouch;
        UITouch *Stair_UnselectedTouch;
        UITouch *Switch_To_BuildTouch;
        UITouch *Switch_To_CombatTouch;
        UITouch *ThrowTouch;
        UITouch *UseTouch;
        UITouch *Wall_SelectedTouch;
        UITouch *Wall_UnselectedTouch;

        NSDate *l3TouchStart;
        NSDate *r3TouchStart;

        BOOL l3Set;
        BOOL r3Set;

        BOOL                  _iPad;
        CGRect                _controlArea;
        UIView                *_view;
        OnScreenControlsLevel _level;
        BOOL                  _visible;

        ControllerSupport *_controllerSupport;
        Controller        *_controller;
        NSMutableArray    *_deadTouches;

        id <TouchFeedbackGenerator> hapticFeedback;
    }

    static const float EDGE_WIDTH = .05;

    //static const float BUTTON_SIZE = 50;
    static const float BUTTON_DIST = 20;
    static float       BUTTON_CENTER_X;
    static float       BUTTON_CENTER_Y;

    static const float D_PAD_DIST = 10;
    static float       D_PAD_CENTER_X;
    static float       D_PAD_CENTER_Y;

    static const float DEAD_ZONE_PADDING = 15;

    static const double STICK_CLICK_RATE = 100;
    static const float  STICK_DEAD_ZONE  = .1;
    static float        STICK_INNER_SIZE;
    static float        STICK_OUTER_SIZE;
    static float        LS_CENTER_X;
    static float        LS_CENTER_Y;
    static float        RS_CENTER_X;
    static float        RS_CENTER_Y;

    static float START_X;
    static float START_Y;

    static float SELECT_X;
    static float SELECT_Y;

    static float HOME_X;
    static float HOME_Y;

    static float R1_X;
    static float R1_Y;
    static float R2_X;
    static float R2_Y;
    static float R3_X;
    static float R3_Y;
    static float L1_X;
    static float L1_Y;
    static float L2_X;
    static float L2_Y;
    static float L3_X;
    static float L3_Y;

    - (id)initWithView:(UIView *)view
          controllerSup:(ControllerSupport *)controllerSupport
          hapticFeedback:(id <TouchFeedbackGenerator>)hapticFeedbackDelegate
    {
        self                  = [self init];
        _view                 = view;
        _controllerSupport = controllerSupport;
        _controller        = [controllerSupport getOscController];
        _deadTouches       = [[NSMutableArray alloc] init];
        hapticFeedback     = hapticFeedbackDelegate;

        _iPad        = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad);
        _controlArea = CGRectMake(0, 0, _view.frame.size.width, _view.frame.size.height);
        if(_iPad)
        {
            // Cut down the control area on an iPad so the controls are more reachable
            _controlArea.size.height = _view.frame.size.height / 2.0;
            _controlArea.origin.y    = _view.frame.size.height - _controlArea.size.height;
        }
        else
        {
            _controlArea.origin.x = _controlArea.size.width * EDGE_WIDTH;
            _controlArea.size.width -= _controlArea.origin.x * 2;
        }

        _aButton              = [CALayer layer];
        _bButton              = [CALayer layer];
        _xButton              = [CALayer layer];
        _yButton              = [CALayer layer];
        _upButton             = [CALayer layer];
        _downButton           = [CALayer layer];
        _leftButton           = [CALayer layer];
        _rightButton          = [CALayer layer];
        _l1Button             = [CALayer layer];
        _r1Button             = [CALayer layer];
        _l2Button             = [CALayer layer];
        _r2Button             = [CALayer layer];
        _l3Button             = [CALayer layer];
        _r3Button             = [CALayer layer];
        _startButton          = [CALayer layer];
        _selectButton         = [CALayer layer];
        _homeButton           = [CALayer layer];
        _leftStickBackground  = [CALayer layer];
        _rightStickBackground = [CALayer layer];
        _leftStick            = [CALayer layer];
        _rightStick           = [CALayer layer];

        return self;
    }

    - (void)cleanup
    {
        [_controllerSupport cleanup];
        _controllerSupport = nil;
        _controller        = nil;
    }

    - (void)show
    {
        _visible = YES;

        [self updateControls];
    }

    - (void)setLevel:(OnScreenControlsLevel)level
    {
        _level = level;

        // Only update controls if we're showing, otherwise
        // show will do it for us.
        if(_visible)
        {
            [self updateControls];
        }
    }

    - (OnScreenControlsLevel)getLevel
    {
        return _level;
    }

    - (void)updateControls
    {
        switch(_level)
        {
            case OnScreenControlsLevelOff:
                [self hideButtons];
                [self hideBumpers];
                [self hideTriggers];
                [self hideStartSelectHome];
                [self hideSticks];
                [self hideL3R3];
                break;
            case OnScreenControlsLevelAutoGCGamepad:
                // GCGamepad is missing triggers, both analog sticks,
                // and the select button
                [self setupGamepadControls];

                [self hideButtons];
                [self hideBumpers];
                [self hideL3R3];
                [self drawTriggers];
                [self drawStartSelectHome];
                [self drawSticks];
                break;
            case OnScreenControlsLevelAutoGCExtendedGamepad:
                // GCExtendedGamepad is missing R3, L3, and select
                [self setupExtendedGamepadControls];

                [self hideButtons];
                [self hideBumpers];
                [self hideTriggers];
                [self drawStartSelectHome];
                [self hideSticks];
                [self drawL3R3];
                break;
            case OnScreenControlsLevelAutoGCExtendedGamepadWithStickButtons:
                // This variant of GCExtendedGamepad has L3 and R3 but
                // is still missing Select
                [self setupExtendedGamepadControls];

                [self hideButtons];
                [self hideBumpers];
                [self hideTriggers];
                [self hideL3R3];
                [self drawStartSelectHome];
                [self hideSticks];
                break;
            case OnScreenControlsLevelSimple:
                [self setupSimpleControls];

                [self hideTriggers];
                [self hideL3R3];
                [self hideBumpers];
                [self hideSticks];
                [self drawStartSelectHome];
                [self drawButtons];
                break;
            case OnScreenControlsLevelFull:
                [self setupComplexControls];

                [self drawButtons];
                [self drawStartSelectHome];
                [self drawBumpers];
                [self drawTriggers];
                [self drawSticks];
                [self hideL3R3]; // Full controls don't need these they have the sticks
                break;
            default:
                LogE(@"Unknown on-screen controls level: %d", (int) _level);
                break;
        }
    }

    // For GCExtendedGamepad controls we move start, select, L3, and R3 to the button
    - (void)setupExtendedGamepadControls
    {
        // Start with the default complex layout
        [self setupComplexControls];

        START_X  = _controlArea.size.width * .95 + _controlArea.origin.x;
        START_Y  = _controlArea.size.height * .9 + _controlArea.origin.y;
        SELECT_X = _controlArea.size.width * .05 + _controlArea.origin.x;
        SELECT_Y = _controlArea.size.height * .9 + _controlArea.origin.y;
        HOME_X   = _controlArea.size.width * .5 + _controlArea.origin.x;
        HOME_Y   = _controlArea.size.height * .9 + _controlArea.origin.y;

        L3_Y = _controlArea.size.height * .85 + _controlArea.origin.y;
        R3_Y = _controlArea.size.height * .85 + _controlArea.origin.y;

        if(_iPad)
        {
            L3_X = _controlArea.size.width * .15 + _controlArea.origin.x;
            R3_X = _controlArea.size.width * .85 + _controlArea.origin.x;
        }
        else
        {
            L3_X = _controlArea.size.width * .25 + _controlArea.origin.x;
            R3_X = _controlArea.size.width * .75 + _controlArea.origin.x;
        }
    }

    // For GCGamepad controls we move triggers, start, and select
    // to sit right above the analog sticks
    - (void)setupGamepadControls
    {
        // Start with the default complex layout
        [self setupComplexControls];

        L2_Y = _controlArea.size.height * .75 + _controlArea.origin.y;
        L2_X = _controlArea.size.width * .05 + _controlArea.origin.x;

        R2_Y = _controlArea.size.height * .75 + _controlArea.origin.y;
        R2_X = _controlArea.size.width * .95 + _controlArea.origin.x;

        START_X  = _controlArea.size.width * .95 + _controlArea.origin.x;
        START_Y  = _controlArea.size.height * .95 + _controlArea.origin.y;
        SELECT_X = _controlArea.size.width * .05 + _controlArea.origin.x;
        SELECT_Y = _controlArea.size.height * .95 + _controlArea.origin.y;
        HOME_X   = _controlArea.size.width * .5 + _controlArea.origin.x;
        HOME_Y   = _controlArea.size.height * .9 + _controlArea.origin.y;

        if(_iPad)
        {
            // The analog sticks are kept closer to the sides on iPad
            LS_CENTER_X = _controlArea.size.width * .15 + _controlArea.origin.x;
            RS_CENTER_X = _controlArea.size.width * .85 + _controlArea.origin.x;
        }
    }

    // For simple controls we move the triggers and buttons to the bottom
    - (void)setupSimpleControls
    {
        // Start with the default complex layout
        [self setupComplexControls];

        START_Y  = _controlArea.size.height * .9 + _controlArea.origin.y;
        SELECT_Y = _controlArea.size.height * .9 + _controlArea.origin.y;
        HOME_X   = _controlArea.size.width * .5 + _controlArea.origin.x;
        HOME_Y   = _controlArea.size.height * .9 + _controlArea.origin.y;

        L2_Y = _controlArea.size.height * .9 + _controlArea.origin.y;
        L2_X = _controlArea.size.width * .1 + _controlArea.origin.x;

        R2_Y = _controlArea.size.height * .9 + _controlArea.origin.y;
        R2_X = _controlArea.size.width * .9 + _controlArea.origin.x;

        if(_iPad)
        {
            // Lower the D-pad and buttons on iPad
            D_PAD_CENTER_Y  = _controlArea.size.height * .75 + _controlArea.origin.y;
            BUTTON_CENTER_Y = _controlArea.size.height * .75 + _controlArea.origin.y;

            // Move Start and Select closer to sides
            SELECT_X = _controlArea.size.width * .2 + _controlArea.origin.x;
            START_X  = _controlArea.size.width * .8 + _controlArea.origin.x;
        }
        else
        {
            SELECT_X = _controlArea.size.width * .4 + _controlArea.origin.x;
            START_X  = _controlArea.size.width * .6 + _controlArea.origin.x;
        }
    }

    - (void)setupComplexControls
    {
        D_PAD_CENTER_X  = _controlArea.size.width * .1 + _controlArea.origin.x;
        D_PAD_CENTER_Y  = _controlArea.size.height * .60 + _controlArea.origin.y;
        BUTTON_CENTER_X = _controlArea.size.width * .9 + _controlArea.origin.x;
        BUTTON_CENTER_Y = _controlArea.size.height * .60 + _controlArea.origin.y;

        if(_iPad)
        {
            // The analog sticks are kept closer to the sides on iPad
            LS_CENTER_X = _controlArea.size.width * .22 + _controlArea.origin.x;
            LS_CENTER_Y = _controlArea.size.height * .80 + _controlArea.origin.y;
            RS_CENTER_X = _controlArea.size.width * .77 + _controlArea.origin.x;
            RS_CENTER_Y = _controlArea.size.height * .80 + _controlArea.origin.y;
        }
        else
        {
            LS_CENTER_X = _controlArea.size.width * .35 + _controlArea.origin.x;
            LS_CENTER_Y = _controlArea.size.height * .75 + _controlArea.origin.y;
            RS_CENTER_X = _controlArea.size.width * .65 + _controlArea.origin.x;
            RS_CENTER_Y = _controlArea.size.height * .75 + _controlArea.origin.y;
        }

        START_X  = _controlArea.size.width * .9 + _controlArea.origin.x;
        START_Y  = _controlArea.size.height * .9 + _controlArea.origin.y;
        SELECT_X = _controlArea.size.width * .1 + _controlArea.origin.x;
        SELECT_Y = _controlArea.size.height * .9 + _controlArea.origin.y;
        HOME_X   = _controlArea.size.width * .5 + _controlArea.origin.x;
        HOME_Y   = _controlArea.size.height * .9 + _controlArea.origin.y;

        L1_Y = _controlArea.size.height * .27 + _controlArea.origin.y;
        L2_Y = _controlArea.size.height * .1 + _controlArea.origin.y;
        R1_Y = _controlArea.size.height * .27 + _controlArea.origin.y;
        R2_Y = _controlArea.size.height * .1 + _controlArea.origin.y;

        if(_iPad)
        {
            // Move L/R buttons closer to the side on iPad
            L1_X = _controlArea.size.width * .05 + _controlArea.origin.x;
            L2_X = _controlArea.size.width * .05 + _controlArea.origin.x;
            R1_X = _controlArea.size.width * .95 + _controlArea.origin.x;
            R2_X = _controlArea.size.width * .95 + _controlArea.origin.x;
        }
        else
        {
            L1_X = _controlArea.size.width * .1 + _controlArea.origin.x;
            L2_X = _controlArea.size.width * .1 + _controlArea.origin.x;
            R1_X = _controlArea.size.width * .9 + _controlArea.origin.x;
            R2_X = _controlArea.size.width * .9 + _controlArea.origin.x;
        }
    }

    - (void)drawButtons
    {
        // create A button
        UIImage *aButtonImage = [UIImage imageNamed:@"AButton"];
        _aButton.contents = (id) aButtonImage.CGImage;
        _aButton.frame    = CGRectMake(BUTTON_CENTER_X - aButtonImage.size.width / 2, BUTTON_CENTER_Y + BUTTON_DIST, aButtonImage.size.width, aButtonImage.size.height);
        [_view.layer addSublayer:_aButton];

        // create B button
        UIImage *bButtonImage = [UIImage imageNamed:@"BButton"];
        _bButton.frame    = CGRectMake(BUTTON_CENTER_X + BUTTON_DIST, BUTTON_CENTER_Y - bButtonImage.size.height / 2, bButtonImage.size.width, bButtonImage.size.height);
        _bButton.contents = (id) bButtonImage.CGImage;
        [_view.layer addSublayer:_bButton];

        // create X Button
        UIImage *xButtonImage = [UIImage imageNamed:@"XButton"];
        _xButton.frame    = CGRectMake(BUTTON_CENTER_X - BUTTON_DIST - xButtonImage.size.width, BUTTON_CENTER_Y - xButtonImage.size.height / 2, xButtonImage.size.width, xButtonImage.size.height);
        _xButton.contents = (id) xButtonImage.CGImage;
        [_view.layer addSublayer:_xButton];

        // create Y Button
        UIImage *yButtonImage = [UIImage imageNamed:@"YButton"];
        _yButton.frame    = CGRectMake(BUTTON_CENTER_X - yButtonImage.size.width / 2, BUTTON_CENTER_Y - BUTTON_DIST - yButtonImage.size.height, yButtonImage.size.width, yButtonImage.size.height);
        _yButton.contents = (id) yButtonImage.CGImage;
        [_view.layer addSublayer:_yButton];

        // create Down button
        UIImage *downButtonImage = [UIImage imageNamed:@"DownButton"];
        _downButton.frame    = CGRectMake(D_PAD_CENTER_X - downButtonImage.size.width / 2, D_PAD_CENTER_Y + D_PAD_DIST, downButtonImage.size.width, downButtonImage.size.height);
        _downButton.contents = (id) downButtonImage.CGImage;
        [_view.layer addSublayer:_downButton];

        // create Right button
        UIImage *rightButtonImage = [UIImage imageNamed:@"RightButton"];
        _rightButton.frame    = CGRectMake(D_PAD_CENTER_X + D_PAD_DIST, D_PAD_CENTER_Y - rightButtonImage.size.height / 2, rightButtonImage.size.width, rightButtonImage.size.height);
        _rightButton.contents = (id) rightButtonImage.CGImage;
        [_view.layer addSublayer:_rightButton];

        // create Up button
        UIImage *upButtonImage = [UIImage imageNamed:@"UpButton"];
        _upButton.frame    = CGRectMake(D_PAD_CENTER_X - upButtonImage.size.width / 2, D_PAD_CENTER_Y - D_PAD_DIST - upButtonImage.size.height, upButtonImage.size.width, upButtonImage.size.height);
        _upButton.contents = (id) upButtonImage.CGImage;
        [_view.layer addSublayer:_upButton];

        // create Left button
        UIImage *leftButtonImage = [UIImage imageNamed:@"LeftButton"];
        _leftButton.frame    = CGRectMake(D_PAD_CENTER_X - D_PAD_DIST - leftButtonImage.size.width, D_PAD_CENTER_Y - leftButtonImage.size.height / 2, leftButtonImage.size.width, leftButtonImage.size.height);
        _leftButton.contents = (id) leftButtonImage.CGImage;
        [_view.layer addSublayer:_leftButton];
        
        NSInteger i = 0;
        
        NSArray *HUDCombatButtonXSaved = [[NSUserDefaults standardUserDefaults] objectForKey:@"reKairosCombatHUDRectX"];
        NSArray *HUDCombatButtonYSaved = [[NSUserDefaults standardUserDefaults] objectForKey:@"reKairosCombatHUDRectY"];
        NSArray *HUDCombatButtonWidthSaved = [[NSUserDefaults standardUserDefaults] objectForKey:@"reKairosCombatHUDRectWidth"];
        NSArray *HUDCombatButtonHeightSaved = [[NSUserDefaults standardUserDefaults] objectForKey:@"reKairosCombatHUDRectHeight"];
        
        Aim = [CALayer layer];
        Autorun = [CALayer layer];
        Confirm = [CALayer layer];
        Crouch_Down = [CALayer layer];
        Crouch_Up = [CALayer layer];
        Cycle_Weapons_Down = [CALayer layer];
        Cycle_Weapons_Up = [CALayer layer];
        Edit_Crosshair = [CALayer layer];
        Edit_Reset = [CALayer layer];
        Edit = [CALayer layer];
        Emote_Wheel = [CALayer layer];
        Exit = [CALayer layer];
        Floor_Selected = [CALayer layer];
        Floor_Unselected = [CALayer layer];
        Inventory = [CALayer layer];
        Jump = [CALayer layer];
        Mic_Muted = [CALayer layer];
        Mic_Unmuted = [CALayer layer];
        Move_Joystick = [CALayer layer];
        Move_Outer = [CALayer layer];
        Open_Chest = [CALayer layer];
        Open_Door = [CALayer layer];
        Ping = [CALayer layer];
        Pyramid_Selected = [CALayer layer];
        Pyramid_Unselected = [CALayer layer];
        Quick_Chat = [CALayer layer];
        Quick_Heal = [CALayer layer];
        Repair = [CALayer layer];
        Reset = [CALayer layer];
        Rotate = [CALayer layer];
        Shoot_Big = [CALayer layer];
        Shoot = [CALayer layer];
        Stair_Selected = [CALayer layer];
        Stair_Unselected = [CALayer layer];
        Switch_To_Build = [CALayer layer];
        Switch_To_Combat = [CALayer layer];
        Throw = [CALayer layer];
        Use = [CALayer layer];
        Wall_Selected = [CALayer layer];
        Wall_Unselected = [CALayer layer];

        
        UIImage *AimImage = [self imageWithImage:[UIImage imageNamed: @"Aim.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:0] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:0] floatValue])];
        Aim.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:0] floatValue], [[HUDCombatButtonYSaved objectAtIndex:0] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:0] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:0] floatValue]);
        Aim.contents = (id) AimImage.CGImage;
        [_view.layer addSublayer:Aim];

        UIImage *AutorunImage = [self imageWithImage:[UIImage imageNamed: @"Autorun.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:1] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:1] floatValue])];
        Autorun.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:1] floatValue], [[HUDCombatButtonYSaved objectAtIndex:1] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:1] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:1] floatValue]);
        Autorun.contents = (id) AutorunImage.CGImage;
        [_view.layer addSublayer:Autorun];

        UIImage *ConfirmImage = [self imageWithImage:[UIImage imageNamed: @"Confirm.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:2] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:2] floatValue])];
        Confirm.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:2] floatValue], [[HUDCombatButtonYSaved objectAtIndex:2] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:2] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:2] floatValue]);
        Confirm.contents = (id) ConfirmImage.CGImage;
        [_view.layer addSublayer:Confirm];

        UIImage *Crouch_DownImage = [self imageWithImage:[UIImage imageNamed: @"Crouch Down.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:3] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:3] floatValue])];
        Crouch_Down.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:3] floatValue], [[HUDCombatButtonYSaved objectAtIndex:3] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:3] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:3] floatValue]);
        Crouch_Down.contents = (id) Crouch_DownImage.CGImage;
        [_view.layer addSublayer:Crouch_Down];

        UIImage *Crouch_UpImage = [self imageWithImage:[UIImage imageNamed: @"Crouch Up.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:4] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:4] floatValue])];
        Crouch_Up.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:4] floatValue], [[HUDCombatButtonYSaved objectAtIndex:4] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:4] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:4] floatValue]);
        Crouch_Up.contents = (id) Crouch_UpImage.CGImage;
        [_view.layer addSublayer:Crouch_Up];

        UIImage *Cycle_Weapons_DownImage = [self imageWithImage:[UIImage imageNamed: @"Cycle Weapons Down.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:5] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:5] floatValue])];
        Cycle_Weapons_Down.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:5] floatValue], [[HUDCombatButtonYSaved objectAtIndex:5] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:5] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:5] floatValue]);
        Cycle_Weapons_Down.contents = (id) Cycle_Weapons_DownImage.CGImage;
        [_view.layer addSublayer:Cycle_Weapons_Down];

        UIImage *Cycle_Weapons_UpImage = [self imageWithImage:[UIImage imageNamed: @"Cycle Weapons Up.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:6] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:6] floatValue])];
        Cycle_Weapons_Up.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:6] floatValue], [[HUDCombatButtonYSaved objectAtIndex:6] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:6] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:6] floatValue]);
        Cycle_Weapons_Up.contents = (id) Cycle_Weapons_UpImage.CGImage;
        [_view.layer addSublayer:Cycle_Weapons_Up];

        UIImage *Edit_CrosshairImage = [self imageWithImage:[UIImage imageNamed: @"Edit Crosshair.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:7] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:7] floatValue])];
        Edit_Crosshair.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:7] floatValue], [[HUDCombatButtonYSaved objectAtIndex:7] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:7] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:7] floatValue]);
        Edit_Crosshair.contents = (id) Edit_CrosshairImage.CGImage;
        [_view.layer addSublayer:Edit_Crosshair];

        UIImage *Edit_ResetImage = [self imageWithImage:[UIImage imageNamed: @"Edit Reset.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:8] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:8] floatValue])];
        Edit_Reset.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:8] floatValue], [[HUDCombatButtonYSaved objectAtIndex:8] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:8] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:8] floatValue]);
        Edit_Reset.contents = (id) Edit_ResetImage.CGImage;
        [_view.layer addSublayer:Edit_Reset];

        UIImage *EditImage = [self imageWithImage:[UIImage imageNamed: @"Edit.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:9] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:9] floatValue])];
        Edit.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:9] floatValue], [[HUDCombatButtonYSaved objectAtIndex:9] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:9] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:9] floatValue]);
        Edit.contents = (id) EditImage.CGImage;
        [_view.layer addSublayer:Edit];

        UIImage *Emote_WheelImage = [self imageWithImage:[UIImage imageNamed: @"Emote Wheel.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:10] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:10] floatValue])];
        Emote_Wheel.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:10] floatValue], [[HUDCombatButtonYSaved objectAtIndex:10] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:10] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:10] floatValue]);
        Emote_Wheel.contents = (id) Emote_WheelImage.CGImage;
        [_view.layer addSublayer:Emote_Wheel];

        UIImage *ExitImage = [self imageWithImage:[UIImage imageNamed: @"Exit.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:11] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:11] floatValue])];
        Exit.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:11] floatValue], [[HUDCombatButtonYSaved objectAtIndex:11] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:11] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:11] floatValue]);
        Exit.contents = (id) ExitImage.CGImage;
        [_view.layer addSublayer:Exit];

        UIImage *Floor_SelectedImage = [self imageWithImage:[UIImage imageNamed: @"Floor Selected.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:12] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:12] floatValue])];
        Floor_Selected.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:12] floatValue], [[HUDCombatButtonYSaved objectAtIndex:12] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:12] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:12] floatValue]);
        Floor_Selected.contents = (id) Floor_SelectedImage.CGImage;
        [_view.layer addSublayer:Floor_Selected];

        UIImage *Floor_UnselectedImage = [self imageWithImage:[UIImage imageNamed: @"Floor Unselected.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:13] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:13] floatValue])];
        Floor_Unselected.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:13] floatValue], [[HUDCombatButtonYSaved objectAtIndex:13] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:13] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:13] floatValue]);
        Floor_Unselected.contents = (id) Floor_UnselectedImage.CGImage;
        [_view.layer addSublayer:Floor_Unselected];

        UIImage *InventoryImage = [self imageWithImage:[UIImage imageNamed: @"Inventory.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:14] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:14] floatValue])];
        Inventory.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:14] floatValue], [[HUDCombatButtonYSaved objectAtIndex:14] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:14] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:14] floatValue]);
        Inventory.contents = (id) InventoryImage.CGImage;
        [_view.layer addSublayer:Inventory];

        UIImage *JumpImage = [self imageWithImage:[UIImage imageNamed: @"Jump.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:15] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:15] floatValue])];
        Jump.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:15] floatValue], [[HUDCombatButtonYSaved objectAtIndex:15] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:15] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:15] floatValue]);
        Jump.contents = (id) JumpImage.CGImage;
        [_view.layer addSublayer:Jump];

        UIImage *Mic_MutedImage = [self imageWithImage:[UIImage imageNamed: @"Mic Muted.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:16] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:16] floatValue])];
        Mic_Muted.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:16] floatValue], [[HUDCombatButtonYSaved objectAtIndex:16] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:16] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:16] floatValue]);
        Mic_Muted.contents = (id) Mic_MutedImage.CGImage;
        [_view.layer addSublayer:Mic_Muted];

        UIImage *Mic_UnmutedImage = [self imageWithImage:[UIImage imageNamed: @"Mic Unmuted.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:17] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:17] floatValue])];
        Mic_Unmuted.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:17] floatValue], [[HUDCombatButtonYSaved objectAtIndex:17] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:17] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:17] floatValue]);
        Mic_Unmuted.contents = (id) Mic_UnmutedImage.CGImage;
        [_view.layer addSublayer:Mic_Unmuted];

        UIImage *Move_JoystickImage = [self imageWithImage:[UIImage imageNamed: @"Move Joystick.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:18] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:18] floatValue])];
        Move_Joystick.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:18] floatValue], [[HUDCombatButtonYSaved objectAtIndex:18] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:18] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:18] floatValue]);
        Move_Joystick.contents = (id) Move_JoystickImage.CGImage;
        [_view.layer addSublayer:Move_Joystick];

        UIImage *Move_OuterImage = [self imageWithImage:[UIImage imageNamed: @"Move Outer.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:19] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:19] floatValue])];
        Move_Outer.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:19] floatValue], [[HUDCombatButtonYSaved objectAtIndex:19] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:19] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:19] floatValue]);
        Move_Outer.contents = (id) Move_OuterImage.CGImage;
        [_view.layer addSublayer:Move_Outer];

        UIImage *Open_ChestImage = [self imageWithImage:[UIImage imageNamed: @"Open Chest.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:20] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:20] floatValue])];
        Open_Chest.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:20] floatValue], [[HUDCombatButtonYSaved objectAtIndex:20] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:20] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:20] floatValue]);
        Open_Chest.contents = (id) Open_ChestImage.CGImage;
        [_view.layer addSublayer:Open_Chest];

        UIImage *Open_DoorImage = [self imageWithImage:[UIImage imageNamed: @"Open Door.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:21] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:21] floatValue])];
        Open_Door.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:21] floatValue], [[HUDCombatButtonYSaved objectAtIndex:21] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:21] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:21] floatValue]);
        Open_Door.contents = (id) Open_DoorImage.CGImage;
        [_view.layer addSublayer:Open_Door];

        UIImage *PingImage = [self imageWithImage:[UIImage imageNamed: @"Ping.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:22] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:22] floatValue])];
        Ping.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:22] floatValue], [[HUDCombatButtonYSaved objectAtIndex:22] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:22] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:22] floatValue]);
        Ping.contents = (id) PingImage.CGImage;
        [_view.layer addSublayer:Ping];

        UIImage *Pyramid_SelectedImage = [self imageWithImage:[UIImage imageNamed: @"Pyramid Selected.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:23] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:23] floatValue])];
        Pyramid_Selected.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:23] floatValue], [[HUDCombatButtonYSaved objectAtIndex:23] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:23] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:23] floatValue]);
        Pyramid_Selected.contents = (id) Pyramid_SelectedImage.CGImage;
        [_view.layer addSublayer:Pyramid_Selected];

        UIImage *Pyramid_UnselectedImage = [self imageWithImage:[UIImage imageNamed: @"Pyramid Unselected.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:24] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:24] floatValue])];
        Pyramid_Unselected.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:24] floatValue], [[HUDCombatButtonYSaved objectAtIndex:24] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:24] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:24] floatValue]);
        Pyramid_Unselected.contents = (id) Pyramid_UnselectedImage.CGImage;
        [_view.layer addSublayer:Pyramid_Unselected];

        UIImage *Quick_ChatImage = [self imageWithImage:[UIImage imageNamed: @"Quick Chat.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:25] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:25] floatValue])];
        Quick_Chat.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:25] floatValue], [[HUDCombatButtonYSaved objectAtIndex:25] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:25] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:25] floatValue]);
        Quick_Chat.contents = (id) Quick_ChatImage.CGImage;
        [_view.layer addSublayer:Quick_Chat];

        UIImage *Quick_HealImage = [self imageWithImage:[UIImage imageNamed: @"Quick Heal.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:26] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:26] floatValue])];
        Quick_Heal.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:26] floatValue], [[HUDCombatButtonYSaved objectAtIndex:26] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:26] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:26] floatValue]);
        Quick_Heal.contents = (id) Quick_HealImage.CGImage;
        [_view.layer addSublayer:Quick_Heal];

        UIImage *RepairImage = [self imageWithImage:[UIImage imageNamed: @"Repair.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:27] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:27] floatValue])];
        Repair.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:27] floatValue], [[HUDCombatButtonYSaved objectAtIndex:27] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:27] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:27] floatValue]);
        Repair.contents = (id) RepairImage.CGImage;
        [_view.layer addSublayer:Repair];

        UIImage *ResetImage = [self imageWithImage:[UIImage imageNamed: @"Reset.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:28] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:28] floatValue])];
        Reset.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:28] floatValue], [[HUDCombatButtonYSaved objectAtIndex:28] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:28] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:28] floatValue]);
        Reset.contents = (id) ResetImage.CGImage;
        [_view.layer addSublayer:Reset];

        UIImage *RotateImage = [self imageWithImage:[UIImage imageNamed: @"Rotate.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:29] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:29] floatValue])];
        Rotate.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:29] floatValue], [[HUDCombatButtonYSaved objectAtIndex:29] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:29] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:29] floatValue]);
        Rotate.contents = (id) RotateImage.CGImage;
        [_view.layer addSublayer:Rotate];

        UIImage *Shoot_BigImage = [self imageWithImage:[UIImage imageNamed: @"Shoot Big.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:30] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:30] floatValue])];
        Shoot_Big.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:30] floatValue], [[HUDCombatButtonYSaved objectAtIndex:30] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:30] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:30] floatValue]);
        Shoot_Big.contents = (id) Shoot_BigImage.CGImage;
        [_view.layer addSublayer:Shoot_Big];

        UIImage *ShootImage = [self imageWithImage:[UIImage imageNamed: @"Shoot.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:31] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:31] floatValue])];
        Shoot.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:31] floatValue], [[HUDCombatButtonYSaved objectAtIndex:31] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:31] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:31] floatValue]);
        Shoot.contents = (id) ShootImage.CGImage;
        [_view.layer addSublayer:Shoot];

        UIImage *Stair_SelectedImage = [self imageWithImage:[UIImage imageNamed: @"Stair Selected.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:32] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:32] floatValue])];
        Stair_Selected.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:32] floatValue], [[HUDCombatButtonYSaved objectAtIndex:32] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:32] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:32] floatValue]);
        Stair_Selected.contents = (id) Stair_SelectedImage.CGImage;
        [_view.layer addSublayer:Stair_Selected];

        UIImage *Stair_UnselectedImage = [self imageWithImage:[UIImage imageNamed: @"Stair Unselected.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:33] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:33] floatValue])];
        Stair_Unselected.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:33] floatValue], [[HUDCombatButtonYSaved objectAtIndex:33] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:33] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:33] floatValue]);
        Stair_Unselected.contents = (id) Stair_UnselectedImage.CGImage;
        [_view.layer addSublayer:Stair_Unselected];

        UIImage *Switch_To_BuildImage = [self imageWithImage:[UIImage imageNamed: @"Switch To Build.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:34] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:34] floatValue])];
        Switch_To_Build.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:34] floatValue], [[HUDCombatButtonYSaved objectAtIndex:34] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:34] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:34] floatValue]);
        Switch_To_Build.contents = (id) Switch_To_BuildImage.CGImage;
        [_view.layer addSublayer:Switch_To_Build];

        UIImage *Switch_To_CombatImage = [self imageWithImage:[UIImage imageNamed: @"Switch To Combat.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:35] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:35] floatValue])];
        Switch_To_Combat.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:35] floatValue], [[HUDCombatButtonYSaved objectAtIndex:35] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:35] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:35] floatValue]);
        Switch_To_Combat.contents = (id) Switch_To_CombatImage.CGImage;
        [_view.layer addSublayer:Switch_To_Combat];

        UIImage *ThrowImage = [self imageWithImage:[UIImage imageNamed: @"Throw.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:36] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:36] floatValue])];
        Throw.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:36] floatValue], [[HUDCombatButtonYSaved objectAtIndex:36] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:36] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:36] floatValue]);
        Throw.contents = (id) ThrowImage.CGImage;
        [_view.layer addSublayer:Throw];

        UIImage *UseImage = [self imageWithImage:[UIImage imageNamed: @"Use.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:37] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:37] floatValue])];
        Use.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:37] floatValue], [[HUDCombatButtonYSaved objectAtIndex:37] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:37] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:37] floatValue]);
        Use.contents = (id) UseImage.CGImage;
        [_view.layer addSublayer:Use];

        UIImage *Wall_SelectedImage = [self imageWithImage:[UIImage imageNamed: @"Wall Selected.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:38] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:38] floatValue])];
        Wall_Selected.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:38] floatValue], [[HUDCombatButtonYSaved objectAtIndex:38] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:38] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:38] floatValue]);
        Wall_Selected.contents = (id) Wall_SelectedImage.CGImage;
        [_view.layer addSublayer:Wall_Selected];

        UIImage *Wall_UnselectedImage = [self imageWithImage:[UIImage imageNamed: @"Wall Unselected.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:39] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:39] floatValue])];
        Wall_Unselected.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:39] floatValue], [[HUDCombatButtonYSaved objectAtIndex:39] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:39] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:39] floatValue]);
        Wall_Unselected.contents = (id) Wall_UnselectedImage.CGImage;
        [_view.layer addSublayer:Wall_Unselected];
    }

- (UIImage *)imageWithImage:(UIImage *)image scaledToFillSize:(CGSize)size
{
    CGFloat scale = MAX(size.width/image.size.width, size.height/image.size.height);
    CGFloat width = image.size.width * scale;
    CGFloat height = image.size.height * scale;
    CGRect imageRect = CGRectMake((size.width - width)/2.0f,
                                  (size.height - height)/2.0f,
                                  width,
                                  height);

    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:imageRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

    - (void)drawStartSelectHome
    {
        // create Start button
        UIImage *startButtonImage = [UIImage imageNamed:@"StartButton"];
        _startButton.frame    = CGRectMake(START_X - startButtonImage.size.width / 2, START_Y - startButtonImage.size.height / 2, startButtonImage.size.width, startButtonImage.size.height);
        _startButton.contents = (id) startButtonImage.CGImage;
        [_view.layer addSublayer:_startButton];

        // create Select button
        UIImage *selectButtonImage = [UIImage imageNamed:@"SelectButton"];
        _selectButton.frame    = CGRectMake(SELECT_X - selectButtonImage.size.width / 2, SELECT_Y - selectButtonImage.size.height / 2, selectButtonImage.size.width, selectButtonImage.size.height);
        _selectButton.contents = (id) selectButtonImage.CGImage;
        [_view.layer addSublayer:_selectButton];

        // create Home button
        UIImage *homeButtonImage = [UIImage imageNamed:@"HomeButton"];
        _homeButton.frame    = CGRectMake(HOME_X - homeButtonImage.size.width / 2, HOME_Y - homeButtonImage.size.height / 2, homeButtonImage.size.width, homeButtonImage.size.height);
        _homeButton.contents = (id) homeButtonImage.CGImage;
        // TODO fix home button sending to webview
        // [_view.layer addSublayer:_homeButton];
    }

    - (void)drawBumpers
    {
        // create L1 button
        UIImage *l1ButtonImage = [UIImage imageNamed:@"L1"];
        _l1Button.frame    = CGRectMake(L1_X - l1ButtonImage.size.width / 2, L1_Y - l1ButtonImage.size.height / 2, l1ButtonImage.size.width, l1ButtonImage.size.height);
        _l1Button.contents = (id) l1ButtonImage.CGImage;
        [_view.layer addSublayer:_l1Button];

        // create R1 button
        UIImage *r1ButtonImage = [UIImage imageNamed:@"R1"];
        _r1Button.frame    = CGRectMake(R1_X - r1ButtonImage.size.width / 2, R1_Y - r1ButtonImage.size.height / 2, r1ButtonImage.size.width, r1ButtonImage.size.height);
        _r1Button.contents = (id) r1ButtonImage.CGImage;
        [_view.layer addSublayer:_r1Button];
    }

    - (void)drawTriggers
    {
        // create L2 button
        UIImage *l2ButtonImage = [UIImage imageNamed:@"L2"];
        _l2Button.frame    = CGRectMake(L2_X - l2ButtonImage.size.width / 2, L2_Y - l2ButtonImage.size.height / 2, l2ButtonImage.size.width, l2ButtonImage.size.height);
        _l2Button.contents = (id) l2ButtonImage.CGImage;
        [_view.layer addSublayer:_l2Button];

        // create R2 button
        UIImage *r2ButtonImage = [UIImage imageNamed:@"R2"];
        _r2Button.frame    = CGRectMake(R2_X - r2ButtonImage.size.width / 2, R2_Y - r2ButtonImage.size.height / 2, r2ButtonImage.size.width, r2ButtonImage.size.height);
        _r2Button.contents = (id) r2ButtonImage.CGImage;
        [_view.layer addSublayer:_r2Button];
    }

    - (void)drawSticks
    {
        // create left analog stick
        UIImage *leftStickBgImage = [UIImage imageNamed:@"StickOuter"];
        _leftStickBackground.frame    = CGRectMake(LS_CENTER_X - leftStickBgImage.size.width / 2, LS_CENTER_Y - leftStickBgImage.size.height / 2, leftStickBgImage.size.width, leftStickBgImage.size.height);
        _leftStickBackground.contents = (id) leftStickBgImage.CGImage;
        [_view.layer addSublayer:_leftStickBackground];

        UIImage *leftStickImage = [UIImage imageNamed:@"StickInner"];
        _leftStick.frame    = CGRectMake(LS_CENTER_X - leftStickImage.size.width / 2, LS_CENTER_Y - leftStickImage.size.height / 2, leftStickImage.size.width, leftStickImage.size.height);
        _leftStick.contents = (id) leftStickImage.CGImage;
        [_view.layer addSublayer:_leftStick];

        // create right analog stick
        UIImage *rightStickBgImage = [UIImage imageNamed:@"StickOuter"];
        _rightStickBackground.frame    = CGRectMake(RS_CENTER_X - rightStickBgImage.size.width / 2, RS_CENTER_Y - rightStickBgImage.size.height / 2, rightStickBgImage.size.width, rightStickBgImage.size.height);
        _rightStickBackground.contents = (id) rightStickBgImage.CGImage;
        [_view.layer addSublayer:_rightStickBackground];

        UIImage *rightStickImage = [UIImage imageNamed:@"StickInner"];
        _rightStick.frame    = CGRectMake(RS_CENTER_X - rightStickImage.size.width / 2, RS_CENTER_Y - rightStickImage.size.height / 2, rightStickImage.size.width, rightStickImage.size.height);
        _rightStick.contents = (id) rightStickImage.CGImage;
        [_view.layer addSublayer:_rightStick];

        STICK_INNER_SIZE = rightStickImage.size.width;
        STICK_OUTER_SIZE = rightStickBgImage.size.width;
    }

    - (void)drawL3R3
    {
        UIImage *l3ButtonImage = [UIImage imageNamed:@"L3"];
        _l3Button.frame        = CGRectMake(L3_X - l3ButtonImage.size.width / 2, L3_Y - l3ButtonImage.size.height / 2, l3ButtonImage.size.width, l3ButtonImage.size.height);
        _l3Button.contents     = (id) l3ButtonImage.CGImage;
        _l3Button.cornerRadius = l3ButtonImage.size.width / 2;
        _l3Button.borderColor  = [UIColor colorWithRed:15.f / 255 green:160.f / 255 blue:40.f / 255 alpha:1.f].CGColor;
        [_view.layer addSublayer:_l3Button];

        UIImage *r3ButtonImage = [UIImage imageNamed:@"R3"];
        _r3Button.frame        = CGRectMake(R3_X - r3ButtonImage.size.width / 2, R3_Y - r3ButtonImage.size.height / 2, r3ButtonImage.size.width, r3ButtonImage.size.height);
        _r3Button.contents     = (id) r3ButtonImage.CGImage;
        _r3Button.cornerRadius = r3ButtonImage.size.width / 2;
        _r3Button.borderColor  = [UIColor colorWithRed:15.f / 255 green:160.f / 255 blue:40.f / 255 alpha:1.f].CGColor;
        [_view.layer addSublayer:_r3Button];
    }

    - (void)hideButtons
    {
        [_aButton removeFromSuperlayer];
        [_bButton removeFromSuperlayer];
        [_xButton removeFromSuperlayer];
        [_yButton removeFromSuperlayer];
        [_upButton removeFromSuperlayer];
        [_downButton removeFromSuperlayer];
        [_leftButton removeFromSuperlayer];
        [_rightButton removeFromSuperlayer];
    }

    - (void)hideStartSelectHome
    {
        [_startButton removeFromSuperlayer];
        [_selectButton removeFromSuperlayer];
        [_homeButton removeFromSuperlayer];
    }

    - (void)hideBumpers
    {
        [_l1Button removeFromSuperlayer];
        [_r1Button removeFromSuperlayer];
    }

    - (void)hideTriggers
    {
        [_l2Button removeFromSuperlayer];
        [_r2Button removeFromSuperlayer];
    }

    - (void)hideSticks
    {
        [_leftStickBackground removeFromSuperlayer];
        [_rightStickBackground removeFromSuperlayer];
        [_leftStick removeFromSuperlayer];
        [_rightStick removeFromSuperlayer];
    }

    - (void)hideL3R3
    {
        [_l3Button removeFromSuperlayer];
        [_r3Button removeFromSuperlayer];
    }

    - (BOOL)handleTouchMovedEvent:touches
    {
        BOOL updated     = false;
        BOOL buttonTouch = false;

        CGFloat HALF_STICK_INNER_SIZE = STICK_INNER_SIZE / 2;
        CGFloat HALF_STICK_OUTER_SIZE = STICK_OUTER_SIZE / 2;

        for(UITouch *touch in touches)
        {
            CGPoint touchLocation = [touch locationInView:_view];
            CGFloat xLoc          = touchLocation.x;
            CGFloat yLoc          = touchLocation.y;
            if(touch == _lsTouch)
            {
                CGFloat deltaX = xLoc - _lsTouchStart.x;
                CGFloat deltaY = yLoc - _lsTouchStart.y;

                CGFloat valueX = CLAMP(deltaX / HALF_STICK_OUTER_SIZE);
                CGFloat valueY = CLAMP(deltaY / HALF_STICK_OUTER_SIZE);

                NO_ANIM(_leftStick.frame = CGRectMake(LS_CENTER_X + valueX * HALF_STICK_OUTER_SIZE - HALF_STICK_INNER_SIZE,
                                                      LS_CENTER_Y + valueY * HALF_STICK_OUTER_SIZE - HALF_STICK_INNER_SIZE,
                                                      STICK_INNER_SIZE,
                                                      STICK_INNER_SIZE));

                if(fabs(valueX) < STICK_DEAD_ZONE)
                {
                    valueX = 0;
                }
                if(fabs(valueY) < STICK_DEAD_ZONE)
                {
                    valueY = 0;
                }

                [_controllerSupport updateLeftStick:_controller x:(short) (0x7FFF * valueX) y:(short) (0x7FFF * -valueY)];

                updated = true;
            }
            else if(touch == _rsTouch)
            {
                CGFloat deltaX = xLoc - _rsTouchStart.x;
                CGFloat deltaY = yLoc - _rsTouchStart.y;

                CGFloat valueX = CLAMP(deltaX / HALF_STICK_OUTER_SIZE);
                CGFloat valueY = CLAMP(deltaY / HALF_STICK_OUTER_SIZE);

                NO_ANIM(_rightStick.frame = CGRectMake(RS_CENTER_X + valueX * HALF_STICK_OUTER_SIZE - HALF_STICK_INNER_SIZE,
                                                       RS_CENTER_Y + valueY * HALF_STICK_OUTER_SIZE - HALF_STICK_INNER_SIZE,
                                                       STICK_INNER_SIZE,
                                                       STICK_INNER_SIZE));

                if(fabs(valueX) < STICK_DEAD_ZONE)
                {
                    valueX = 0;
                }
                if(fabs(valueY) < STICK_DEAD_ZONE)
                {
                    valueY = 0;
                }

                [_controllerSupport updateRightStick:_controller x:(short) (0x7FFF * valueX) y:(short) (0x7FFF * -valueY)];

                updated = true;
            }
            else if(touch == _dpadTouch)
            {
                [_controllerSupport clearButtonFlag:_controller
                                    flags:UP_FLAG | DOWN_FLAG | LEFT_FLAG | RIGHT_FLAG];

                // Allow the user to slide their finger to another d-pad button
                if([_upButton.presentationLayer hitTest:touchLocation])
                {
                    [_controllerSupport setButtonFlag:_controller flags:UP_FLAG];
                    updated = true;
                }
                else if([_downButton.presentationLayer hitTest:touchLocation])
                {
                    [_controllerSupport setButtonFlag:_controller flags:DOWN_FLAG];
                    updated = true;
                }
                else if([_leftButton.presentationLayer hitTest:touchLocation])
                {
                    [_controllerSupport setButtonFlag:_controller flags:LEFT_FLAG];
                    updated = true;
                }
                else if([_rightButton.presentationLayer hitTest:touchLocation])
                {
                    [_controllerSupport setButtonFlag:_controller flags:RIGHT_FLAG];
                    updated = true;
                }

                buttonTouch = true;
            }
            else if(touch == _aTouch)
            {
                buttonTouch = true;
            }
            else if(touch == _bTouch)
            {
                buttonTouch = true;
            }
            else if(touch == _xTouch)
            {
                buttonTouch = true;
            }
            else if(touch == _yTouch)
            {
                buttonTouch = true;
            }
            else if(touch == _startTouch)
            {
                buttonTouch = true;
            }
            else if(touch == _selectTouch)
            {
                buttonTouch = true;
            }
            else if(touch == _homeTouch)
            {
                buttonTouch = true;
            }
            else if(touch == _l1Touch)
            {
                buttonTouch = true;
            }
            else if(touch == _r1Touch)
            {
                buttonTouch = true;
            }
            else if(touch == _l2Touch)
            {
                buttonTouch = true;
            }
            else if(touch == _r2Touch)
            {
                buttonTouch = true;
            }
            else if(touch == _l3Touch)
            {
                buttonTouch = true;
            }
            else if(touch == _r3Touch)
            {
                buttonTouch = true;
            } else if (touch == AimTouch) {
                buttonTouch = true;
             }
             else if (touch == AutorunTouch) {
                buttonTouch = true;
             }
             else if (touch == ConfirmTouch) {
                buttonTouch = true;
             }
             else if (touch == Crouch_DownTouch) {
                buttonTouch = true;
             }
             else if (touch == Crouch_UpTouch) {
                buttonTouch = true;
             }
             else if (touch == Cycle_Weapons_DownTouch) {
                buttonTouch = true;
             }
             else if (touch == Cycle_Weapons_UpTouch) {
                buttonTouch = true;
             }
             else if (touch == Edit_CrosshairTouch) {
                buttonTouch = true;
             }
             else if (touch == Edit_ResetTouch) {
                buttonTouch = true;
             }
             else if (touch == EditTouch) {
                buttonTouch = true;
             }
             else if (touch == Emote_WheelTouch) {
                buttonTouch = true;
             }
             else if (touch == ExitTouch) {
                buttonTouch = true;
             }
             else if (touch == Floor_SelectedTouch) {
                buttonTouch = true;
             }
             else if (touch == Floor_UnselectedTouch) {
                buttonTouch = true;
             }
             else if (touch == InventoryTouch) {
                buttonTouch = true;
             }
             else if (touch == JumpTouch) {
                buttonTouch = true;
             }
             else if (touch == Mic_MutedTouch) {
                buttonTouch = true;
             }
             else if (touch == Mic_UnmutedTouch) {
                buttonTouch = true;
             }
             else if (touch == Move_JoystickTouch) {
                buttonTouch = true;
             }
             else if (touch == Move_OuterTouch) {
                buttonTouch = true;
             }
             else if (touch == Open_ChestTouch) {
                buttonTouch = true;
             }
             else if (touch == Open_DoorTouch) {
                buttonTouch = true;
             }
             else if (touch == PingTouch) {
                buttonTouch = true;
             }
             else if (touch == Pyramid_SelectedTouch) {
                buttonTouch = true;
             }
             else if (touch == Pyramid_UnselectedTouch) {
                buttonTouch = true;
             }
             else if (touch == Quick_ChatTouch) {
                buttonTouch = true;
             }
             else if (touch == Quick_HealTouch) {
                buttonTouch = true;
             }
             else if (touch == RepairTouch) {
                buttonTouch = true;
             }
             else if (touch == ResetTouch) {
                buttonTouch = true;
             }
             else if (touch == RotateTouch) {
                buttonTouch = true;
             }
             else if (touch == Shoot_BigTouch) {
                buttonTouch = true;
             }
             else if (touch == ShootTouch) {
                buttonTouch = true;
             }
             else if (touch == Stair_SelectedTouch) {
                buttonTouch = true;
             }
             else if (touch == Stair_UnselectedTouch) {
                buttonTouch = true;
             }
             else if (touch == Switch_To_BuildTouch) {
                buttonTouch = true;
             }
             else if (touch == Switch_To_CombatTouch) {
                buttonTouch = true;
             }
             else if (touch == ThrowTouch) {
                buttonTouch = true;
             }
             else if (touch == UseTouch) {
                buttonTouch = true;
             }
             else if (touch == Wall_SelectedTouch) {
                buttonTouch = true;
             }
             else if (touch == Wall_UnselectedTouch) {
                buttonTouch = true;
             }
            if([_deadTouches containsObject:touch])
            {
                updated = true;
            }
        }
        if(updated)
        {
            [_controllerSupport updateFinished:_controller];
        }
        return updated || buttonTouch;
    }

    - (BOOL)handleTouchDownEvent:touches
    {
        BOOL        updated    = false;
        BOOL        stickTouch = false;
        for(UITouch *touch in touches)
        {
            CGPoint touchLocation = [touch locationInView:_view];

            if([_aButton.presentationLayer hitTest:touchLocation])
            {
                [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
                _aTouch = touch;
                updated = true;
            }
            else if([_bButton.presentationLayer hitTest:touchLocation])
            {
                [_controllerSupport setButtonFlag:_controller flags:B_FLAG];
                _bTouch = touch;
                updated = true;
            }
            else if([_xButton.presentationLayer hitTest:touchLocation])
            {
                [_controllerSupport setButtonFlag:_controller flags:X_FLAG];
                _xTouch = touch;
                updated = true;
            }
            else if([_yButton.presentationLayer hitTest:touchLocation])
            {
                [_controllerSupport setButtonFlag:_controller flags:Y_FLAG];
                _yTouch = touch;
                updated = true;
            }
            else if([_upButton.presentationLayer hitTest:touchLocation])
            {
                [_controllerSupport setButtonFlag:_controller flags:UP_FLAG];
                _dpadTouch = touch;
                updated    = true;
            }
            else if([_downButton.presentationLayer hitTest:touchLocation])
            {
                [_controllerSupport setButtonFlag:_controller flags:DOWN_FLAG];
                _dpadTouch = touch;
                updated    = true;
            }
            else if([_leftButton.presentationLayer hitTest:touchLocation])
            {
                [_controllerSupport setButtonFlag:_controller flags:LEFT_FLAG];
                _dpadTouch = touch;
                updated    = true;
            }
            else if([_rightButton.presentationLayer hitTest:touchLocation])
            {
                [_controllerSupport setButtonFlag:_controller flags:RIGHT_FLAG];
                _dpadTouch = touch;
                updated    = true;
            }
            else if([_startButton.presentationLayer hitTest:touchLocation])
            {
                [_controllerSupport setButtonFlag:_controller flags:PLAY_FLAG];
                _startTouch = touch;
                updated     = true;
            }
            else if([_homeButton.presentationLayer hitTest:touchLocation])
            {
                [_controllerSupport setButtonFlag:_controller flags:HOME_FLAG];
                _homeTouch = touch;
                updated    = true;
            }
            else if([_selectButton.presentationLayer hitTest:touchLocation])
            {
                [_controllerSupport setButtonFlag:_controller flags:BACK_FLAG];
                _selectTouch = touch;
                updated      = true;
            }
            else if([_l1Button.presentationLayer hitTest:touchLocation])
            {
                [_controllerSupport setButtonFlag:_controller flags:LB_FLAG];
                _l1Touch = touch;
                updated  = true;
            }
            else if([_r1Button.presentationLayer hitTest:touchLocation])
            {
                [_controllerSupport setButtonFlag:_controller flags:RB_FLAG];
                _r1Touch = touch;
                updated  = true;
            }
            else if([_l2Button.presentationLayer hitTest:touchLocation])
            {
                [_controllerSupport updateLeftTrigger:_controller left:0xFF];
                _l2Touch = touch;
                updated  = true;
            }
            else if([_r2Button.presentationLayer hitTest:touchLocation])
            {
                [_controllerSupport updateRightTrigger:_controller right:0xFF];
                _r2Touch = touch;
                updated  = true;
            }
            else if([_l3Button.presentationLayer hitTest:touchLocation])
            {
                if(l3Set)
                {
                    [_controllerSupport clearButtonFlag:_controller flags:LS_CLK_FLAG];
                    _l3Button.borderWidth = 0.0f;
                }
                else
                {
                    [_controllerSupport setButtonFlag:_controller flags:LS_CLK_FLAG];
                    _l3Button.borderWidth = 2.0f;
                }
                l3Set    = !l3Set;
                _l3Touch = touch;
                updated  = true;
            }
            else if([_r3Button.presentationLayer hitTest:touchLocation])
            {
                if(r3Set)
                {
                    [_controllerSupport clearButtonFlag:_controller flags:RS_CLK_FLAG];
                    _r3Button.borderWidth = 0.0f;
                }
                else
                {
                    [_controllerSupport setButtonFlag:_controller flags:RS_CLK_FLAG];
                    _r3Button.borderWidth = 2.0f;
                }
                r3Set    = !r3Set;
                _r3Touch = touch;
                updated  = true;
            }
            else if(touchLocation.x <= _view.bounds.size.width / 2.0 && touchLocation.y > 50)
            {
                if(l3TouchStart != nil)
                {
                    // Find elapsed time and convert to milliseconds
                    // Use (-) modifier to conversion since receiver is earlier than now
                    double l3TouchTime = [l3TouchStart timeIntervalSinceNow] * -1000.0;
                    if(l3TouchTime < STICK_CLICK_RATE)
                    {
                        [_controllerSupport setButtonFlag:_controller flags:LS_CLK_FLAG];
                        updated = true;
                    }
                }
                _lsTouch      = touch;
                _lsTouchStart = touchLocation;
                stickTouch    = true;
            }
            else if(touchLocation.x > _view.bounds.size.width / 2.0 && touchLocation.y > 50)
            {
                if(r3TouchStart != nil)
                {
                    // Find elapsed time and convert to milliseconds
                    // Use (-) modifier to conversion since receiver is earlier than now
                    double r3TouchTime = [r3TouchStart timeIntervalSinceNow] * -1000.0;
                    if(r3TouchTime < STICK_CLICK_RATE)
                    {
                        [_controllerSupport setButtonFlag:_controller flags:RS_CLK_FLAG];
                        updated = true;
                    }
                }
                _rsTouch      = touch;
                _rsTouchStart = touchLocation;
                stickTouch    = true;
            } else if([Aim.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport updateLeftTrigger:_controller left:0xFF];
              AimTouch = touch;
           updated = true;
           }
            else if([Autorun.presentationLayer hitTest:touchLocation]) {
              [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
              AutorunTouch = touch;
           updated = true;
           }
            else if([Confirm.presentationLayer hitTest:touchLocation]) {
              [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
              ConfirmTouch = touch;
           updated = true;
           }
            else if([Crouch_Down.presentationLayer hitTest:touchLocation]) {
               // [_controllerSupport setButtonFlag:_controller flags:RIGHT_FLAG];
                [_controllerSupport setButtonFlag:_controller flags:RS_CLK_FLAG];
              Crouch_DownTouch = touch;
           updated = true;
           }
            else if([Crouch_Up.presentationLayer hitTest:touchLocation]) {
                //[_controllerSupport setButtonFlag:_controller flags:RIGHT_FLAG];
                [_controllerSupport setButtonFlag:_controller flags:RS_CLK_FLAG];
              Crouch_UpTouch = touch;
           updated = true;
           }
            else if([Cycle_Weapons_Down.presentationLayer hitTest:touchLocation]) {
              [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
              Cycle_Weapons_DownTouch = touch;
           updated = true;
           }
            else if([Cycle_Weapons_Up.presentationLayer hitTest:touchLocation]) {
              [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
              Cycle_Weapons_UpTouch = touch;
           updated = true;
           }
            else if([Edit_Crosshair.presentationLayer hitTest:touchLocation]) {
              [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
              Edit_CrosshairTouch = touch;
           updated = true;
           }
            else if([Edit_Reset.presentationLayer hitTest:touchLocation]) {
              [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
              Edit_ResetTouch = touch;
           updated = true;
           }
            else if([Edit.presentationLayer hitTest:touchLocation]) {
              [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
              EditTouch = touch;
           updated = true;
           }
            else if([Emote_Wheel.presentationLayer hitTest:touchLocation]) {
              [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
              Emote_WheelTouch = touch;
           updated = true;
           }
            else if([Exit.presentationLayer hitTest:touchLocation]) {
              [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
              ExitTouch = touch;
           updated = true;
           }
            else if([Floor_Selected.presentationLayer hitTest:touchLocation]) {
              [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
              Floor_SelectedTouch = touch;
           updated = true;
           }
            else if([Floor_Unselected.presentationLayer hitTest:touchLocation]) {
              [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
              Floor_UnselectedTouch = touch;
           updated = true;
           }
            else if([Inventory.presentationLayer hitTest:touchLocation]) {
              [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
              InventoryTouch = touch;
           updated = true;
           }
            else if([Jump.presentationLayer hitTest:touchLocation]) {
              [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
              JumpTouch = touch;
           updated = true;
           }
            else if([Mic_Muted.presentationLayer hitTest:touchLocation]) {
              [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
              Mic_MutedTouch = touch;
           updated = true;
           }
            else if([Mic_Unmuted.presentationLayer hitTest:touchLocation]) {
              [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
              Mic_UnmutedTouch = touch;
           updated = true;
           }
            else if([Move_Joystick.presentationLayer hitTest:touchLocation]) {
              [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
              Move_JoystickTouch = touch;
           updated = true;
           }
            else if([Move_Outer.presentationLayer hitTest:touchLocation]) {
              [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
              Move_OuterTouch = touch;
           updated = true;
           }
            else if([Open_Chest.presentationLayer hitTest:touchLocation]) {
              [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
              Open_ChestTouch = touch;
           updated = true;
           }
            else if([Open_Door.presentationLayer hitTest:touchLocation]) {
              [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
              Open_DoorTouch = touch;
           updated = true;
           }
            else if([Ping.presentationLayer hitTest:touchLocation]) {
              [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
                [_controllerSupport updateFinished:_controller];
                
                double delayInSeconds = 0.02;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self->_controllerSupport clearButtonFlag:self->_controller flags:A_FLAG];
                    [self->_controllerSupport updateFinished:self->_controller];
                });

                
                double delayInSeconds3 = 0.04;
                dispatch_time_t popTime3 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds3 * NSEC_PER_SEC));
                dispatch_after(popTime3, dispatch_get_main_queue(), ^(void){
                    [self->_controllerSupport updateRightTrigger:self->_controller right:0xFF];
                    [self->_controllerSupport updateFinished:self->_controller];
                });
                
                double delayInSeconds2 = 0.06;
                dispatch_time_t popTime2 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds2 * NSEC_PER_SEC));
                dispatch_after(popTime2, dispatch_get_main_queue(), ^(void){
                    [_controllerSupport updateRightTrigger:_controller right:0];
                    [self->_controllerSupport updateFinished:self->_controller];
                });

              //PingTouch = touch;
           //updated = true;
           }
            else if([Pyramid_Selected.presentationLayer hitTest:touchLocation]) {
              [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
              Pyramid_SelectedTouch = touch;
           updated = true;
           }
            else if([Pyramid_Unselected.presentationLayer hitTest:touchLocation]) {
              [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
              Pyramid_UnselectedTouch = touch;
           updated = true;
           }
            else if([Quick_Chat.presentationLayer hitTest:touchLocation]) {
              [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
              Quick_ChatTouch = touch;
           updated = true;
           }
            else if([Quick_Heal.presentationLayer hitTest:touchLocation]) {
              [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
              Quick_HealTouch = touch;
           updated = true;
           }
            else if([Repair.presentationLayer hitTest:touchLocation]) {
              [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
              RepairTouch = touch;
           updated = true;
           }
            else if([Reset.presentationLayer hitTest:touchLocation]) {
              [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
              ResetTouch = touch;
           updated = true;
           }
            else if([Rotate.presentationLayer hitTest:touchLocation]) {
              [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
              RotateTouch = touch;
           updated = true;
           }
            else if([Shoot_Big.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport updateRightTrigger:_controller right:0xFF];
              Shoot_BigTouch = touch;
           updated = true;
           }
            else if([Shoot.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport updateRightTrigger:_controller right:0xFF];
              ShootTouch = touch;
           updated = true;
           }
            else if([Stair_Selected.presentationLayer hitTest:touchLocation]) {
              [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
              Stair_SelectedTouch = touch;
           updated = true;
           }
            else if([Stair_Unselected.presentationLayer hitTest:touchLocation]) {
              [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
              Stair_UnselectedTouch = touch;
           updated = true;
           }
            else if([Switch_To_Build.presentationLayer hitTest:touchLocation]) {
              [_controllerSupport setButtonFlag:_controller flags:B_FLAG];
              Switch_To_BuildTouch = touch;
           updated = true;
           }
            else if([Switch_To_Combat.presentationLayer hitTest:touchLocation]) {
              [_controllerSupport setButtonFlag:_controller flags:B_FLAG];
              Switch_To_CombatTouch = touch;
           updated = true;
           }
            else if([Throw.presentationLayer hitTest:touchLocation]) {
              [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
              ThrowTouch = touch;
           updated = true;
           }
            else if([Use.presentationLayer hitTest:touchLocation]) {
              [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
              UseTouch = touch;
           updated = true;
           }
            else if([Wall_Selected.presentationLayer hitTest:touchLocation]) {
              [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
              Wall_SelectedTouch = touch;
           updated = true;
           }
            else if([Wall_Unselected.presentationLayer hitTest:touchLocation]) {
              [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
              Wall_UnselectedTouch = touch;
           updated = true;
           }
            if(!updated && !stickTouch && [self isInDeadZone:touch])
            {
                [_deadTouches addObject:touch];
                updated = true;
            }
        }
        if(updated)
        {
            [hapticFeedback generateFeedback];
            [_controllerSupport updateFinished:_controller];
        }
        return updated || stickTouch;
    }

    - (BOOL)handleTouchUpEvent:touches
    {
        BOOL        updated = false;
        BOOL        touched = false;
        for(UITouch *touch in touches)
        {
            if(touch == _aTouch)
            {
                [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
                _aTouch = nil;
                updated = true;
            }
            else if(touch == _bTouch)
            {
                [_controllerSupport clearButtonFlag:_controller flags:B_FLAG];
                _bTouch = nil;
                updated = true;
            }
            else if(touch == _xTouch)
            {
                [_controllerSupport clearButtonFlag:_controller flags:X_FLAG];
                _xTouch = nil;
                updated = true;
            }
            else if(touch == _yTouch)
            {
                [_controllerSupport clearButtonFlag:_controller flags:Y_FLAG];
                _yTouch = nil;
                updated = true;
            }
            else if(touch == _dpadTouch)
            {
                [_controllerSupport clearButtonFlag:_controller
                                    flags:UP_FLAG | DOWN_FLAG | LEFT_FLAG | RIGHT_FLAG];
                _dpadTouch = nil;
                updated    = true;
            }
            else if(touch == _startTouch)
            {
                [_controllerSupport clearButtonFlag:_controller flags:PLAY_FLAG];
                _startTouch = nil;
                updated     = true;
            }
            else if(touch == _homeTouch)
            {
                [_controllerSupport clearButtonFlag:_controller flags:HOME_FLAG];
                _homeTouch = nil;
                updated    = true;
            }
            else if(touch == _selectTouch)
            {
                [_controllerSupport clearButtonFlag:_controller flags:BACK_FLAG];
                _selectTouch = nil;
                updated      = true;
            }
            else if(touch == _l1Touch)
            {
                [_controllerSupport clearButtonFlag:_controller flags:LB_FLAG];
                _l1Touch = nil;
                updated  = true;
            }
            else if(touch == _r1Touch)
            {
                [_controllerSupport clearButtonFlag:_controller flags:RB_FLAG];
                _r1Touch = nil;
                updated  = true;
            }
            else if(touch == _l2Touch)
            {
                [_controllerSupport updateLeftTrigger:_controller left:0];
                _l2Touch = nil;
                updated  = true;
            }
            else if(touch == _r2Touch)
            {
                [_controllerSupport updateRightTrigger:_controller right:0];
                _r2Touch = nil;
                updated  = true;
            }
            else if(touch == _lsTouch)
            {
                _leftStick.frame = CGRectMake(LS_CENTER_X - STICK_INNER_SIZE / 2, LS_CENTER_Y - STICK_INNER_SIZE / 2, STICK_INNER_SIZE, STICK_INNER_SIZE);
                [_controllerSupport updateLeftStick:_controller x:0 y:0];
                [_controllerSupport clearButtonFlag:_controller flags:LS_CLK_FLAG];
                l3TouchStart = [NSDate date];
                _lsTouch     = nil;
                updated      = true;
            }
            else if(touch == _rsTouch)
            {
                _rightStick.frame = CGRectMake(RS_CENTER_X - STICK_INNER_SIZE / 2, RS_CENTER_Y - STICK_INNER_SIZE / 2, STICK_INNER_SIZE, STICK_INNER_SIZE);
                [_controllerSupport updateRightStick:_controller x:0 y:0];
                [_controllerSupport clearButtonFlag:_controller flags:RS_CLK_FLAG];
                r3TouchStart = [NSDate date];
                _rsTouch     = nil;
                updated      = true;
            }
            else if(touch == _l3Touch)
            {
                _l3Touch = nil;
                touched  = true;
            }
            else if(touch == _r3Touch)
            {
                _r3Touch = nil;
                touched  = true;
            } else if (touch == AimTouch) {
                [_controllerSupport updateLeftTrigger:_controller left:0];
              AimTouch = nil;
              updated = true;
           }
            else if (touch == AutorunTouch) {
              [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
              AutorunTouch = nil;
              updated = true;
           }
            else if (touch == ConfirmTouch) {
              [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
              ConfirmTouch = nil;
              updated = true;
           }
            else if (touch == Crouch_DownTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:RS_CLK_FLAG];
              Crouch_DownTouch = nil;
              updated = true;
           }
            else if (touch == Crouch_UpTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:RS_CLK_FLAG];
              Crouch_UpTouch = nil;
              updated = true;
           }
            else if (touch == Cycle_Weapons_DownTouch) {
              [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
              Cycle_Weapons_DownTouch = nil;
              updated = true;
           }
            else if (touch == Cycle_Weapons_UpTouch) {
              [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
              Cycle_Weapons_UpTouch = nil;
              updated = true;
           }
            else if (touch == Edit_CrosshairTouch) {
              [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
              Edit_CrosshairTouch = nil;
              updated = true;
           }
            else if (touch == Edit_ResetTouch) {
              [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
              Edit_ResetTouch = nil;
              updated = true;
           }
            else if (touch == EditTouch) {
              [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
              EditTouch = nil;
              updated = true;
           }
            else if (touch == Emote_WheelTouch) {
              [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
              Emote_WheelTouch = nil;
              updated = true;
           }
            else if (touch == ExitTouch) {
              [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
              ExitTouch = nil;
              updated = true;
           }
            else if (touch == Floor_SelectedTouch) {
              [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
              Floor_SelectedTouch = nil;
              updated = true;
           }
            else if (touch == Floor_UnselectedTouch) {
              [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
              Floor_UnselectedTouch = nil;
              updated = true;
           }
            else if (touch == InventoryTouch) {
              [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
              InventoryTouch = nil;
              updated = true;
           }
            else if (touch == JumpTouch) {
              [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
              JumpTouch = nil;
              updated = true;
           }
            else if (touch == Mic_MutedTouch) {
              [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
              Mic_MutedTouch = nil;
              updated = true;
           }
            else if (touch == Mic_UnmutedTouch) {
              [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
              Mic_UnmutedTouch = nil;
              updated = true;
           }
            else if (touch == Move_JoystickTouch) {
              [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
              Move_JoystickTouch = nil;
              updated = true;
           }
            else if (touch == Move_OuterTouch) {
              [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
              Move_OuterTouch = nil;
              updated = true;
           }
            else if (touch == Open_ChestTouch) {
              [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
              Open_ChestTouch = nil;
              updated = true;
           }
            else if (touch == Open_DoorTouch) {
              [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
              Open_DoorTouch = nil;
              updated = true;
           }
            else if (touch == PingTouch) {
              [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
              PingTouch = nil;
              updated = true;
           }
            else if (touch == Pyramid_SelectedTouch) {
              [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
              Pyramid_SelectedTouch = nil;
              updated = true;
           }
            else if (touch == Pyramid_UnselectedTouch) {
              [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
              Pyramid_UnselectedTouch = nil;
              updated = true;
           }
            else if (touch == Quick_ChatTouch) {
              [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
              Quick_ChatTouch = nil;
              updated = true;
           }
            else if (touch == Quick_HealTouch) {
              [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
              Quick_HealTouch = nil;
              updated = true;
           }
            else if (touch == RepairTouch) {
              [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
              RepairTouch = nil;
              updated = true;
           }
            else if (touch == ResetTouch) {
              [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
              ResetTouch = nil;
              updated = true;
           }
            else if (touch == RotateTouch) {
              [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
              RotateTouch = nil;
              updated = true;
           }
            else if (touch == Shoot_BigTouch) {
                //[_controllerSupport updateRightTrigger:_controller right:0xFF];
                [_controllerSupport updateRightTrigger:_controller right:0];
              Shoot_BigTouch = nil;
              updated = true;
           }
            else if (touch == ShootTouch) {
                //[_controllerSupport updateRightTrigger:_controller right:0xFF];
                [_controllerSupport updateRightTrigger:_controller right:0];
              ShootTouch = nil;
              updated = true;
           }
            else if (touch == Stair_SelectedTouch) {
              [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
              Stair_SelectedTouch = nil;
              updated = true;
           }
            else if (touch == Stair_UnselectedTouch) {
              [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
              Stair_UnselectedTouch = nil;
              updated = true;
           }
            else if (touch == Switch_To_BuildTouch) {
              [_controllerSupport clearButtonFlag:_controller flags:B_FLAG];
              Switch_To_BuildTouch = nil;
              updated = true;
           }
            else if (touch == Switch_To_CombatTouch) {
              [_controllerSupport clearButtonFlag:_controller flags:B_FLAG];
              Switch_To_CombatTouch = nil;
              updated = true;
           }
            else if (touch == ThrowTouch) {
              [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
              ThrowTouch = nil;
              updated = true;
           }
            else if (touch == UseTouch) {
              [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
              UseTouch = nil;
              updated = true;
           }
            else if (touch == Wall_SelectedTouch) {
              [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
              Wall_SelectedTouch = nil;
              updated = true;
           }
            else if (touch == Wall_UnselectedTouch) {
              [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
              Wall_UnselectedTouch = nil;
              updated = true;
           }
            if([_deadTouches containsObject:touch])
            {
                [_deadTouches removeObject:touch];
                updated = true;
            }
        }
        if(updated)
        {
            [_controllerSupport updateFinished:_controller];
        }

        return updated || touched;
    }

    - (BOOL)isInDeadZone:(UITouch *)touch
    {
        // Dynamically evaluate deadzones based on the controls
        // on screen at the time
        if(_leftButton.superlayer != nil && [self isDpadDeadZone:touch])
        {
            return true;
        }
        else if(_aButton.superlayer != nil && [self isAbxyDeadZone:touch])
        {
            return true;
        }
        else if(_l2Button.superlayer != nil && [self isTriggerDeadZone:touch])
        {
            return true;
        }
        else if(_l1Button.superlayer != nil && [self isBumperDeadZone:touch])
        {
            return true;
        }
        else if(_startButton.superlayer != nil && [self isStartSelectHomeDeadZone:touch])
        {
            return true;
        }
        else if(_homeButton.superlayer != nil && [self isStartSelectHomeDeadZone:touch])
        {
            return true;
        }
        else if(_l3Button.superlayer != nil && [self isL3R3DeadZone:touch])
        {
            return true;
        }
        else if(_leftStickBackground.superlayer != nil && [self isStickDeadZone:touch])
        {
            return true;
        }

        return false;
    }

    - (BOOL)isDpadDeadZone:(UITouch *)touch
    {
        return [self isDeadZone:touch
                     startX:_view.frame.origin.x
                     startY:_upButton.frame.origin.y
                     endX:_rightButton.frame.origin.x + _rightButton.frame.size.width
                     endY:_view.frame.origin.y + _view.frame.size.height];
    }

    - (BOOL)isAbxyDeadZone:(UITouch *)touch
    {
        return [self isDeadZone:touch
                     startX:_xButton.frame.origin.x
                     startY:_yButton.frame.origin.y
                     endX:_view.frame.origin.x + _view.frame.size.width
                     endY:_view.frame.origin.y + _view.frame.size.height];
    }

    - (BOOL)isBumperDeadZone:(UITouch *)touch
    {
        return [self isDeadZone:touch
                     startX:_view.frame.origin.x
                     startY:_l2Button.frame.origin.y + _l2Button.frame.size.height
                     endX:_l1Button.frame.origin.x + _l1Button.frame.size.width
                     endY:_upButton.frame.origin.y]
               || [self isDeadZone:touch
                        startX:_r2Button.frame.origin.x
                        startY:_r2Button.frame.origin.y + _r2Button.frame.size.height
                        endX:_view.frame.origin.x + _view.frame.size.width
                        endY:_yButton.frame.origin.y];
    }

    - (BOOL)isTriggerDeadZone:(UITouch *)touch
    {
        return [self isDeadZone:touch
                     startX:_view.frame.origin.x
                     startY:_l2Button.frame.origin.y
                     endX:_l2Button.frame.origin.x + _l2Button.frame.size.width
                     endY:_view.frame.origin.y + _view.frame.size.height]
               || [self isDeadZone:touch
                        startX:_r2Button.frame.origin.x
                        startY:_r2Button.frame.origin.y
                        endX:_view.frame.origin.x + _view.frame.size.width
                        endY:_view.frame.origin.y + _view.frame.size.height];
    }

    - (BOOL)isL3R3DeadZone:(UITouch *)touch
    {
        return [self isDeadZone:touch
                     startX:_view.frame.origin.x
                     startY:_l3Button.frame.origin.y
                     endX:_view.frame.origin.x
                     endY:_view.frame.origin.y + _view.frame.size.height]
               || [self isDeadZone:touch
                        startX:_r3Button.frame.origin.x
                        startY:_r3Button.frame.origin.y
                        endX:_view.frame.origin.x + _view.frame.size.width
                        endY:_view.frame.origin.y + _view.frame.size.height];
    }

    - (BOOL)isStartSelectHomeDeadZone:(UITouch *)touch
    {
        return [self isDeadZone:touch
                     startX:_startButton.frame.origin.x
                     startY:_startButton.frame.origin.y
                     endX:_view.frame.origin.x + _view.frame.size.width
                     endY:_view.frame.origin.y + _view.frame.size.height]
               || [self isDeadZone:touch
                        startX:_view.frame.origin.x
                        startY:_selectButton.frame.origin.y
                        endX:_selectButton.frame.origin.x + _selectButton.frame.size.width
                        endY:_view.frame.origin.y + _view.frame.size.height];
    }

    - (BOOL)isStickDeadZone:(UITouch *)touch
    {
        return [self isDeadZone:touch
                     startX:_leftStickBackground.frame.origin.x - 15
                     startY:_leftStickBackground.frame.origin.y - 15
                     endX:_leftStickBackground.frame.origin.x + _leftStickBackground.frame.size.width + 15
                     endY:_view.frame.origin.y + _view.frame.size.height]
               || [self isDeadZone:touch
                        startX:_rightStickBackground.frame.origin.x - 15
                        startY:_rightStickBackground.frame.origin.y - 15
                        endX:_rightStickBackground.frame.origin.x + _rightStickBackground.frame.size.width + 15
                        endY:_view.frame.origin.y + _view.frame.size.height];
    }

    - (BOOL)isDeadZone:(UITouch *)touch startX:(float)deadZoneStartX startY:(float)deadZoneStartY endX:(float)deadZoneEndX endY:(float)deadZoneEndY
    {
        deadZoneStartX -= DEAD_ZONE_PADDING;
        deadZoneStartY -= DEAD_ZONE_PADDING;
        deadZoneEndX += DEAD_ZONE_PADDING;
        deadZoneEndY += DEAD_ZONE_PADDING;

        CGPoint touchLocation = [touch locationInView:_view];
        return (touchLocation.x > deadZoneStartX && touchLocation.x < deadZoneEndX
                && touchLocation.y > deadZoneStartY && touchLocation.y < deadZoneEndY);

    }

@end

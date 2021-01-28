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
        
        CALayer *_fortniteAim;
        CALayer *_fortniteAutorun;
        CALayer *_fortniteConfirm;
        CALayer *_fortniteCrouch_Down;
        CALayer *_fortniteCrouch_Up;
        CALayer *_fortniteCycle_Weapons_Down;
        CALayer *_fortniteCycle_Weapons_Up;
        CALayer *_fortniteEdit_Crosshair;
        CALayer *_fortniteEdit_Reset;
        CALayer *_fortniteEdit;
        CALayer *_fortniteEmote_Wheel;
        CALayer *_fortniteExit;
        CALayer *_fortniteFloor_Selected;
        CALayer *_fortniteFloor_Unselected;
        CALayer *_fortniteInventory;
        CALayer *_fortniteJump;
        CALayer *_fortniteMic_Muted;
        CALayer *_fortniteMic_Unmuted;
        CALayer *_fortniteMove_Joystick;
        CALayer *_fortniteMove_Outer;
        CALayer *_fortniteOpen_Chest;
        CALayer *_fortniteOpen_Door;
        CALayer *_fortnitePing;
        CALayer *_fortnitePyramid_Selected;
        CALayer *_fortnitePyramid_Unselected;
        CALayer *_fortniteQuick_Chat;
        CALayer *_fortniteQuick_Heal;
        CALayer *_fortniteRepair;
        CALayer *_fortniteReset;
        CALayer *_fortniteRotate;
        CALayer *_fortniteShoot_Big;
        CALayer *_fortniteShoot;
        CALayer *_fortniteStair_Selected;
        CALayer *_fortniteStair_Unselected;
        CALayer *_fortniteSwitch_To_Build;
        CALayer *_fortniteSwitch_To_Combat;
        CALayer *_fortniteThrow;
        CALayer *_fortniteUse;
        CALayer *_fortniteWall_Selected;
        CALayer *_fortniteWall_Unselected;
        
        UITouch *_fortniteAimTouch;
        UITouch *_fortniteAutorunTouch;
        UITouch *_fortniteConfirmTouch;
        UITouch *_fortniteCrouch_DownTouch;
        UITouch *_fortniteCrouch_UpTouch;
        UITouch *_fortniteCycle_Weapons_DownTouch;
        UITouch *_fortniteCycle_Weapons_UpTouch;
        UITouch *_fortniteEdit_CrosshairTouch;
        UITouch *_fortniteEdit_ResetTouch;
        UITouch *_fortniteEditTouch;
        UITouch *_fortniteEmote_WheelTouch;
        UITouch *_fortniteExitTouch;
        UITouch *_fortniteFloor_SelectedTouch;
        UITouch *_fortniteFloor_UnselectedTouch;
        UITouch *_fortniteInventoryTouch;
        UITouch *_fortniteJumpTouch;
        UITouch *_fortniteMic_MutedTouch;
        UITouch *_fortniteMic_UnmutedTouch;
        UITouch *_fortniteMove_JoystickTouch;
        UITouch *_fortniteMove_OuterTouch;
        UITouch *_fortniteOpen_ChestTouch;
        UITouch *_fortniteOpen_DoorTouch;
        UITouch *_fortnitePingTouch;
        UITouch *_fortnitePyramid_SelectedTouch;
        UITouch *_fortnitePyramid_UnselectedTouch;
        UITouch *_fortniteQuick_ChatTouch;
        UITouch *_fortniteQuick_HealTouch;
        UITouch *_fortniteRepairTouch;
        UITouch *_fortniteResetTouch;
        UITouch *_fortniteRotateTouch;
        UITouch *_fortniteShoot_BigTouch;
        UITouch *_fortniteShootTouch;
        UITouch *_fortniteStair_SelectedTouch;
        UITouch *_fortniteStair_UnselectedTouch;
        UITouch *_fortniteSwitch_To_BuildTouch;
        UITouch *_fortniteSwitch_To_CombatTouch;
        UITouch *_fortniteThrowTouch;
        UITouch *_fortniteUseTouch;
        UITouch *_fortniteWall_SelectedTouch;
        UITouch *_fortniteWall_UnselectedTouch;

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
                [self drawFortniteButtons]; // Draw forntite buttons when needed. Projected to move to other options.
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
        
    }

    -(void) drawFortniteButtons {

        NSArray *HUDCombatButtonXSaved = [[NSUserDefaults standardUserDefaults] objectForKey:@"reKairosCombatHUDRectX"];
        NSArray *HUDCombatButtonYSaved = [[NSUserDefaults standardUserDefaults] objectForKey:@"reKairosCombatHUDRectY"];
        NSArray *HUDCombatButtonWidthSaved = [[NSUserDefaults standardUserDefaults] objectForKey:@"reKairosCombatHUDRectWidth"];
        NSArray *HUDCombatButtonHeightSaved = [[NSUserDefaults standardUserDefaults] objectForKey:@"reKairosCombatHUDRectHeight"];

        _fortniteAim = [CALayer layer];
        _fortniteAutorun = [CALayer layer];
        _fortniteConfirm = [CALayer layer];
        _fortniteCrouch_Down = [CALayer layer];
        _fortniteCrouch_Up = [CALayer layer];
        _fortniteCycle_Weapons_Down = [CALayer layer];
        _fortniteCycle_Weapons_Up = [CALayer layer];
        _fortniteEdit_Crosshair = [CALayer layer];
        _fortniteEdit_Reset = [CALayer layer];
        _fortniteEdit = [CALayer layer];
        _fortniteEmote_Wheel = [CALayer layer];
        _fortniteExit = [CALayer layer];
        _fortniteFloor_Selected = [CALayer layer];
        _fortniteFloor_Unselected = [CALayer layer];
        _fortniteInventory = [CALayer layer];
        _fortniteJump = [CALayer layer];
        _fortniteMic_Muted = [CALayer layer];
        _fortniteMic_Unmuted = [CALayer layer];
        _fortniteMove_Joystick = [CALayer layer];
        _fortniteMove_Outer = [CALayer layer];
        _fortniteOpen_Chest = [CALayer layer];
        _fortniteOpen_Door = [CALayer layer];
        _fortnitePing = [CALayer layer];
        _fortnitePyramid_Selected = [CALayer layer];
        _fortnitePyramid_Unselected = [CALayer layer];
        _fortniteQuick_Chat = [CALayer layer];
        _fortniteQuick_Heal = [CALayer layer];
        _fortniteRepair = [CALayer layer];
        _fortniteReset = [CALayer layer];
        _fortniteRotate = [CALayer layer];
        _fortniteShoot_Big = [CALayer layer];
        _fortniteShoot = [CALayer layer];
        _fortniteStair_Selected = [CALayer layer];
        _fortniteStair_Unselected = [CALayer layer];
        _fortniteSwitch_To_Build = [CALayer layer];
        _fortniteSwitch_To_Combat = [CALayer layer];
        _fortniteThrow = [CALayer layer];
        _fortniteUse = [CALayer layer];
        _fortniteWall_Selected = [CALayer layer];
        _fortniteWall_Unselected = [CALayer layer];


        UIImage *AimImage = [self imageWithImage:[UIImage imageNamed: @"Aim.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:0] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:0] floatValue])];
        _fortniteAim.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:0] floatValue], [[HUDCombatButtonYSaved objectAtIndex:0] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:0] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:0] floatValue]);
        _fortniteAim.contents = (id) AimImage.CGImage;
        [_view.layer addSublayer:_fortniteAim];

        UIImage *AutorunImage = [self imageWithImage:[UIImage imageNamed: @"Autorun.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:1] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:1] floatValue])];
        _fortniteAutorun.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:1] floatValue], [[HUDCombatButtonYSaved objectAtIndex:1] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:1] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:1] floatValue]);
        _fortniteAutorun.contents = (id) AutorunImage.CGImage;
        [_view.layer addSublayer:_fortniteAutorun];

        UIImage *ConfirmImage = [self imageWithImage:[UIImage imageNamed: @"Confirm.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:2] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:2] floatValue])];
        _fortniteConfirm.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:2] floatValue], [[HUDCombatButtonYSaved objectAtIndex:2] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:2] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:2] floatValue]);
        _fortniteConfirm.contents = (id) ConfirmImage.CGImage;
        [_view.layer addSublayer:_fortniteConfirm];

        UIImage *Crouch_DownImage = [self imageWithImage:[UIImage imageNamed: @"Crouch Down.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:3] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:3] floatValue])];
        _fortniteCrouch_Down.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:3] floatValue], [[HUDCombatButtonYSaved objectAtIndex:3] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:3] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:3] floatValue]);
        _fortniteCrouch_Down.contents = (id) Crouch_DownImage.CGImage;
        [_view.layer addSublayer:_fortniteCrouch_Down];

        UIImage *Crouch_UpImage = [self imageWithImage:[UIImage imageNamed: @"Crouch Up.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:4] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:4] floatValue])];
        _fortniteCrouch_Up.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:4] floatValue], [[HUDCombatButtonYSaved objectAtIndex:4] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:4] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:4] floatValue]);
        _fortniteCrouch_Up.contents = (id) Crouch_UpImage.CGImage;
        [_view.layer addSublayer:_fortniteCrouch_Up];

        UIImage *Cycle_Weapons_DownImage = [self imageWithImage:[UIImage imageNamed: @"Cycle Weapons Down.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:5] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:5] floatValue])];
        _fortniteCycle_Weapons_Down.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:5] floatValue], [[HUDCombatButtonYSaved objectAtIndex:5] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:5] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:5] floatValue]);
        _fortniteCycle_Weapons_Down.contents = (id) Cycle_Weapons_DownImage.CGImage;
        [_view.layer addSublayer:_fortniteCycle_Weapons_Down];

        UIImage *Cycle_Weapons_UpImage = [self imageWithImage:[UIImage imageNamed: @"Cycle Weapons Up.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:6] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:6] floatValue])];
        _fortniteCycle_Weapons_Up.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:6] floatValue], [[HUDCombatButtonYSaved objectAtIndex:6] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:6] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:6] floatValue]);
        _fortniteCycle_Weapons_Up.contents = (id) Cycle_Weapons_UpImage.CGImage;
        [_view.layer addSublayer:_fortniteCycle_Weapons_Up];

        UIImage *Edit_CrosshairImage = [self imageWithImage:[UIImage imageNamed: @"Edit Crosshair.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:7] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:7] floatValue])];
        _fortniteEdit_Crosshair.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:7] floatValue], [[HUDCombatButtonYSaved objectAtIndex:7] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:7] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:7] floatValue]);
        _fortniteEdit_Crosshair.contents = (id) Edit_CrosshairImage.CGImage;
        [_view.layer addSublayer:_fortniteEdit_Crosshair];

        UIImage *Edit_ResetImage = [self imageWithImage:[UIImage imageNamed: @"Edit Reset.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:8] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:8] floatValue])];
        _fortniteEdit_Reset.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:8] floatValue], [[HUDCombatButtonYSaved objectAtIndex:8] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:8] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:8] floatValue]);
        _fortniteEdit_Reset.contents = (id) Edit_ResetImage.CGImage;
        [_view.layer addSublayer:_fortniteEdit_Reset];

        UIImage *EditImage = [self imageWithImage:[UIImage imageNamed: @"Edit.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:9] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:9] floatValue])];
        _fortniteEdit.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:9] floatValue], [[HUDCombatButtonYSaved objectAtIndex:9] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:9] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:9] floatValue]);
        _fortniteEdit.contents = (id) EditImage.CGImage;
        [_view.layer addSublayer:_fortniteEdit];

        UIImage *Emote_WheelImage = [self imageWithImage:[UIImage imageNamed: @"Emote Wheel.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:10] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:10] floatValue])];
        _fortniteEmote_Wheel.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:10] floatValue], [[HUDCombatButtonYSaved objectAtIndex:10] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:10] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:10] floatValue]);
        _fortniteEmote_Wheel.contents = (id) Emote_WheelImage.CGImage;
        [_view.layer addSublayer:_fortniteEmote_Wheel];

        UIImage *ExitImage = [self imageWithImage:[UIImage imageNamed: @"Exit.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:11] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:11] floatValue])];
        _fortniteExit.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:11] floatValue], [[HUDCombatButtonYSaved objectAtIndex:11] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:11] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:11] floatValue]);
        _fortniteExit.contents = (id) ExitImage.CGImage;
        [_view.layer addSublayer:_fortniteExit];

        UIImage *Floor_SelectedImage = [self imageWithImage:[UIImage imageNamed: @"Floor Selected.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:12] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:12] floatValue])];
        _fortniteFloor_Selected.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:12] floatValue], [[HUDCombatButtonYSaved objectAtIndex:12] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:12] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:12] floatValue]);
        _fortniteFloor_Selected.contents = (id) Floor_SelectedImage.CGImage;
        [_view.layer addSublayer:_fortniteFloor_Selected];

        UIImage *Floor_UnselectedImage = [self imageWithImage:[UIImage imageNamed: @"Floor Unselected.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:13] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:13] floatValue])];
        _fortniteFloor_Unselected.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:13] floatValue], [[HUDCombatButtonYSaved objectAtIndex:13] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:13] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:13] floatValue]);
        _fortniteFloor_Unselected.contents = (id) Floor_UnselectedImage.CGImage;
        [_view.layer addSublayer:_fortniteFloor_Unselected];

        UIImage *InventoryImage = [self imageWithImage:[UIImage imageNamed: @"Inventory.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:14] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:14] floatValue])];
        _fortniteInventory.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:14] floatValue], [[HUDCombatButtonYSaved objectAtIndex:14] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:14] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:14] floatValue]);
        _fortniteInventory.contents = (id) InventoryImage.CGImage;
        [_view.layer addSublayer:_fortniteInventory];

        UIImage *JumpImage = [self imageWithImage:[UIImage imageNamed: @"Jump.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:15] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:15] floatValue])];
        _fortniteJump.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:15] floatValue], [[HUDCombatButtonYSaved objectAtIndex:15] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:15] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:15] floatValue]);
        _fortniteJump.contents = (id) JumpImage.CGImage;
        [_view.layer addSublayer:_fortniteJump];

        UIImage *Mic_MutedImage = [self imageWithImage:[UIImage imageNamed: @"Mic Muted.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:16] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:16] floatValue])];
        _fortniteMic_Muted.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:16] floatValue], [[HUDCombatButtonYSaved objectAtIndex:16] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:16] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:16] floatValue]);
        _fortniteMic_Muted.contents = (id) Mic_MutedImage.CGImage;
        [_view.layer addSublayer:_fortniteMic_Muted];

        UIImage *Mic_UnmutedImage = [self imageWithImage:[UIImage imageNamed: @"Mic Unmuted.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:17] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:17] floatValue])];
        _fortniteMic_Unmuted.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:17] floatValue], [[HUDCombatButtonYSaved objectAtIndex:17] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:17] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:17] floatValue]);
        _fortniteMic_Unmuted.contents = (id) Mic_UnmutedImage.CGImage;
        [_view.layer addSublayer:_fortniteMic_Unmuted];

        UIImage *Move_JoystickImage = [self imageWithImage:[UIImage imageNamed: @"Move Joystick.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:18] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:18] floatValue])];
        _fortniteMove_Joystick.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:18] floatValue], [[HUDCombatButtonYSaved objectAtIndex:18] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:18] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:18] floatValue]);
        _fortniteMove_Joystick.contents = (id) Move_JoystickImage.CGImage;
        [_view.layer addSublayer:_fortniteMove_Joystick];

        UIImage *Move_OuterImage = [self imageWithImage:[UIImage imageNamed: @"Move Outer.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:19] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:19] floatValue])];
        _fortniteMove_Outer.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:19] floatValue], [[HUDCombatButtonYSaved objectAtIndex:19] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:19] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:19] floatValue]);
        _fortniteMove_Outer.contents = (id) Move_OuterImage.CGImage;
        [_view.layer addSublayer:_fortniteMove_Outer];

        UIImage *Open_ChestImage = [self imageWithImage:[UIImage imageNamed: @"Open Chest.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:20] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:20] floatValue])];
        _fortniteOpen_Chest.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:20] floatValue], [[HUDCombatButtonYSaved objectAtIndex:20] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:20] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:20] floatValue]);
        _fortniteOpen_Chest.contents = (id) Open_ChestImage.CGImage;
        [_view.layer addSublayer:_fortniteOpen_Chest];

        UIImage *Open_DoorImage = [self imageWithImage:[UIImage imageNamed: @"Open Door.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:21] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:21] floatValue])];
        _fortniteOpen_Door.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:21] floatValue], [[HUDCombatButtonYSaved objectAtIndex:21] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:21] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:21] floatValue]);
        _fortniteOpen_Door.contents = (id) Open_DoorImage.CGImage;
        [_view.layer addSublayer:_fortniteOpen_Door];

        UIImage *PingImage = [self imageWithImage:[UIImage imageNamed: @"Ping.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:22] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:22] floatValue])];
        _fortnitePing.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:22] floatValue], [[HUDCombatButtonYSaved objectAtIndex:22] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:22] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:22] floatValue]);
        _fortnitePing.contents = (id) PingImage.CGImage;
        [_view.layer addSublayer:_fortnitePing];

        UIImage *Pyramid_SelectedImage = [self imageWithImage:[UIImage imageNamed: @"Pyramid Selected.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:23] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:23] floatValue])];
        _fortnitePyramid_Selected.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:23] floatValue], [[HUDCombatButtonYSaved objectAtIndex:23] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:23] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:23] floatValue]);
        _fortnitePyramid_Selected.contents = (id) Pyramid_SelectedImage.CGImage;
        [_view.layer addSublayer:_fortnitePyramid_Selected];

        UIImage *Pyramid_UnselectedImage = [self imageWithImage:[UIImage imageNamed: @"Pyramid Unselected.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:24] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:24] floatValue])];
        _fortnitePyramid_Unselected.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:24] floatValue], [[HUDCombatButtonYSaved objectAtIndex:24] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:24] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:24] floatValue]);
        _fortnitePyramid_Unselected.contents = (id) Pyramid_UnselectedImage.CGImage;
        [_view.layer addSublayer:_fortnitePyramid_Unselected];

        UIImage *Quick_ChatImage = [self imageWithImage:[UIImage imageNamed: @"Quick Chat.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:25] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:25] floatValue])];
        _fortniteQuick_Chat.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:25] floatValue], [[HUDCombatButtonYSaved objectAtIndex:25] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:25] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:25] floatValue]);
        _fortniteQuick_Chat.contents = (id) Quick_ChatImage.CGImage;
        [_view.layer addSublayer:_fortniteQuick_Chat];

        UIImage *Quick_HealImage = [self imageWithImage:[UIImage imageNamed: @"Quick Heal.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:26] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:26] floatValue])];
        _fortniteQuick_Heal.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:26] floatValue], [[HUDCombatButtonYSaved objectAtIndex:26] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:26] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:26] floatValue]);
        _fortniteQuick_Heal.contents = (id) Quick_HealImage.CGImage;
        [_view.layer addSublayer:_fortniteQuick_Heal];

        UIImage *RepairImage = [self imageWithImage:[UIImage imageNamed: @"Repair.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:27] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:27] floatValue])];
        _fortniteRepair.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:27] floatValue], [[HUDCombatButtonYSaved objectAtIndex:27] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:27] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:27] floatValue]);
        _fortniteRepair.contents = (id) RepairImage.CGImage;
        [_view.layer addSublayer:_fortniteRepair];

        UIImage *ResetImage = [self imageWithImage:[UIImage imageNamed: @"Reset.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:28] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:28] floatValue])];
        _fortniteReset.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:28] floatValue], [[HUDCombatButtonYSaved objectAtIndex:28] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:28] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:28] floatValue]);
        _fortniteReset.contents = (id) ResetImage.CGImage;
        [_view.layer addSublayer:_fortniteReset];

        UIImage *RotateImage = [self imageWithImage:[UIImage imageNamed: @"Rotate.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:29] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:29] floatValue])];
        _fortniteRotate.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:29] floatValue], [[HUDCombatButtonYSaved objectAtIndex:29] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:29] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:29] floatValue]);
        _fortniteRotate.contents = (id) RotateImage.CGImage;
        [_view.layer addSublayer:_fortniteRotate];

        UIImage *Shoot_BigImage = [self imageWithImage:[UIImage imageNamed: @"Shoot Big.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:30] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:30] floatValue])];
        _fortniteShoot_Big.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:30] floatValue], [[HUDCombatButtonYSaved objectAtIndex:30] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:30] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:30] floatValue]);
        _fortniteShoot_Big.contents = (id) Shoot_BigImage.CGImage;
        [_view.layer addSublayer:_fortniteShoot_Big];

        UIImage *ShootImage = [self imageWithImage:[UIImage imageNamed: @"Shoot.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:31] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:31] floatValue])];
        _fortniteShoot.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:31] floatValue], [[HUDCombatButtonYSaved objectAtIndex:31] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:31] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:31] floatValue]);
        _fortniteShoot.contents = (id) ShootImage.CGImage;
        [_view.layer addSublayer:_fortniteShoot];

        UIImage *Stair_SelectedImage = [self imageWithImage:[UIImage imageNamed: @"Stair Selected.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:32] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:32] floatValue])];
        _fortniteStair_Selected.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:32] floatValue], [[HUDCombatButtonYSaved objectAtIndex:32] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:32] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:32] floatValue]);
        _fortniteStair_Selected.contents = (id) Stair_SelectedImage.CGImage;
        [_view.layer addSublayer:_fortniteStair_Selected];

        UIImage *Stair_UnselectedImage = [self imageWithImage:[UIImage imageNamed: @"Stair Unselected.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:33] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:33] floatValue])];
        _fortniteStair_Unselected.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:33] floatValue], [[HUDCombatButtonYSaved objectAtIndex:33] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:33] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:33] floatValue]);
        _fortniteStair_Unselected.contents = (id) Stair_UnselectedImage.CGImage;
        [_view.layer addSublayer:_fortniteStair_Unselected];

        UIImage *Switch_To_BuildImage = [self imageWithImage:[UIImage imageNamed: @"Switch To Build.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:34] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:34] floatValue])];
        _fortniteSwitch_To_Build.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:34] floatValue], [[HUDCombatButtonYSaved objectAtIndex:34] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:34] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:34] floatValue]);
        _fortniteSwitch_To_Build.contents = (id) Switch_To_BuildImage.CGImage;
        [_view.layer addSublayer:_fortniteSwitch_To_Build];

        UIImage *Switch_To_CombatImage = [self imageWithImage:[UIImage imageNamed: @"Switch To Combat.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:35] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:35] floatValue])];
        _fortniteSwitch_To_Combat.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:35] floatValue], [[HUDCombatButtonYSaved objectAtIndex:35] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:35] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:35] floatValue]);
        _fortniteSwitch_To_Combat.contents = (id) Switch_To_CombatImage.CGImage;
        [_view.layer addSublayer:_fortniteSwitch_To_Combat];

        UIImage *ThrowImage = [self imageWithImage:[UIImage imageNamed: @"Throw.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:36] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:36] floatValue])];
        _fortniteThrow.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:36] floatValue], [[HUDCombatButtonYSaved objectAtIndex:36] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:36] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:36] floatValue]);
        _fortniteThrow.contents = (id) ThrowImage.CGImage;
        [_view.layer addSublayer:_fortniteThrow];

        UIImage *UseImage = [self imageWithImage:[UIImage imageNamed: @"Use.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:37] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:37] floatValue])];
        _fortniteUse.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:37] floatValue], [[HUDCombatButtonYSaved objectAtIndex:37] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:37] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:37] floatValue]);
        _fortniteUse.contents = (id) UseImage.CGImage;
        [_view.layer addSublayer:_fortniteUse];

        UIImage *Wall_SelectedImage = [self imageWithImage:[UIImage imageNamed: @"Wall Selected.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:38] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:38] floatValue])];
        _fortniteWall_Selected.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:38] floatValue], [[HUDCombatButtonYSaved objectAtIndex:38] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:38] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:38] floatValue]);
        _fortniteWall_Selected.contents = (id) Wall_SelectedImage.CGImage;
        [_view.layer addSublayer:_fortniteWall_Selected];

        UIImage *Wall_UnselectedImage = [self imageWithImage:[UIImage imageNamed: @"Wall Unselected.png"] scaledToFillSize:CGSizeMake([[HUDCombatButtonWidthSaved objectAtIndex:39] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:39] floatValue])];
        _fortniteWall_Unselected.frame = CGRectMake([[HUDCombatButtonXSaved objectAtIndex:39] floatValue], [[HUDCombatButtonYSaved objectAtIndex:39] floatValue], [[HUDCombatButtonWidthSaved objectAtIndex:39] floatValue], [[HUDCombatButtonHeightSaved objectAtIndex:39] floatValue]);
        _fortniteWall_Unselected.contents = (id) Wall_UnselectedImage.CGImage;
        [_view.layer addSublayer:_fortniteWall_Unselected];
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
            }
            else if (touch == _fortniteAimTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortniteAutorunTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortniteConfirmTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortniteCrouch_DownTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortniteCrouch_UpTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortniteCycle_Weapons_DownTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortniteCycle_Weapons_UpTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortniteEdit_CrosshairTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortniteEdit_ResetTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortniteEditTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortniteEmote_WheelTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortniteExitTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortniteFloor_SelectedTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortniteFloor_UnselectedTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortniteInventoryTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortniteJumpTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortniteMic_MutedTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortniteMic_UnmutedTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortniteMove_JoystickTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortniteMove_OuterTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortniteOpen_ChestTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortniteOpen_DoorTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortnitePingTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortnitePyramid_SelectedTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortnitePyramid_UnselectedTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortniteQuick_ChatTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortniteQuick_HealTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortniteRepairTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortniteResetTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortniteRotateTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortniteShoot_BigTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortniteShootTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortniteStair_SelectedTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortniteStair_UnselectedTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortniteSwitch_To_BuildTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortniteSwitch_To_CombatTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortniteThrowTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortniteUseTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortniteWall_SelectedTouch) {
                buttonTouch = true;
            }
            else if (touch == _fortniteWall_UnselectedTouch) {
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
            }
            else if([_fortniteAim.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport updateLeftTrigger:_controller left:0xFF];
                _fortniteAimTouch = touch;
                updated = true;
            }
            else if([_fortniteAutorun.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
                _fortniteAutorunTouch = touch;
                updated = true;
            }
            else if([_fortniteConfirm.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
                _fortniteConfirmTouch = touch;
                updated = true;
            }
            else if([_fortniteCrouch_Down.presentationLayer hitTest:touchLocation]) {
                // [_controllerSupport setButtonFlag:_controller flags:RIGHT_FLAG];
                [_controllerSupport setButtonFlag:_controller flags:RS_CLK_FLAG];
                _fortniteCrouch_DownTouch = touch;
                updated = true;
            }
            else if([_fortniteCrouch_Up.presentationLayer hitTest:touchLocation]) {
                //[_controllerSupport setButtonFlag:_controller flags:RIGHT_FLAG];
                [_controllerSupport setButtonFlag:_controller flags:RS_CLK_FLAG];
                _fortniteCrouch_UpTouch = touch;
                updated = true;
            }
            else if([_fortniteCycle_Weapons_Down.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
                _fortniteCycle_Weapons_DownTouch = touch;
                updated = true;
            }
            else if([_fortniteCycle_Weapons_Up.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
                _fortniteCycle_Weapons_UpTouch = touch;
                updated = true;
            }
            else if([_fortniteEdit_Crosshair.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
                _fortniteEdit_CrosshairTouch = touch;
                updated = true;
            }
            else if([_fortniteEdit_Reset.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
                _fortniteEdit_ResetTouch = touch;
                updated = true;
            }
            else if([_fortniteEdit.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
                _fortniteEditTouch = touch;
                updated = true;
            }
            else if([_fortniteEmote_Wheel.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
                _fortniteEmote_WheelTouch = touch;
                updated = true;
            }
            else if([_fortniteExit.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
                _fortniteExitTouch = touch;
                updated = true;
            }
            else if([_fortniteFloor_Selected.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
                _fortniteFloor_SelectedTouch = touch;
                updated = true;
            }
            else if([_fortniteFloor_Unselected.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
                _fortniteFloor_UnselectedTouch = touch;
                updated = true;
            }
            else if([_fortniteInventory.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
                _fortniteInventoryTouch = touch;
                updated = true;
            }
            else if([_fortniteJump.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
                _fortniteJumpTouch = touch;
                updated = true;
            }
            else if([_fortniteMic_Muted.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
                _fortniteMic_MutedTouch = touch;
                updated = true;
            }
            else if([_fortniteMic_Unmuted.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
                _fortniteMic_UnmutedTouch = touch;
                updated = true;
            }
            else if([_fortniteMove_Joystick.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
                _fortniteMove_JoystickTouch = touch;
                updated = true;
            }
            else if([_fortniteMove_Outer.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
                _fortniteMove_OuterTouch = touch;
                updated = true;
            }
            else if([_fortniteOpen_Chest.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
                _fortniteOpen_ChestTouch = touch;
                updated = true;
            }
            else if([_fortniteOpen_Door.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
                _fortniteOpen_DoorTouch = touch;
                updated = true;
            }
            else if([_fortnitePing.presentationLayer hitTest:touchLocation]) {
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
            else if([_fortnitePyramid_Selected.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
                _fortnitePyramid_SelectedTouch = touch;
                updated = true;
            }
            else if([_fortnitePyramid_Unselected.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
                _fortnitePyramid_UnselectedTouch = touch;
                updated = true;
            }
            else if([_fortniteQuick_Chat.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
                _fortniteQuick_ChatTouch = touch;
                updated = true;
            }
            else if([_fortniteQuick_Heal.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
                _fortniteQuick_HealTouch = touch;
                updated = true;
            }
            else if([_fortniteRepair.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
                _fortniteRepairTouch = touch;
                updated = true;
            }
            else if([_fortniteReset.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
                _fortniteResetTouch = touch;
                updated = true;
            }
            else if([_fortniteRotate.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
                _fortniteRotateTouch = touch;
                updated = true;
            }
            else if([_fortniteShoot_Big.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport updateRightTrigger:_controller right:0xFF];
                _fortniteShoot_BigTouch = touch;
                updated = true;
            }
            else if([_fortniteShoot.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport updateRightTrigger:_controller right:0xFF];
                _fortniteShootTouch = touch;
                updated = true;
            }
            else if([_fortniteStair_Selected.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
                _fortniteStair_SelectedTouch = touch;
                updated = true;
            }
            else if([_fortniteStair_Unselected.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
                _fortniteStair_UnselectedTouch = touch;
                updated = true;
            }
            else if([_fortniteSwitch_To_Build.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport setButtonFlag:_controller flags:B_FLAG];
                _fortniteSwitch_To_BuildTouch = touch;
                updated = true;
            }
            else if([_fortniteSwitch_To_Combat.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport setButtonFlag:_controller flags:B_FLAG];
                _fortniteSwitch_To_CombatTouch = touch;
                updated = true;
            }
            else if([_fortniteThrow.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
                _fortniteThrowTouch = touch;
                updated = true;
            }
            else if([_fortniteUse.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
                _fortniteUseTouch = touch;
                updated = true;
            }
            else if([_fortniteWall_Selected.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
                _fortniteWall_SelectedTouch = touch;
                updated = true;
            }
            else if([_fortniteWall_Unselected.presentationLayer hitTest:touchLocation]) {
                [_controllerSupport setButtonFlag:_controller flags:A_FLAG];
                _fortniteWall_UnselectedTouch = touch;
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
            }
            else if (touch == _fortniteAimTouch) {
                [_controllerSupport updateLeftTrigger:_controller left:0];
                _fortniteAimTouch = nil;
                updated = true;
            }
            else if (touch == _fortniteAutorunTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
                _fortniteAutorunTouch = nil;
                updated = true;
            }
            else if (touch == _fortniteConfirmTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
                _fortniteConfirmTouch = nil;
                updated = true;
            }
            else if (touch == _fortniteCrouch_DownTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:RS_CLK_FLAG];
                _fortniteCrouch_DownTouch = nil;
                updated = true;
            }
            else if (touch == _fortniteCrouch_UpTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:RS_CLK_FLAG];
                _fortniteCrouch_UpTouch = nil;
                updated = true;
            }
            else if (touch == _fortniteCycle_Weapons_DownTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
                _fortniteCycle_Weapons_DownTouch = nil;
                updated = true;
            }
            else if (touch == _fortniteCycle_Weapons_UpTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
                _fortniteCycle_Weapons_UpTouch = nil;
                updated = true;
            }
            else if (touch == _fortniteEdit_CrosshairTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
                _fortniteEdit_CrosshairTouch = nil;
                updated = true;
            }
            else if (touch == _fortniteEdit_ResetTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
                _fortniteEdit_ResetTouch = nil;
                updated = true;
            }
            else if (touch == _fortniteEditTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
                _fortniteEditTouch = nil;
                updated = true;
            }
            else if (touch == _fortniteEmote_WheelTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
                _fortniteEmote_WheelTouch = nil;
                updated = true;
            }
            else if (touch == _fortniteExitTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
                _fortniteExitTouch = nil;
                updated = true;
            }
            else if (touch == _fortniteFloor_SelectedTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
                _fortniteFloor_SelectedTouch = nil;
                updated = true;
            }
            else if (touch == _fortniteFloor_UnselectedTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
                _fortniteFloor_UnselectedTouch = nil;
                updated = true;
            }
            else if (touch == _fortniteInventoryTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
                _fortniteInventoryTouch = nil;
                updated = true;
            }
            else if (touch == _fortniteJumpTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
                _fortniteJumpTouch = nil;
                updated = true;
            }
            else if (touch == _fortniteMic_MutedTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
                _fortniteMic_MutedTouch = nil;
                updated = true;
            }
            else if (touch == _fortniteMic_UnmutedTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
                _fortniteMic_UnmutedTouch = nil;
                updated = true;
            }
            else if (touch == _fortniteMove_JoystickTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
                _fortniteMove_JoystickTouch = nil;
                updated = true;
            }
            else if (touch == _fortniteMove_OuterTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
                _fortniteMove_OuterTouch = nil;
                updated = true;
            }
            else if (touch == _fortniteOpen_ChestTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
                _fortniteOpen_ChestTouch = nil;
                updated = true;
            }
            else if (touch == _fortniteOpen_DoorTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
                _fortniteOpen_DoorTouch = nil;
                updated = true;
            }
            else if (touch == _fortnitePingTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
                _fortnitePingTouch = nil;
                updated = true;
            }
            else if (touch == _fortnitePyramid_SelectedTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
                _fortnitePyramid_SelectedTouch = nil;
                updated = true;
            }
            else if (touch == _fortnitePyramid_UnselectedTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
                _fortnitePyramid_UnselectedTouch = nil;
                updated = true;
            }
            else if (touch == _fortniteQuick_ChatTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
                _fortniteQuick_ChatTouch = nil;
                updated = true;
            }
            else if (touch == _fortniteQuick_HealTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
                _fortniteQuick_HealTouch = nil;
                updated = true;
            }
            else if (touch == _fortniteRepairTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
                _fortniteRepairTouch = nil;
                updated = true;
            }
            else if (touch == _fortniteResetTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
                _fortniteResetTouch = nil;
                updated = true;
            }
            else if (touch == _fortniteRotateTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
                _fortniteRotateTouch = nil;
                updated = true;
            }
            else if (touch == _fortniteShoot_BigTouch) {
                //[_controllerSupport updateRightTrigger:_controller right:0xFF];
                [_controllerSupport updateRightTrigger:_controller right:0];
                _fortniteShoot_BigTouch = nil;
                updated = true;
            }
            else if (touch == _fortniteShootTouch) {
                //[_controllerSupport updateRightTrigger:_controller right:0xFF];
                [_controllerSupport updateRightTrigger:_controller right:0];
                _fortniteShootTouch = nil;
                updated = true;
            }
            else if (touch == _fortniteStair_SelectedTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
                _fortniteStair_SelectedTouch = nil;
                updated = true;
            }
            else if (touch == _fortniteStair_UnselectedTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
                _fortniteStair_UnselectedTouch = nil;
                updated = true;
            }
            else if (touch == _fortniteSwitch_To_BuildTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:B_FLAG];
                _fortniteSwitch_To_BuildTouch = nil;
                updated = true;
            }
            else if (touch == _fortniteSwitch_To_CombatTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:B_FLAG];
                _fortniteSwitch_To_CombatTouch = nil;
                updated = true;
            }
            else if (touch == _fortniteThrowTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
                _fortniteThrowTouch = nil;
                updated = true;
            }
            else if (touch == _fortniteUseTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
                _fortniteUseTouch = nil;
                updated = true;
            }
            else if (touch == _fortniteWall_SelectedTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
                _fortniteWall_SelectedTouch = nil;
                updated = true;
            }
            else if (touch == _fortniteWall_UnselectedTouch) {
                [_controllerSupport clearButtonFlag:_controller flags:A_FLAG];
                _fortniteWall_UnselectedTouch = nil;
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

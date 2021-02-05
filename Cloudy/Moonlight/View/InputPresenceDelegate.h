// Copyright (c) 2021 Nomad5. All rights reserved.

#import <Foundation/Foundation.h>

@protocol InputPresenceDelegate <NSObject>

    - (void)gamepadPresenceChanged;

    - (void)mousePresenceChanged;

@end
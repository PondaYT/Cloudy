// Copyright (c) 2021 Nomad5. All rights reserved.

#import <Foundation/Foundation.h>

@protocol UserInteractionDelegate <NSObject>

    - (void)userInteractionBegan;

    - (void)userInteractionEnded;

@end
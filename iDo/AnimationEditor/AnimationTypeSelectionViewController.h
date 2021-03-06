//
//  AnimationTypeSelectionViewController.h
//  iDo
//
//  Created by Huang Hongsen on 12/12/14.
//  Copyright (c) 2014 com.microstrategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnimationEditorManager.h"
#import "AnimationDescription.h"
@protocol AnimationTypeSelectionViewControllerDelegate
- (void) animationEditorDidSelectAnimation:(AnimationDescription *) animation;
- (void) animationEditorInitializedWithAnimation:(AnimationDescription *) animation;
@end
@interface AnimationTypeSelectionViewController : UIViewController

@property (nonatomic) AnimationEvent animationEvent;
@property (nonatomic) AnimationEffect animationEffect;
@property (nonatomic, weak) UIView *animationTarget;
@property (nonatomic, weak) id<AnimationTypeSelectionViewControllerDelegate> delegate;
@end

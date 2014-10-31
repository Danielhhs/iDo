//
//  GenericContainerView.h
//  iDo
//
//  Created by Huang Hongsen on 10/14/14.
//  Copyright (c) 2014 com.microstrategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ControlPointManager.h"

@class GenericContainerView;
@class ReflectionView;

@protocol ContentContainerViewDelegate <NSObject>

- (void) contentViewWillBecomFirstResponder:(GenericContainerView *) contentView;

- (void) contentViewDidBecomFirstResponder:(GenericContainerView *) contentView;

- (void) contentViewWillResignFirstResponder:(GenericContainerView *) contentView;

- (void) contentViewDidResignFirstResponder:(GenericContainerView *) contentView;

- (void) contentView:(GenericContainerView *) contentView
 didChangeAttributes: (NSDictionary *) attributes;
@end

@interface GenericContainerView : UIView

@property (nonatomic, strong) ReflectionView *reflection;
@property (nonatomic) BOOL showShadow;

@property (nonatomic, weak) id<ContentContainerViewDelegate> delegate;
- (NSDictionary *) attributes;

- (instancetype) initWithAttributes:(NSDictionary *) attributes;

- (CGSize) minSize;

- (BOOL) isContentFirstResponder;

- (CGRect) contentViewFrame;

- (UIImage *) contentSnapshot;

- (void) addSubViews;

- (void) applyAttributes:(NSDictionary *) attributes;

- (void) addReflectionView;

- (void) updateReflectionView;

- (void) updateEditingStatus;

- (void) hideRotationIndicator;

- (CGRect) originalContentFrame;

@end

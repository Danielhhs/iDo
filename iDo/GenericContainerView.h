//
//  GenericContainerView.h
//  iDo
//
//  Created by Huang Hongsen on 10/14/14.
//  Copyright (c) 2014 com.microstrategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ControlPointManager.h"
#import "Operation.h"

@class GenericContainerView;
@class ReflectionView;

@protocol ContentContainerViewDelegate <NSObject>

- (void) contentViewWillBecomFirstResponder:(GenericContainerView *) contentView;

- (void) contentViewDidBecomFirstResponder:(GenericContainerView *) contentView;

- (void) contentViewDidResignFirstResponder:(GenericContainerView *) contentView;

- (void) contentView:(GenericContainerView *) contentView
 didChangeAttributes: (NSDictionary *) attributes;

- (void) contentView:(GenericContainerView *) contentView
startChangingAttributes:(NSDictionary *) attribtues;

- (void) frameDidChangeForContentView:(GenericContainerView *) contentView;

- (void) contentView:(GenericContainerView *) content willBeAddedToView:(UIView *) canvas;

- (void) contentView:(GenericContainerView *) content didRemoveFromView:(UIView *) canvas;

- (void) contentViewDidPerformUndoRedoOperation:(GenericContainerView *) content;

@optional
- (void) contentViewWillResignFirstResponder:(GenericContainerView *) contentView;
@end

@interface GenericContainerView : UIView<OperationTarget>

@property (nonatomic, strong) ReflectionView *reflection;
@property (nonatomic, strong) UIView *shadow;
@property (nonatomic, weak) id<ContentContainerViewDelegate> delegate;

- (NSMutableDictionary *) attributes;

- (instancetype) initWithAttributes:(NSDictionary *) attributes delegate:(id<ContentContainerViewDelegate>)delegate;

- (CGSize) minSize;

- (BOOL) isContentFirstResponder;

- (CGRect) contentViewFrameFromBounds:(CGRect) bounds;

- (UIImage *) contentSnapshot;

- (void) addSubViews;

- (void) applyAttributes:(NSDictionary *) attributes;

- (void) updateReflectionView;

- (void) updateEditingStatus;

- (void) hideRotationIndicator;

- (void) pushUnsavedOperation;

- (UIView *) contentView;
@end

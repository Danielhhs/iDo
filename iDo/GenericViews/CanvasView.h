//
//  CanvasView.h
//  iDo
//
//  Created by Huang Hongsen on 10/31/14.
//  Copyright (c) 2014 com.microstrategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericContainerView.h"
@class CanvasView;
@protocol CanvasViewDelegate <NSObject>

- (void) userDidTapInCanvas:(CanvasView *) canvas;

@end

@interface CanvasView : UIView

@property (nonatomic, strong) UIImage *background;
@property (nonatomic, strong) NSMutableArray *animations;
@property (nonatomic, weak) id<CanvasViewDelegate> delegate;

- (instancetype) initWithAttributes:(NSDictionary *) attributes
                           delegate:(id<CanvasViewDelegate>) delegate
                    contentDelegate:(id<ContentContainerViewDelegate>)contentDelegate;
- (void) setupWithAttributes:(NSDictionary *) attribtues;
- (void) disablePinch;
- (void) enablePinch;
@end

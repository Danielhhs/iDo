//
//  CustomTapTextView.h
//  iDo
//
//  Created by Huang Hongsen on 11/2/14.
//  Copyright (c) 2014 com.microstrategy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CustomTapTextView;

@protocol CustomTapTextViewDelegate <UITextViewDelegate>

- (void) textView:(CustomTapTextView *)textView didSelectFont:(UIFont *) font;

@end

@interface CustomTapTextView : UITextView

@property (nonatomic, weak) id<CustomTapTextViewDelegate> delegate;

- (instancetype) initWithFrame:(CGRect)frame attributes:(NSDictionary *) attributes;

- (void) readyToEdit;
- (void) finishEditing;

@end

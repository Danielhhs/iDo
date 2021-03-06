//
//  CustomTapTextView.m
//  iDo
//
//  Created by Huang Hongsen on 11/2/14.
//  Copyright (c) 2014 com.microstrategy. All rights reserved.
//

#import "CustomTapTextView.h"
#import "GenericContainerViewHelper.h"
#import "KeyConstants.h"
#import "CoreTextHelper.h"
#import "EditMenuManager.h"

@interface CustomTapTextView()
@property (nonatomic, strong) UITapGestureRecognizer *tapToEdit;
@property (nonatomic, strong) UITapGestureRecognizer *tapToLocate;
@end

@implementation CustomTapTextView
#pragma mark - Set Up
- (void) setupWithAttributes:(TextContentDTO *) attributes
{
    self.backgroundColor = attributes.backgroundColor;
    self.editable = NO;
    self.selectable = NO;
    
    self.tapToEdit = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapToEdit:)];
    self.tapToEdit.numberOfTapsRequired = 2;
    self.attributedText = attributes.attributedString;
    self.scrollEnabled = NO;
    self.allowsEditingTextAttributes = YES;
    self.tapToLocate = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapToLocate:)];
    self.tapToLocate.numberOfTapsRequired = 1;
}

- (instancetype) initWithFrame:(CGRect)frame attributes:(TextContentDTO *) attributes
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupWithAttributes:attributes];
    }
    return self;
}

#pragma mark - User Interaction
- (void) handleTapToEdit:(UITapGestureRecognizer *) tap
{
    self.editable = YES;
    self.selectable = YES;
    [self becomeFirstResponder];
    [[EditMenuManager sharedManager] hideEditMenu];
    [self removeGestureRecognizer:self.tapToEdit];
    [self addGestureRecognizer:self.tapToLocate];
}

- (void) handleTapToLocate:(UITapGestureRecognizer *) tap
{
    [self.delegate textViewWillChangeSelection:self];
    NSLayoutManager *layoutManager = [self layoutManager];
    CGPoint location = [tap locationInView:self];
    location.x -= self.textContainerInset.left;
    location.y -= self.textContainerInset.top;
    
    NSUInteger characterIndex = [layoutManager characterIndexForPoint:location inTextContainer:self.textContainer fractionOfDistanceBetweenInsertionPoints:NULL];
    if (characterIndex < [self.textStorage length]) {
        self.selectedRange = NSMakeRange(characterIndex + 1, 0);
    }
    NSRange range;
    if (characterIndex == 0) {
        range = NSMakeRange(characterIndex, 1);
    } else {
        range = NSMakeRange(characterIndex - 1, 1);
    }
    if (characterIndex > 0) {
        characterIndex = characterIndex - 1;
    }
    UIFont *font = [[self.attributedText attributesAtIndex:characterIndex effectiveRange:&range] objectForKey:NSFontAttributeName];
    [self.delegate textView:self didSelectFont:font];
}

- (void) readyToEdit
{
    [self addGestureRecognizer:self.tapToEdit];
}

- (void) finishEditing
{
    [self removeGestureRecognizer:self.tapToEdit];
    [self removeGestureRecognizer:self.tapToLocate];
    self.editable = NO;
    self.selectable = NO;
    [self resignFirstResponder];
}

- (void) setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    [self.delegate textViewDidChangeAttributedText:self];
}

@end

//
//  ImageContainerView.m
//  iDo
//
//  Created by Huang Hongsen on 10/15/14.
//  Copyright (c) 2014 com.microstrategy. All rights reserved.
//

#import "ImageContainerView.h"
#import "UIView+Snapshot.h"

#define DEFAULT_IMAGE_EDGE 300

@interface ImageContainerView()
@property (nonatomic, strong) UIImageView *imageContent;
@end

@implementation ImageContainerView

- (instancetype) initWithImage:(UIImage *)image
{
    CGFloat scale = image.size.width / image.size.height;
    CGFloat width = scale > 1 ? DEFAULT_IMAGE_EDGE : DEFAULT_IMAGE_EDGE / scale;
    CGFloat height = scale > 1 ? DEFAULT_IMAGE_EDGE : DEFAULT_IMAGE_EDGE / scale;
    self = [super initWithFrame:CGRectMake(0, 0, width, height)];
    if (self) {
        _image = image;
        [self setUpImageContentWithImage:image];
        [self addSubViews];
    }
    return self;
}

- (void) setUpImageContentWithImage:(UIImage *) image
{
    self.imageContent = [[UIImageView alloc] initWithImage:image];
    self.imageContent.frame = [self contentViewFrame];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeImage:)];
    [self.imageContent addGestureRecognizer:doubleTap];
}

- (void) setImage:(UIImage *)image
{
    _image = image;
    self.imageContent.image = image;
}

- (void) addSubViews
{
    [self addSubview:self.imageContent];
    [super addSubViews];
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.imageContent.frame = [self contentViewFrame];
}

#pragma mark - User Interactions

- (BOOL) resignFirstResponder
{
    BOOL result = [super resignFirstResponder];
    [self.imageContent setUserInteractionEnabled:NO];
    [self.delegate contentViewDidResignFirstResponder:self];
    return result;
}

- (BOOL) becomeFirstResponder
{
    BOOL result = [super becomeFirstResponder];
    [self.imageContent setUserInteractionEnabled:YES];
    [self.delegate contentViewDidBecomFirstResponder:self];
    [self updateEditingStatus];
    return result;
}

- (void) changeImage:(UITapGestureRecognizer *) tap
{
    [self.delegate handleTapOnImage:self];
}

- (UIImage *) contentSnapshot
{
    return [self.imageContent snapshot];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
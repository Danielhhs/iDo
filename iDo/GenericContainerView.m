//
//  GenericContainerView.m
//  iDo
//
//  Created by Huang Hongsen on 10/14/14.
//  Copyright (c) 2014 com.microstrategy. All rights reserved.
//

#import "GenericContainerView.h"
#import "ReflectionView.h"
#import "ShadowHelper.h"
#import "RotationHelper.h"
#import "GenericContainerViewHelper.h"
#import "KeyConstants.h"
#import "UndoManager.h"
#import "SimpleOperation.h"
#import "CompoundOperation.h"
#import "DrawingConstants.h"
#import "ReflectionHelper.h"
@interface GenericContainerView()
@property (nonatomic) BOOL showBorder;;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@property (nonatomic, strong) UIRotationGestureRecognizer *rotation;
@property (nonatomic, strong) NSMutableDictionary *fullAttributes;
@property (nonatomic, strong) RotationIndicatorView *rotationIndicator;
@property (nonatomic, strong) Operation *currentOperation;
@property (nonatomic) CGPoint originalCenter;
@end

@implementation GenericContainerView

#pragma mark - Set Up
- (instancetype) initWithAttributes:(NSMutableDictionary *)attributes delegate:(id<ContentContainerViewDelegate>)delegate
{
    CGRect frameValue = [GenericContainerViewHelper frameFromAttributes:attributes];
    self = [self initWithFrame:frameValue];
    if (self) {
        self.fullAttributes = attributes;
        self.delegate = delegate;
    }
    return self;
}

- (void) setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    [self setNeedsDisplay];
    [[ControlPointManager sharedManager] layoutControlPoints];
    [self.reflection updateFrame];
    [self.rotationIndicator applyToView:self];
    [ShadowHelper applyShadowToGenericContainerView:self];
}

- (void) setCenter:(CGPoint)center
{
    [super setCenter:center];
    [GenericContainerViewHelper mergeChangedAttributes:@{[KeyConstants centerKey] : [NSValue valueWithCGPoint:center]} withFullAttributes:self.attributes];
}

- (void) setTransform:(CGAffineTransform)transform
{
    BOOL oldTransformStatus = CGAffineTransformIsIdentity(self.transform);
    BOOL newTransformStatus = CGAffineTransformIsIdentity(transform);
    [super setTransform:transform];
    if (oldTransformStatus != newTransformStatus) {
        [self updateEditingStatus];
    }
    [self.rotationIndicator update];
}

- (void) setup
{
    self.backgroundColor = [UIColor clearColor];
    [self setupGestures];
    _rotationIndicator = [[RotationIndicatorView alloc] initWithFrame:self.frame];
    [_rotationIndicator applyToView:self];
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (NSMutableDictionary *) attributes
{
    return self.fullAttributes;
}

#pragma mark - Apply Attributes
- (void) applyAttributes:(NSDictionary *)attributes
{
    [GenericContainerViewHelper mergeChangedAttributes:attributes withFullAttributes:self.fullAttributes];
    [GenericContainerViewHelper applyAttribute:attributes toContainer:self];
}

#pragma mark - User Interations
- (void) setupGestures
{
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(becomeFirstResponder)];
    [self addGestureRecognizer:self.tap];
    
    self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:self.pan];
    
    self.rotation = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
    [self addGestureRecognizer:self.rotation];
}

- (BOOL) resignFirstResponder
{
    self.showBorder = NO;
    self.tap.enabled = YES;
    [[ControlPointManager sharedManager] removeAllControlPointsFromView:self];
    return [super resignFirstResponder];
}

- (BOOL) becomeFirstResponder
{
    [self.delegate contentViewWillBecomFirstResponder:self];
    self.tap.enabled = NO;
    self.showBorder = YES;
    [[ControlPointManager sharedManager] addAndLayoutControlPointsInView:self];
    [self updateEditingStatus];
    return [super becomeFirstResponder];
}

- (void) handlePan:(UIPanGestureRecognizer *) gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.originalCenter = self.center;
        [self.delegate contentView:self startChangingAttributes:nil];
        [ReflectionHelper hideReflectionViewFromGenericContainerView:self];
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gesture translationInView:self.superview];
        self.center = CGPointMake(self.center.x + translation.x, self.center.y + translation.y);
        [gesture setTranslation:CGPointZero inView:self.superview];
    } else if (gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateEnded) {
        SimpleOperation *centerOperation = [[SimpleOperation alloc] initWithTargets:@[self] key:[KeyConstants centerKey] fromValue:[NSValue valueWithCGPoint:self.originalCenter]];
        centerOperation.toValue = [NSValue valueWithCGPoint:self.center];
        [[UndoManager sharedManager] pushOperation:centerOperation];
        [self becomeFirstResponder];
        [self.delegate contentView:self didChangeAttributes:nil];
        [ReflectionHelper applyReflectionViewToGenericContainerView:self];
    }
}

- (void) handleRotation:(UIRotationGestureRecognizer *) gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [GenericContainerViewHelper resetActualTransformWithView:self];
        NSValue *fromValue = [NSValue valueWithCGAffineTransform:self.transform];
        self.currentOperation = [[SimpleOperation alloc] initWithTargets:@[self] key:[KeyConstants transformKey] fromValue:fromValue];
        [self.delegate contentView:self startChangingAttributes:nil];
        [ShadowHelper hideShadowForGenericContainerView:self];
        [ReflectionHelper hideReflectionViewFromGenericContainerView:self];
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        [self applyAttributes:@{[KeyConstants rotationKey] : @(gesture.rotation)}];
        gesture.rotation = 0;
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        [self.rotationIndicator hide];
        [GenericContainerViewHelper mergeChangedAttributes:@{[KeyConstants transformKey] : [NSValue valueWithCGAffineTransform:self.transform]} withFullAttributes:self.attributes];
        ((SimpleOperation *)self.currentOperation).toValue = [NSValue valueWithCGAffineTransform:self.transform];
        [[UndoManager sharedManager] pushOperation:self.currentOperation];
        [self becomeFirstResponder];
        [self.delegate contentView:self didChangeAttributes:nil];
        [ShadowHelper applyShadowToGenericContainerView:self];
        [ReflectionHelper applyReflectionViewToGenericContainerView:self];
    }
}

#pragma mark - Drawing
- (void)drawRect:(CGRect)rect {
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRect:[[ControlPointManager sharedManager] borderRectFromContainerViewBounds:rect]];
    
    borderPath.lineWidth = 3.f;
    [[self borderStrokeColor] setStroke];
    [borderPath stroke];
}

- (UIColor *) borderStrokeColor
{
    return self.showBorder ? [[ControlPointManager sharedManager] borderColor] : [UIColor clearColor];
}

#pragma mark - Other APIs
- (CGRect) contentViewFrameFromBounds:(CGRect) bounds
{
    CGRect contentFrame;
    contentFrame = CGRectInset(bounds, [DrawingConstants controlPointSizeHalf], [DrawingConstants controlPointSizeHalf]);
    return contentFrame;
}

- (void) addSubViews
{
    [ReflectionHelper applyReflectionViewToGenericContainerView:self];
    [self addSubview:self.rotationIndicator];
}

- (void) setShowBorder:(BOOL)showBorder
{
    if (_showBorder != showBorder) {
        _showBorder = showBorder;
        [self setNeedsDisplay];
    }
}

- (BOOL) isContentFirstResponder
{
    return self.showBorder;
}

- (void) updateReflectionView
{
    [self.reflection updateFrame];
}

- (UIImage *) contentSnapshot
{
    return nil;
}

- (CGSize) minSize
{
    CGSize minSize;
    minSize.height = 2 * [DrawingConstants controlPointSizeHalf] + MIN_CONTENT_HEIGHT;
    minSize.width = [DrawingConstants controlPointSizeHalf] * 2 + MIN_CONTENT_WIDTH;
    return minSize;
}

- (void) updateEditingStatus
{
    if (CGAffineTransformIsIdentity(self.transform)) {
        [[ControlPointManager sharedManager] enableControlPoints];
    }
}

- (void) hideRotationIndicator
{
    [self.rotationIndicator hide];
}

- (void) pushUnsavedOperation
{}

- (UIView *) contentView
{
    return nil;
}

#pragma mark - OperationTarget
- (void) performOperation:(Operation *)operation
{
    SimpleOperation *simpleOperation = (SimpleOperation *) operation;
    if ([simpleOperation.key isEqualToString:[KeyConstants addKey]]) {
        GenericContainerView *content = [simpleOperation.targets lastObject];
        UIView *canvas = (UIView *)simpleOperation.toValue;
        [self.delegate contentView:content willBeAddedToView:canvas];
        [canvas addSubview:content];
        [content becomeFirstResponder];
    } else if ([simpleOperation.key isEqualToString:[KeyConstants deleteKey]]) {
        GenericContainerView *content = [simpleOperation.targets lastObject];
        UIView *canvas = (UIView *)simpleOperation.toValue;
        [content removeFromSuperview];
        [self.delegate contentView:content didRemoveFromView:canvas];
    } else {
        NSDictionary *attibutes = @{simpleOperation.key : simpleOperation.toValue};
        [self becomeFirstResponder];
        [GenericContainerViewHelper mergeChangedAttributes:attibutes withFullAttributes:self.fullAttributes];
        [GenericContainerViewHelper applyUndoAttribute:attibutes toContainer:self];
    }
    [ShadowHelper applyShadowToGenericContainerView:self];
    [ReflectionHelper applyReflectionViewToGenericContainerView:self];
    [self.delegate contentViewDidPerformUndoRedoOperation:self];
}

@end

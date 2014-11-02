//
//  EditorPanelViewController.m
//  iDo
//
//  Created by Huang Hongsen on 10/20/14.
//  Copyright (c) 2014 com.microstrategy. All rights reserved.
//

#import "EditorPanelViewController.h"
#import "ImageHelper.h"
#import "EditorPanelManager.h"
#import "UIView+Snapshot.h"
#import "EditorButtonView.h"
#import "TooltipView.h"
#import "SliderWithTooltip.h"
#import "KeyConstants.h"

#define THUMB_WIDTH_HALF 15

@interface EditorPanelViewController ()<SliderWithToolTipDelegate>
@property (weak, nonatomic) IBOutlet EditorButtonView *addReflectionView;
@property (weak, nonatomic) IBOutlet EditorButtonView *addShadowView;
@property (weak, nonatomic) IBOutlet TooltipView *tooltipView;
@property (weak, nonatomic) IBOutlet SliderWithTooltip *alphaSlider;
@property (weak, nonatomic) IBOutlet SliderWithTooltip *sizeSlider;
@property (weak, nonatomic) IBOutlet SliderWithTooltip *viewOpacitySlider;
@property (nonatomic, strong) NSMutableDictionary *attributes;

@end

@implementation EditorPanelViewController

#pragma mark - Memory Management
- (void) awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tapToAddReflection = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reflectionStatusChanged:)];
    [self.addReflectionView addGestureRecognizer:tapToAddReflection];
    UITapGestureRecognizer *tapToAddShadow = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shadowStatusChanged:)];
    [self.addShadowView addGestureRecognizer:tapToAddShadow];
    self.alphaSlider.delegate = self;
    self.sizeSlider.delegate = self;
    self.viewOpacitySlider.delegate = self;
}

#pragma mark - User Interaction 
- (IBAction)handleTap:(id)sender {
}

- (IBAction)rotationValueChanged:(UISlider *)sender {
    [self updateTooltipViewFromSender:sender];
    [self.delegate editorPanelViewController:self didChangeAttributes:@{[KeyConstants rotationKey] : @(sender.value)}];
}

- (IBAction)restore {
    [self.delegate editorPanelViewController:self didChangeAttributes:@{[KeyConstants rotationKey] : @(0),
                                                                        [KeyConstants restoreKey] : @(YES)}];
}

- (void) applyAttributes:(NSDictionary *)attributes
{
    self.attributes = [attributes mutableCopy];
    NSNumber *reflection = attributes[[KeyConstants reflectionKey]];
    if (reflection) {
        self.addReflectionView.selected = [reflection boolValue];
    }
    NSNumber *shadow = attributes[[KeyConstants shadowKey]];
    if (shadow) {
        self.addShadowView.selected = [shadow boolValue];
    }
    [self updateSliders];
}

- (IBAction)alphaChanged:(UISlider *)sender {
    [self updateTooltipViewFromSender:sender];
    NSString *changedKey;
    if (self.addReflectionView.selected) {
        changedKey = [KeyConstants reflectionAlphaKey];
    } else {
        changedKey = [KeyConstants shadowAlphaKey];
    }
    [self.attributes setValue:@(sender.value) forKey:changedKey];
    [self.delegate editorPanelViewController:self didChangeAttributes:@{changedKey : @(sender.value)}];
}

- (IBAction)sizeChanged:(UISlider *)sender {
    [self updateTooltipViewFromSender:sender];
    NSString *changedKey;
    if (self.addReflectionView.selected) {
        changedKey = [KeyConstants reflectionSizeKey];
    } else {
        changedKey = [KeyConstants shadowSizeKey];
    }
    [self.attributes setValue:@(sender.value) forKey:changedKey];
    [self.delegate editorPanelViewController:self didChangeAttributes:@{changedKey : @(sender.value)}];
}

- (IBAction)viewOpacityChanged:(SliderWithTooltip *)sender {
    [self updateTooltipViewFromSender:sender];
    [self.attributes setValue:@(sender.value) forKey:[KeyConstants viewOpacityKey]];
    [self.delegate editorPanelViewController:self didChangeAttributes:@{[KeyConstants viewOpacityKey] : @(sender.value)}];
}

- (void) reflectionStatusChanged:(UITapGestureRecognizer *) gesture
{
    self.addReflectionView.selected = !self.addReflectionView.selected;
    self.addShadowView.selected = NO;
    [self updateReflectionShadowStatus];
    [self updateSliders];
    [self.delegate editorPanelViewController:self didChangeAttributes:@{
                                                                        [KeyConstants reflectionKey] : @(self.addReflectionView.selected),
                                                                        [KeyConstants shadowKey] : @(NO)
                                                                        }];
}

- (void) shadowStatusChanged:(UITapGestureRecognizer *) gesture
{
    self.addShadowView.selected = !self.addShadowView.selected;
    self.addReflectionView.selected = NO;
    [self updateReflectionShadowStatus];
    [self updateSliders];
    [self.delegate editorPanelViewController:self didChangeAttributes:@{
                                                                        [KeyConstants shadowKey] : @(self.addShadowView.selected),
                                                                        [KeyConstants reflectionKey] : @(NO)
                                                                        }];
}

- (void) updateReflectionShadowStatus
{
    [self.attributes setValue:@(self.addReflectionView.selected) forKey:[KeyConstants reflectionKey]];
    [self.attributes setValue:@(self.addShadowView.selected) forKey:[KeyConstants reflectionKey]];
}

- (void) updateSliders
{
    self.sizeSlider.enabled = YES;
    self.alphaSlider.enabled = YES;
    if (self.addReflectionView.selected) {
        NSNumber *reflectionAlpha = self.attributes[[KeyConstants reflectionAlphaKey]];
        if (reflectionAlpha) {
            [self.alphaSlider setValue:[reflectionAlpha floatValue] animated:YES];
        }
        NSNumber *reflectionSize = self.attributes[[KeyConstants reflectionSizeKey]];
        if (reflectionSize) {
            [self.sizeSlider setValue:[reflectionSize floatValue] animated:YES];
        }
    } else if (self.addShadowView.selected) {
        NSNumber *shadowAlpha = self.attributes[[KeyConstants shadowAlphaKey]];
        if (shadowAlpha) {
            [self.alphaSlider setValue:[shadowAlpha floatValue] animated:YES];
        }
        NSNumber *shadowSize = self.attributes[[KeyConstants shadowSizeKey]];
        if (shadowSize) {
            [self.sizeSlider setValue:[shadowSize doubleValue] animated:YES];
        }
    } else {
        self.sizeSlider.enabled = NO;
        self.alphaSlider.enabled = NO;
    }
}

#pragma mark - Tooltip Management

- (void) updateTooltipViewFromSender:(UISlider *) sender
{
    CGRect trackRect = [sender trackRectForBounds:sender.bounds];
    CGRect thumbRect = [sender thumbRectForBounds:[sender bounds] trackRect:trackRect value:sender.value];
    CGPoint position = [self.view convertPoint:thumbRect.origin fromView:sender];
    self.tooltipView.hidden = NO;
    self.tooltipView.toolTipText = [NSString stringWithFormat:@"%3.2f", sender.value];
    self.tooltipView.center = [self tooltipCenterFromThumbPosition:position];
}

- (CGPoint) tooltipCenterFromThumbPosition:(CGPoint) position
{
    CGPoint center;
    center.x = position.x + THUMB_WIDTH_HALF;
    center.y = position.y - self.tooltipView.frame.size.height / 2;
    return center;
}

- (IBAction)hideTooltip
{
    self.tooltipView.hidden = YES;
}

- (void) touchDidEndInSlider:(SliderWithTooltip *)slider
{
    self.tooltipView.hidden = YES;
}

@end

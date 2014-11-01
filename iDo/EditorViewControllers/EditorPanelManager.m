//
//  EditorPanelHelper.m
//  iDo
//
//  Created by Huang Hongsen on 10/17/14.
//  Copyright (c) 2014 com.microstrategy. All rights reserved.
//

#import "EditorPanelManager.h"
#import "ImageEditorPanelViewController.h"
#import "TextEditorPanelViewController.h"
#import "UIView+Snapshot.h"
#import "ImageContainerView.h"
#import "TextContainerView.h"

#define EDITOR_PANEL_WIDTH 300

@interface EditorPanelManager()

@property (nonatomic, strong) ImageEditorPanelViewController *imageEditor;
@property (nonatomic, strong) EditorPanelViewController *currentEditor;
@property (nonatomic, strong) TextEditorPanelViewController *textEditor;

@end

static EditorPanelManager *sharedInstance;

@implementation EditorPanelManager

#pragma mark - Singleton
- (instancetype) init
{
    return nil;
}

- (instancetype) initInternal
{
    self = [super init];
    if (self) {
        _imageEditor = [self createImageEditorViewController];
        _textEditor = [self createTextEditorViewController];
    }
    return self;
}

+ (EditorPanelManager *) sharedManager
{
    if (!sharedInstance) {
        sharedInstance = [[EditorPanelManager alloc] initInternal];
    }
    return sharedInstance;
}

#pragma mark - Utility Methods

+ (CGRect) editorPanelFrameInView:(UIView *) parentView
{
    CGRect frame;
    frame.size.width = EDITOR_PANEL_WIDTH;
    frame.size.height = parentView.bounds.size.height;
    frame.origin.x = parentView.bounds.size.width - EDITOR_PANEL_WIDTH;
    frame.origin.y = 64;
    return frame;
}

+ (CGRect) editorPanelFrameOutOfView:(UIView *) parentView
{
    CGRect frame;
    frame.size.width = EDITOR_PANEL_WIDTH;
    frame.size.height = parentView.bounds.size.height;
    frame.origin.x = parentView.bounds.size.width;
    frame.origin.y = 64;
    return frame;
}

+ (CGFloat) currentEditorWidth
{
    return sharedInstance.currentEditor.view.frame.size.width;
}

- (ImageEditorPanelViewController *) createImageEditorViewController
{
    return [[ImageEditorPanelViewController alloc] initWithNibName:@"ImageEditorPanelViewController" bundle:[NSBundle mainBundle]];
}

- (TextEditorPanelViewController *) createTextEditorViewController
{
    return [[TextEditorPanelViewController alloc] initWithNibName:@"TextEditorPanelViewController" bundle:[NSBundle mainBundle]];
}

- (void) makeCurrentEditorApplyChanges:(NSDictionary *)attributes
{
    [self.currentEditor applyAttributes:attributes];
}

#pragma mark - Presenting Editor Panels
- (void) showEditorPanelInViewController:(SliderEditingViewController *)viewController
                          forContentView:(GenericContainerView *)contentView
{
    if ([contentView isKindOfClass:[ImageContainerView class]]) {
        [self showImageEditorInViewController:viewController attributes:[contentView attributes]];
    } else if ([contentView isKindOfClass:[TextContainerView class]]) {
        [self showTextEditorInViewController:viewController attributes:[contentView attributes]];
    }
}

- (void) showImageEditorInViewController:(SliderEditingViewController *)viewController
                              attributes:(NSDictionary *)attributes
{
    self.currentEditor = self.imageEditor;
    self.imageEditor.delegate = viewController;
    [self showCurrentEditorInViewController:viewController];
    [self.imageEditor applyAttributes:attributes];
}

- (void) showTextEditorInViewController:(SliderEditingViewController *)viewController
                             attributes:(NSDictionary *)attributes
{
    self.currentEditor = self.textEditor;
    self.textEditor.delegate = viewController;
    [self showCurrentEditorInViewController:viewController];
    [self.textEditor applyAttributes:attributes];
}

- (void) showCurrentEditorInViewController:(SliderEditingViewController *) viewController
{
    [viewController addChildViewController:self.currentEditor];
    self.currentEditor.view.frame = [EditorPanelManager editorPanelFrameOutOfView:viewController.view];
    [viewController.view addSubview:self.currentEditor.view];
    [self.currentEditor didMoveToParentViewController:viewController];
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.currentEditor.view.frame = [EditorPanelManager editorPanelFrameInView:viewController.view];
        [viewController adjustCanvasSizeAndPosition];
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - Dismiss Editor Panels
- (void) dismissAllEditorPanelsFromViewController:(SliderEditingViewController *) viewController
{
    EditorPanelViewController *animationVC = nil;
    if ([self.currentEditor isKindOfClass:[ImageEditorPanelViewController class]]) {
        animationVC = [self createImageEditorViewController];
    } else if ([self.currentEditor isKindOfClass:[TextEditorPanelViewController class]]) {
        animationVC = [self createTextEditorViewController];
    }
    [viewController addChildViewController:animationVC];
    animationVC.view.frame = self.currentEditor.view.frame;
    
    [self.currentEditor willMoveToParentViewController:nil];
    [self.currentEditor.view removeFromSuperview];
    [self.currentEditor removeFromParentViewController];
    self.currentEditor = nil;
    
    [viewController.view addSubview:animationVC.view];
    [animationVC didMoveToParentViewController:viewController];
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        animationVC.view.frame = [EditorPanelManager editorPanelFrameOutOfView:viewController.view];
        [viewController adjustCanvasSizeAndPosition];
    } completion:^(BOOL finished) {
        [animationVC willMoveToParentViewController:nil];
        [animationVC.view removeFromSuperview];
        [animationVC removeFromParentViewController];
    }];
}

- (void) handleContentViewDidFinishChanging
{
    [self.currentEditor hideTooltip];
}


@end

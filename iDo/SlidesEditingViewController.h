//
//  ViewController.h
//  iDo
//
//  Created by Huang Hongsen on 10/14/14.
//  Copyright (c) 2014 com.microstrategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditorPanelContainerViewController.h"
#import "TextEditorPanelContainerViewController.h"
#import "ImageContainerView.h"
#import "TextContainerView.h"
#import "CanvasView.h"
#import "ContentEditMenuView.h"

@class SlidesEditingViewController;
@protocol SlidesEditingViewControllerDelegate <NSObject>

- (void) adjustCanvasPositionForContentBottom:(CGFloat) contentBottom;
- (void) contentDidChangeFromEditingController:(SlidesEditingViewController *)editingController;
- (void) contentView:(GenericContainerView *)content willBeAddedToView:(UIView *)canvas;
- (void) contentViewDidPerformUndoRedoOperation:(GenericContainerView *) content;
- (void) contentView:(GenericContainerView *)content didRemoveFromView:(UIView *)canvas;
- (void) allContentViewDidResignFirstResponder;
@optional
- (void) contentViewDidBecomeFirstResponder:(GenericContainerView *) content;
@end

@interface SlidesEditingViewController : UIViewController<CanvasViewDelegate, ImageContainerViewDelegate, TextContainerViewDelegate, TextEditorPanelContainerViewControllerDelegate, EditorPanelContainerViewControllerDelegate>

@property (strong, nonatomic) CanvasView *canvas;
@property (nonatomic, weak) ContentEditMenuView *editMenu;
@property (nonatomic, strong) GenericContainerView *currentSelectedContent;
@property (nonatomic, weak) id<SlidesEditingViewControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableDictionary *slideAttributes;

- (void) resignPreviousFirstResponderExceptForContainer:(GenericContainerView *) container;
- (void) addContentViewToCanvas:(GenericContainerView *) content;
- (void) removeCurrentContentViewFromCanvas;
- (void) saveSlideAttributes;
@end


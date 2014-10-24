//
//  ViewController.m
//  iDo
//
//  Created by Huang Hongsen on 10/14/14.
//  Copyright (c) 2014 com.microstrategy. All rights reserved.
//

#import "ViewController.h"
#import "ImageContainerView.h"
#import "TextContainerView.h"
#import "EditorPanelManager.h"
#import "TooltipView.h"

@interface ViewController ()<ImageContainerViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, strong) GenericContainerView *currentSelectedContent;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    ImageContainerView *view = [[ImageContainerView alloc] initWithImage:[UIImage imageNamed:@"background.jpg"]];
//    self.view.layer.contents = (__bridge id)[UIImage imageNamed:@"background.jpg"].CGImage;
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnView)]];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - User Interactions

- (void) tapOnView
{
    [self resignPreviousFirstResponderExceptForContainer:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addImage:(id)sender {
    ImageContainerView *view = [[ImageContainerView alloc] initWithImage:[UIImage imageNamed:@"background.jpg"]];
    view.delegate = self;
    [view becomeFirstResponder];
    [self.view addSubview:view];
}

- (IBAction)addText:(id)sender {
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:@"Test Test" attributes:@{}];
    TextContainerView *view = [[TextContainerView alloc] initWithAttributedString:attrStr];
    view.delegate = self;
    [view becomeFirstResponder];
    [self.view addSubview:view];
}

#pragma mark - ContentContainerViewDelegate
- (void) contentViewWillResignFirstResponder:(GenericContainerView *)contentView
{
    
}

- (void) contentViewDidResignFirstResponder:(GenericContainerView *)contentView
{
    self.currentSelectedContent = nil;
    [[EditorPanelManager sharedManager] dismissAllEditorPanelsFromViewController:self];
}

- (void) contentViewWillBecomFirstResponder:(GenericContainerView *)contentView
{
    [self resignPreviousFirstResponderExceptForContainer:contentView];
}

- (void) contentViewDidBecomFirstResponder:(GenericContainerView *)contentView
{
    self.currentSelectedContent = contentView;
    [[EditorPanelManager sharedManager] showEditorPanelInViewController:self forContentView:contentView];
}

- (void) contentView:(GenericContainerView *)contentView didChangeAttributes:(NSDictionary *)attributes
{
    [[EditorPanelManager sharedManager] makeCurrentEditorApplyChanges:attributes];
}

- (void) resignPreviousFirstResponderExceptForContainer:(GenericContainerView *) container
{
    for (UIView *subView in self.view.subviews) {
        if ([subView isKindOfClass:[GenericContainerView class]] && subView != container) {
            GenericContainerView *containerView = (GenericContainerView *) subView;
            if ([containerView isContentFirstResponder]) {
                [containerView resignFirstResponder];
            }
        }
    }
}

- (void) handleTapOnImage:(ImageContainerView *)container
{
    UIPopoverController *popOver = [[UIPopoverController alloc] initWithContentViewController:self.imagePicker];
    [popOver presentPopoverFromRect:container.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

#pragma mark - EditorPanelViewControllerDelegate
- (void) editorPanelViewController:(EditorPanelViewController *)editor didChangeAttributes:(NSDictionary *)attributes
{
    [self.currentSelectedContent applyAttributes:attributes];
}

- (void) restoreFromEditorPanelViewController:(EditorPanelViewController *)editor
{
    [self.currentSelectedContent restore];
}

#pragma mark - TextEditorPanelViewController

- (void) textAttributes:(NSDictionary *)textAttributes didChangeFromTextEditor:(TextEditorPanelViewController *)textEditor
{
    NSLog(@"%@", textAttributes);
}


#pragma mark - ImagePicker
- (UIImagePickerController *) imagePicker
{
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.allowsEditing = NO;
        _imagePicker.delegate = self;
        _imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    return _imagePicker;
}


#pragma mark - UIImagePickerViewControllerDelegate
- (void) imagePickerController:(UIImagePickerController *)picker
 didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self updateCurrentImageContentWithImage:selectedImage];
}

- (void) updateCurrentImageContentWithImage:(UIImage *) image
{
    if ([self.currentSelectedContent isKindOfClass:[ImageContainerView class]]) {
        ImageContainerView *imageContainer = (ImageContainerView *) self.currentSelectedContent;
        imageContainer.image = image;
    }
}



@end

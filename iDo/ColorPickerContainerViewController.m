//
//  ColorPickerContainerViewController.m
//  iDo
//
//  Created by Huang Hongsen on 12/9/14.
//  Copyright (c) 2014 com.microstrategy. All rights reserved.
//

#import "ColorPickerContainerViewController.h"
#import "ColorPickerViewController.h"
#import "RegularColorPickerViewController.h"
@interface ColorPickerContainerViewController()<ColorPickerViewControllerDelegate, RegularColorPickerViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSegment;
@property (nonatomic, strong) ColorPickerViewController *colorPicker;
@property (nonatomic, strong) RegularColorPickerViewController *regularColorPicker;
@property (nonatomic) UIColor *selectedColor;
@end
#define COLOR_PICKER_VIEW_WIDTH 300
#define COLOR_PICKER_VIEW_HEIGHT 400
#define COLOR_PICKER_VIEW_TOP_SPACE 50

#define REGULAR_COLOR_PICKER_INDEX 0
#define COLOR_PICKER_INDEX 1

@implementation ColorPickerContainerViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.colorPicker = [[UIStoryboard storyboardWithName:@"EditorViewControllers" bundle:nil] instantiateViewControllerWithIdentifier:@"ColorPickerViewController"];
    self.colorPicker.delegate = self;
    self.regularColorPicker = [[UIStoryboard storyboardWithName:@"EditorViewControllers" bundle:nil] instantiateViewControllerWithIdentifier:@"RegularColorPickerViewController"];
    self.regularColorPicker.delegate = self;

}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showRegularColorPicker];
    [self.colorPicker setSelectedColor:self.selectedColor];
}

- (IBAction)fragmentChanged:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == COLOR_PICKER_INDEX) {
        [self showColorPicker];
    } else if (sender.selectedSegmentIndex == REGULAR_COLOR_PICKER_INDEX) {
        [self showRegularColorPicker];
    }
}

#pragma mark - Fragment Switch
- (void) showColorPicker
{
    [self hideRegularColorPicker];
    [self addChildViewController:self.colorPicker];
    self.colorPicker.view.frame = CGRectMake(0, COLOR_PICKER_VIEW_TOP_SPACE, COLOR_PICKER_VIEW_WIDTH, COLOR_PICKER_VIEW_HEIGHT);
    [self.view addSubview:self.colorPicker.view];
    [self.colorPicker didMoveToParentViewController:self];
}

- (void) showRegularColorPicker
{
    [self hideColorPicker];
    [self addChildViewController:self.regularColorPicker];
    self.regularColorPicker.view.frame = CGRectMake(0, COLOR_PICKER_VIEW_TOP_SPACE, COLOR_PICKER_VIEW_WIDTH, COLOR_PICKER_VIEW_HEIGHT);
    [self.view addSubview:self.regularColorPicker.view];
    [self.regularColorPicker didMoveToParentViewController:self];
}

- (void) hideColorPicker
{
    [self.colorPicker willMoveToParentViewController:nil];
    [self.colorPicker.view removeFromSuperview];
    [self.colorPicker removeFromParentViewController];
}

- (void) hideRegularColorPicker
{
    [self.regularColorPicker willMoveToParentViewController:nil];
    [self.regularColorPicker.view removeFromSuperview];
    [self.regularColorPicker removeFromParentViewController];
}

#pragma mark - ColorPickerViewControllerDelegate
- (void) colorPickerDidChangeToColor:(UIColor *)color
{
    [self.delegate colorPickerDidChangeToColor:color];
}

- (void) colorPickerDidSelectColor:(UIColor *)color
{
    [self.delegate colorPickerDidSelectColor:color];
}

- (void) setSelectedColor:(UIColor *)color
{
    [self.colorPicker setSelectedColor:color];
    [self.regularColorPicker setSelectedColor:color];
    _selectedColor = color;
}

#pragma mark - RegularColorPickerViewControllerDelegate
- (void) regularColorPickerViewController:(RegularColorPickerViewController *)controller didSelectColor:(UIColor *)color
{
    [self.delegate colorPickerDidSelectColor:color];
}

@end

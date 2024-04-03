//
//  BaseViewController.m
//  ECoreEngineDemo
//
//  Created by migu on 2022/2/8.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    [self createBackButton];
    [self createRightButton];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
     self.navigationController.navigationBar.translucent = true;
    
    self.navigationController.navigationBar.tintColor = [UIColor clearColor];
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
}


- (void)createBackButton
{
    UIImage *backImage = [UIImage imageNamed:@"nav_backBtn"];
    CGRect frame = CGRectMake(0, 0, 30, 30);
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = frame;
    [backButton setImage: backImage forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:backButton] animated:NO];
}

- (void)createRightButton
{
    UIImage *rightImage = [UIImage imageNamed:@"nav_downBtn"];
    CGRect frame = CGRectMake(0, 0, 30, 30);
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = frame;
    [rightButton setImage: rightImage forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(rightAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:rightButton] animated:NO];
}

- (void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated: YES];
}

- (void)rightAction:(id)sender
{

}

-(UIStatusBarStyle)statusBarStyle
{
    return UIStatusBarStyleDefault;
}

-(BOOL)enablePopGesture
{
    return NO;
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
}

@end

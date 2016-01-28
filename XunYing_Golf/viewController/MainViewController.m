//
//  MainViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/9/7.
//  Copyright (c) 2015年 LiuC. All rights reserved.
//

#import "MainViewController.h"
#import "XunYingPre.h"
#import "HttpTools.h"
#import "UIColor+UICon.h"

@interface MainViewController ()<UIActionSheetDelegate,UITabBarControllerDelegate>

@property(strong, nonatomic)UIBarButtonItem *rightButton;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navBarBack.png"] style:UIBarButtonItemStyleDone target:self action:@selector(navBack)];
//    self.navigationItem.leftBarButtonItem.tintColor = [UIColor HexString:@"454545"];
    
}
//#pragma -mark navBack
//-(void)navBack
//{
//    NSLog(@"enter navBack");
//    [self.navigationController popViewControllerAnimated:YES];
//}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //
    self.tabBarController.selectedIndex = 2;
    
//    NSThread *heartBeatThread = [[NSThread alloc] initWithTarget:self selector:@selector(timelySend) object:nil];
//    [heartBeatThread start];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}
#pragma -mark viewWillAppear
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

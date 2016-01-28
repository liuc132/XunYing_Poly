//
//  MoreMainViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/9/30.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import "MoreMainTabBarViewController.h"

@interface MoreMainTabBarViewController ()


@property (strong, nonatomic) IBOutlet UITabBar *moreMainTabBar;

@end


@implementation MoreMainTabBarViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    //NSLog(@"enter MoreMainTabBarViewController");
    self.selectedIndex = 1;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ForceBackField:) name:@"forceBackField" object:nil];
    
}

- (void)ForceBackField:(NSNotification *)sender
{
    __weak typeof(self) weakSelf = self;
    if ([sender.userInfo[@"forceBack"] isEqualToString:@"1"]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        //
        dispatch_async(dispatch_get_main_queue(), ^{
//            UIAlertView *serverForceBackAlert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"您的小组已回场" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
//            [serverForceBackAlert show];
            
            [weakSelf performSegueWithIdentifier:@"serVerBackField" sender:nil];
        });
        
        
    }
}
//
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //
    [self.tabBarController setSelectedIndex:1];
    NSLog(@"tab bar Selected Index:%lu",self.tabBarController.selectedIndex);
}


@end

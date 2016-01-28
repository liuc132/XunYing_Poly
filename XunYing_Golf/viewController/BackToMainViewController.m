//
//  BackToMainViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/10/9.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import "BackToMainViewController.h"

@interface BackToMainViewController ()

@end

@implementation BackToMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self performSegueWithIdentifier:@"backToMain" sender:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

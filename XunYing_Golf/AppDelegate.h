//
//  AppDelegate.h
//  XunYing_Golf
//
//  Created by LiuC on 15/8/27.
//  Copyright (c) 2015年 LiuC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

//#define USES_TOUCHkit   1

#if USES_TOUCHkit
#import "TOUCHkitView.h"
#import "TOUCHOverlayWindow.h"
#define WINDOW_CLASS    TOUCHOverlayWindow
#else
#define WINDOW_CLASS    UIWindow
#endif


#define UMENG_APPKEY  @"56c67c7ce0f55aef1c0034d2"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) WINDOW_CLASS *window;

@property (strong, nonatomic) UIViewController *rootVC;

@property float autoSizeScaleX;
@property float autoSizeScaleY;
//+(void)storyBoardAutoLay:(UIView *)allView;

//@property (strong, nonatomic) UIImageView *splashView;

@end


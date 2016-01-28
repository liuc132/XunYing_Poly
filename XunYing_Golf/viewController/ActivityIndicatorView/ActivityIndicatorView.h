//
//  ActivityIndicatorView.h
//  XunYing_Golf
//
//  Created by LiuC on 15/9/9.
//  Copyright (c) 2015年 LiuC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityIndicatorView : UIView

@property(strong, nonatomic)UIActivityIndicatorView *activityIndicatorView;

-(void)showIndicator;
-(void)hideIndicator;


@end

//
//  ActivityIndicatorView.m
//  XunYing_Golf
//
//  Created by LiuC on 15/9/9.
//  Copyright (c) 2015年 LiuC. All rights reserved.
//

#import "ActivityIndicatorView.h"

@implementation ActivityIndicatorView

-(void)drawRect:(CGRect)rect
{
    //init activityIndicatorView
    self.activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    //set this view's center
    self.activityIndicatorView.center = CGPointMake(rect.size.width/2, rect.size.height/2);
    
    self.activityIndicatorView.tintColor = [UIColor grayColor];
    
    self.activityIndicatorView.color     = [UIColor blackColor];
    
}
#pragma --mark showIndicator
/**
 *  start animating and show the view
 */
-(void)showIndicator
{
    //start animating and show the view
    [self.activityIndicatorView startAnimating];
    self.hidden = NO;
}
#pragma --mark hideIndicator
/**
 *  stop animating and hide the view
 */
-(void)hideIndicator
{
    [self.activityIndicatorView stopAnimating];
    self.hidden = YES;
}

@end

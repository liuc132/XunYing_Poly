//
//  CaddyView.m
//  XunYing_Golf
//
//  Created by LiuC on 15/12/1.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import "CaddyView.h"
#import "UIColor+UICon.h"

#define caddySelectedBKColor @"01cc00"



@interface CaddyView ()<UIGestureRecognizerDelegate>

@end
@implementation CaddyView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeButton)];
    tapGesture.numberOfTouchesRequired = 1;
    tapGesture.delegate = self;
    
    [self addGestureRecognizer:tapGesture];
}

-(void)changeButton
{
    NSLog(@"enter changeButton and tag is:%ld and view is:%@",(long)self.tag,self);
    
    
    
    [self setBackgroundColor:[UIColor HexString:caddySelectedBKColor]];
    
}


@end

//
//  subCaddyOrCartView.m
//  XunYing_Golf
//
//  Created by LiuC on 15/12/30.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import "subCaddyOrCartView.h"

@interface subCaddyOrCartView ()<UIGestureRecognizerDelegate>

@end

@implementation subCaddyOrCartView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self == nil) {
        self.layer.cornerRadius = 6.0;
    }
    return self;
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.layer.cornerRadius = 6.0;
    
    NSLog(@"enter draw subCaddyOrCart");
    //
    UILongPressGestureRecognizer *deleteTheData = [[UILongPressGestureRecognizer alloc] initWithTarget:[self superview] action:@selector(deleteCaddyOrCart:)];
    deleteTheData.delegate = self;
    deleteTheData.minimumPressDuration = 0.5;//2秒
    
}

- (void)deleteCaddyOrCart:(id)sender
{
    NSLog(@"enter deleteCaddyOrCart");
    
    NSLog(@"haha");
    
}


@end

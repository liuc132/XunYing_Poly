//
//  CreateGroupViewController.h
//  XunYing_Golf
//
//  Created by LiuC on 15/9/18.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import <UIKit/UIKit.h>


#ifndef myData
#define myData
//unsigned char ucCusCounts;
//unsigned char ucHolePosition;
//BOOL          allowDownCourt;

#endif

@protocol WaitToPlayTableViewControllerDelegate <NSObject>

-(void)getCustomerCounts:(NSInteger)customerCount andHolePosition:(NSInteger)holePosition;

@end



@interface CreateGroupViewController : UIViewController

@property (weak, nonatomic) id<WaitToPlayTableViewControllerDelegate> cusAndHoleDelegate;

@end

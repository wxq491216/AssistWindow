//
//  FloatView.h
//  FloatView
//
//  Created by xqwang on 6/7/16.
//  Copyright © 2016 DataEye. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, YDAssistiveTouchStatus){
    AssistWindow,
    DialogWindow,
    MainWindow
};


@interface YDAssistiveTouch : UIWindow

@property(nonatomic, strong)NSArray* tools;

@property(nonatomic, assign)YDAssistiveTouchStatus windowStatus;

-(BOOL)open;

-(void)showWindow;

@end



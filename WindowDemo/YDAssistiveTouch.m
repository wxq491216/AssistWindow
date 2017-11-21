//
//  FloatView.m
//  FloatView
//
//  Created by xqwang on 6/7/16.
//  Copyright © 2016 DataEye. All rights reserved.
//

#import "YDAssistiveTouch.h"


//浮动框大小
#define ASSIST_WIDTH   44
#define ASSIST_HEIGHT  44
//导航条设计长度
#define NAVIGATION_DESIGN_WIDTH   196
#define NAVIGATION_HEIGHT  44
//导航条上工具数目
//#define NAVIGATION_TOOL_NUM    4
#define NAVIGATION_TOOL_WIDTH  44
#define NAVIGATION_TOOL_HEIGHT 44
//工具间距离
#define NAVIGATION_TOOL_MARGIN 3
//导航条背景末端弧形宽度
#define NAVIGATION_BG_END_WIDTH 20

//弹出框大小
#define WINDOW_WIDTH   400
#define WINDOW_HEIGHT  300

@interface YDAssistiveTouch () <UITextFieldDelegate, CAAnimationDelegate, UIGestureRecognizerDelegate>

@property(nonatomic, strong)UIPanGestureRecognizer* panGesture;
@property(nonatomic, strong)UITapGestureRecognizer* tapGesture;

@property(nonatomic, strong)UIImageView* logoView;
@property(nonatomic, assign)BOOL toolPopup;
@property(nonatomic, strong)UIView* toolBgView;
@property(nonatomic, strong)UIImageView* toolBgImageView;

@end

@implementation YDAssistiveTouch

-(instancetype)init
{
    if (self = [super init]) {
        self.windowLevel = UIWindowLevelAlert + 1;
        [self setBackgroundColor:[UIColor clearColor]];
        self.clipsToBounds = YES;
        self.opaque = NO;
        self.hidden = YES;
        self.windowStatus = AssistWindow;
        
        self.toolPopup = NO;
        [self setUpNavigationTools];
        [self addGesture];
        [self windowMoveSide];
    }
    return self;
}

-(void)showWindow
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.hidden = NO;
    });
}

-(void)setWindowStatus:(YDAssistiveTouchStatus)windowStatus
{
    CGRect newWindowFrame = [self rectOfWindow:windowStatus];
    CGRect oldWindowFrame = self.frame;
    _windowStatus = windowStatus;
    if (windowStatus != AssistWindow) {
        self.alpha = 1.0f;
    }
    if (windowStatus == DialogWindow) {
        [self.toolBgView setHidden:YES];
    }else{
        [self.toolBgView setHidden:NO];
    }
    if (windowStatus == MainWindow) {
        self.toolBgView.frame = oldWindowFrame;
    }else if (windowStatus == AssistWindow){
        self.toolBgView.frame = CGRectMake(0, 0, newWindowFrame.size.width, newWindowFrame.size.height);
    }
    self.frame = newWindowFrame;
}

-(void)setTools:(NSArray *)tools
{
    if ([tools count] == 0) {
        NSLog(@"Tools must have more than three, please reset again!");
        return;
    }
    _tools = tools;
    NSInteger number = [self.tools count];
    CGFloat width = ASSIST_WIDTH + number * (NAVIGATION_TOOL_WIDTH + NAVIGATION_TOOL_MARGIN) + NAVIGATION_BG_END_WIDTH;
    self.toolBgImageView.frame = CGRectMake(0, 0, width, NAVIGATION_TOOL_HEIGHT);
}

-(BOOL)open
{
    if (self.windowStatus != AssistWindow) {
        return YES;
    }
    return NO;
}

-(void)setUpNavigationTools
{
    self.logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"float_window"]];
    self.toolBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ASSIST_WIDTH, ASSIST_HEIGHT)];
    [self.toolBgView setBackgroundColor:[UIColor clearColor]];
    [self.toolBgView addSubview:self.logoView];
    [self.logoView setFrame:CGRectMake(0, 0, ASSIST_WIDTH, ASSIST_HEIGHT)];
    [self addSubview:self.toolBgView];
    
    self.toolBgImageView = [[UIImageView alloc] init];
//    self.toolBgImageView.frame = CGRectMake(0, 0, NAVIGATION_DESIGN_WIDTH, NAVIGATION_TOOL_HEIGHT);
}

-(void)addGesture
{
    if (self.panGesture == nil) {
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self.panGesture setDelegate:self];
    }
    if (self.tapGesture == nil) {
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    }
    [self.toolBgView addGestureRecognizer:self.panGesture];
    [self.toolBgView addGestureRecognizer:self.tapGesture];
}

-(void)setRootViewController:(UIViewController *)rootViewController
{
    [super setRootViewController:rootViewController];
    if (self.windowStatus == MainWindow) {
        [self bringSubviewToFront:self.toolBgView];
    }
}

-(void)handlePan:(UIPanGestureRecognizer*)p
{
    UIView* targetView = [p view];
    UIWindow* targetWindow = self;
    if (!self.open) {
        targetView = self;
        targetWindow = [[UIApplication sharedApplication] keyWindow];
    }
    CGPoint point = [p locationInView:targetWindow];
    if (p.state == UIGestureRecognizerStateBegan) {
        targetView.alpha = 1;
    }else if(p.state == UIGestureRecognizerStateChanged){
        targetView.center = CGPointMake(point.x, point.y);
    }else if(p.state == UIGestureRecognizerStateEnded){
        CGPoint center = [self sidePoint];
        [UIView animateWithDuration:0.15f animations:^{
            [targetView setCenter:center];
        } completion:^(BOOL finished) {
            targetView.alpha = 0.5f;
        }];
    }
}

-(void)handleTap:(UITapGestureRecognizer*)tap
{
    self.alpha = 1.0f;
    if (self.toolPopup) {
        [self pullBack];
    }else{
        [self popUp];
    }
}


-(void)pullBack
{
    [self.toolBgView setUserInteractionEnabled:NO];
    self.toolPopup = NO;
    
    NSUInteger direction = [self popBackDirection];
    
    __block int index = 0;
    for (int i = 0; i < [self.tools count]; i++) {
        UIImageView* subView = [self.tools objectAtIndex:i];
        [UIView animateWithDuration:0.25f animations:^{
            if (direction == 1) {
                [subView setFrame:CGRectMake(0, 0, ASSIST_WIDTH, ASSIST_HEIGHT)];
            }else if (direction == 0){
                [subView setFrame:self.logoView.frame];
            }
            
        } completion:^(BOOL finished) {
            [self.toolBgImageView removeFromSuperview];
            [subView removeFromSuperview];
            @synchronized(self){
                index++;
            }
            if (index == [self.tools count] - 1) {
                [self pullBackFrame:direction];
                CGRect frame = self.logoView.frame;
                frame.origin.x = 0;
                self.logoView.frame = frame;
                [self.toolBgView setUserInteractionEnabled:YES];
            }
        }];
    }
}

-(void)popUp
{
    self.toolPopup = YES;
    [self.toolBgView setUserInteractionEnabled:NO];
    NSUInteger direction = [self popUpDirection];
    [self popUpFrame:direction];
    
    [self.toolBgView addSubview:self.toolBgImageView];
    
    if (direction == 1) {
        UIImage* leftImage = [UIImage imageNamed:@"tool_bg_left"];
        leftImage = [leftImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, NAVIGATION_BG_END_WIDTH, 0, NAVIGATION_DESIGN_WIDTH - NAVIGATION_TOOL_WIDTH)];
        [self.toolBgImageView setImage:leftImage];
        
        
        CGRect frame = self.logoView.frame;
        frame.origin.x = self.toolBgView.frame.size.width - frame.size.width;
        self.logoView.frame = frame;
    }else if (direction == 0){
        UIImage* rightImg = [UIImage imageNamed:@"tool_bg_right"];
        rightImg = [rightImg resizableImageWithCapInsets:UIEdgeInsetsMake(0, NAVIGATION_TOOL_WIDTH, 0, NAVIGATION_DESIGN_WIDTH - NAVIGATION_BG_END_WIDTH)];
        [self.toolBgImageView setImage:rightImg];
    }
    
    __block int index = 0;
    for (int i = 0; i < [self.tools count]; i++) {
        UIImageView* subView = [self.tools objectAtIndex:i];
        [self.toolBgView addSubview:subView];
        [UIView animateWithDuration:0.25f animations:^{
            if (direction == 0) {
                [subView setFrame:CGRectMake(ASSIST_WIDTH + i * NAVIGATION_TOOL_WIDTH + (i + 1) * NAVIGATION_TOOL_MARGIN, (ASSIST_HEIGHT - NAVIGATION_TOOL_HEIGHT) / 2, NAVIGATION_TOOL_WIDTH, NAVIGATION_TOOL_HEIGHT)];
            }else if (direction == 1){
                [subView setFrame:CGRectMake(NAVIGATION_BG_END_WIDTH + (NAVIGATION_TOOL_WIDTH + NAVIGATION_TOOL_MARGIN) * i, (ASSIST_HEIGHT - NAVIGATION_TOOL_HEIGHT) / 2, NAVIGATION_TOOL_WIDTH, NAVIGATION_TOOL_HEIGHT)];
            }
            
        } completion:^(BOOL finished) {
            @synchronized(self){
                index++;
            }
            if (index == [self.tools count] - 1) {
                [self.toolBgView setUserInteractionEnabled:YES];
            }
        }];
    }
    [self.toolBgView bringSubviewToFront:self.logoView];
}

-(NSUInteger)popUpDirection
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect frame = [self.toolBgView convertRect:[self.logoView frame] toView:[[UIApplication sharedApplication] keyWindow]];
    if (NAVIGATION_DESIGN_WIDTH + frame.origin.x > screenRect.size.width) {
        return 1;
    }
    return 0;
}

-(NSUInteger)popBackDirection
{
    CGRect frame = self.logoView.frame;
    if (frame.origin.x == 0) {
        return 1;
    }
    return 0;
}

-(void)popUpFrame:(NSUInteger)direction
{
    CGFloat width = self.toolBgImageView.bounds.size.width;
    CGRect frame = self.frame;
    if (frame.size.width < width) {
        frame.size.width = width;
        if (direction == 1) {
            frame.origin.x -= width - ASSIST_WIDTH;
        }
        self.frame = [self visiableFrame:frame];
    }
    
    CGRect bgFrame = self.toolBgView.frame;
    bgFrame.size.width = width;
    self.toolBgView.frame = [self visiableFrame:bgFrame];
}

-(void)pullBackFrame:(NSUInteger)direction
{
    CGFloat width = self.toolBgImageView.bounds.size.width;
    CGRect frame = self.frame;
    if (frame.size.width <= width) {
        if (direction == 0) {
            frame.origin.x += frame.size.width - ASSIST_WIDTH;
        }
        frame.size.width = ASSIST_WIDTH;
        self.frame = frame;
    }
    
    CGRect bgFrame;
    if (self.open) {
        bgFrame = [self.toolBgView convertRect:self.logoView.frame toView:self];
    }else{
        bgFrame = self.toolBgView.frame;
        bgFrame.size.width = ASSIST_WIDTH;
    }
    self.toolBgView.frame = bgFrame;
}

-(CGRect)visiableFrame:(CGRect)frame
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    if (frame.origin.x < 0) {
        frame.origin.x = 0;
    }
    if (frame.origin.x + frame.size.width > rect.size.width) {
        frame.origin.x = rect.size.width - frame.size.width;
    }
    if (frame.origin.y < 0) {
        frame.origin.y = 0;
    }
    if (frame.origin.y + frame.size.height > rect.size.height) {
        frame.origin.y = rect.size.height - frame.size.height;
    }
    return frame;
}

-(void)closeWindow
{
    if ([self open]) {
        [UIView animateWithDuration:0.2f animations:^{
            self.transform = CGAffineTransformScale(self.transform, 0.2f, 0.2f);
        } completion:^(BOOL finished) {
            self.transform = CGAffineTransformIdentity;
            [self setRootViewController:nil];
            [self setWindowStatus:AssistWindow];
            self.alpha = 1.0f;
            [self windowMoveSide];
        }];
    }
}

-(void)windowMoveSide
{
    [self.toolBgView setUserInteractionEnabled:NO];
    CGPoint center = [self sidePoint];
    [UIView animateWithDuration:0.2f delay:0.1f options:0 animations:^{
        self.center = center;
    } completion:^(BOOL finished) {
        self.alpha = 0.5f;
        [self.toolBgView setUserInteractionEnabled:YES];
    }];
}

-(CGPoint)sidePoint
{
    UIView* targetView = self;
    if ([self open]) {
        targetView = self.toolBgView;
    }
    CGPoint center = targetView.center;
    CGSize size = [[UIScreen mainScreen] bounds].size;
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    NSArray* numbers = @[@(center.x), @(center.y), @(width - center.x), @(height - center.y)];
    CGFloat position = [self positionMinNumber:numbers];
    CGPoint point = center;
    if (position == 0) {
        point.x = 0;
    }else if (position == 1){
        point.y = 0;
    }else if (position == 2){
        point.x = width;
    }else if (position == 3){
        point.y = height;
    }
    return point;
}

-(int)positionMinNumber:(NSArray*)numbers
{
    __block int position = 0;
    __block CGFloat min = [[numbers objectAtIndex:0] floatValue];
    [numbers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat value = [obj floatValue];
        if (value < min) {
            min = value;
            position = (int)idx;
        }
    }];
    return position;
}

-(CGRect)rectOfWindow:(YDAssistiveTouchStatus)status
{
    CGSize size = [[UIScreen mainScreen] bounds].size;
    CGFloat width, height;
    if (status == AssistWindow) {
        width = ASSIST_WIDTH;
        height = ASSIST_HEIGHT;
    }/*else if(status == NavigationWindow){
        width = NAVIGATION_DESIGN_WIDTH;
        height = NAVIGATION_HEIGHT;
    }*/else if(status == DialogWindow){
        width = WINDOW_WIDTH;
        height = WINDOW_HEIGHT;
    }else {
        width = size.width;
        height = size.height;
    }
    
    if (width > size.width) {
        CGFloat rate = size.width / width;
        width = size.width;
        height = height * rate;
    }
    CGFloat x = (size.width - width) / 2;
    CGFloat y = (size.height - height) / 2;
    return CGRectMake(x, y, width, height);
}


#pragma UIGestureRecognizerDelegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

-(void)dealloc
{
}

@end

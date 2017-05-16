//
//  ViewController.m
//  Demo
//
//  Created by fm on 2017/5/16.
//  Copyright © 2017年 wangjiuyin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<FMTouchIDDelegate>

@property (nonatomic, strong) FMTouchID *touchID;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.touchID evaluatePolicyWithFallbackTitle:@"Touch ID" andLocalizedReason:@"通过Home键验证已有手机指纹"];
}

#pragma mark - PCTouchIDDelegate
- (void)appTouchIDClosed
{
    NSLog(@"appTouchIDClosed");
}

- (void)devicePasswordNotSet
{
    NSLog(@"devicePasswordNotSet");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"指纹" message:@"您的设备没有开启密码..." delegate:self cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
    
    [alert show];
}

- (void)touchIDNotEnrolled
{
    NSLog(@"touchIDNotEnrolled");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"指纹" message:@"您的设备没有录入指纹..." delegate:self cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
    
    [alert show];
}

- (void)touchIDInfomationHaveChange
{
    NSLog(@"touchIDInfomationHaveChange");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"指纹" message:@"您的指纹信息已经发生变化..." delegate:self cancelButtonTitle:@"使用登录密码" otherButtonTitles:@"取消", nil];
    
    [alert show];
}

- (void)touchIDIsNotAvailableOnThisDevice
{
    NSLog(@"touchIDIsNotAvailableOnThisDevice");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"指纹" message:@"您的设备不支持指纹..." delegate:self cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
    
    [alert show];
}

- (void)touchIDWorkWell
{
    NSLog(@"touchIDWorkWell");
    [self.touchID evaluatePolicyWithFallbackTitle:@"Touch ID" andLocalizedReason:@"通过Home键验证已有手机指纹"];
}

- (void)touchIDValideSuccess
{
    NSLog(@"touchIDValideSuccess");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"指纹" message:@"验证成功" delegate:self cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
    
    [alert show];
}

- (void)touchIDCancell
{
    NSLog(@"已取消");
}

- (void)touchIDSelectFallback
{
    NSLog(@"touchIDSelectFallback");
}

#pragma mark - getter & setter
- (FMTouchID *)touchID
{
    if (!_touchID) {
        _touchID = [[FMTouchID alloc] init];
        _touchID.delegate = self;
    }
    return _touchID;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

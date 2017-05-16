//
//  FMTouchID.h
//  Demo
//
//  Created by fm on 2017/5/16.
//  Copyright © 2017年 wangjiuyin. All rights reserved.
//

#import <LocalAuthentication/LocalAuthentication.h>

@class FMTouchID;
@protocol FMTouchIDDelegate <NSObject>

@optional
- (void)appTouchIDClosed;  //应用中关闭了指纹
- (void)devicePasswordNotSet;    //设备的密码没有开启
- (void)touchIDNotEnrolled;    //开启了密码，但是没有设置指纹
- (void)touchIDInfomationHaveChange;    //指纹信息发生变化
- (void)touchIDIsNotAvailableOnThisDevice;   //设备不支持指纹
- (void)touchIDWorkWell;    //指纹工作正常
- (void)touchIDValideSuccess;    //验证成功
- (void)touchIDSelectFallback;   //点击了 fallback
- (void)touchIDCancell;  // 点击了取消

@end

typedef NS_ENUM(NSUInteger, TouchIDStatus) {
    kTouchIDStatusNormal = 1, //指纹正常
    kTouchIDStatusClose,  //app指纹关闭
    kTouchIDStatusUseless,  //系统指纹被关闭了
    kTouchIDStatusNone   //设备没有指纹，机型和系统版本不支持
};

static  NSString *kTouchIDClosed = @"kTouchIDClosed";
static  NSString *kTouchIDUsing = @"kTouchIDUsing";

@interface FMTouchID : LAContext

@property (nonatomic, assign) TouchIDStatus status;  //指纹状态

@property (nonatomic, weak) id<FMTouchIDDelegate> delegate;

- (void)evaluatePolicyWithFallbackTitle:(NSString *)title andLocalizedReason:(NSString *)reason;   //开启指纹

@end

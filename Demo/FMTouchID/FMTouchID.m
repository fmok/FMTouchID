//
//  FMTouchID.m
//  Demo
//
//  Created by fm on 2017/5/16.
//  Copyright © 2017年 wangjiuyin. All rights reserved.
//

#import "FMTouchID.h"

static const NSString *kServiceName = @"com.serviceName";

@implementation FMTouchID

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setLocalAuthentication];
    }
    return self;
}

#pragma mark - Public methods
- (void)evaluatePolicyWithFallbackTitle:(NSString *)title andLocalizedReason:(NSString *)reason
{
    self.localizedFallbackTitle = title;
    [self evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:reason reply:^(BOOL success, NSError *error) {
        if (success) {
            if (![[NSUserDefaults standardUserDefaults] objectForKey:kTouchIDUsing]) {
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kTouchIDUsing];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (_delegate && [_delegate respondsToSelector:@selector(touchIDValideSuccess)]) {
                    [_delegate touchIDValideSuccess];
                }
            });
        } else{
            if (error.code == kLAErrorUserCancel) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (_delegate && [_delegate respondsToSelector:@selector(touchIDCancell)]) {
                        [_delegate touchIDCancell];
                    }
                });
            } else if(error.code == kLAOptionUserFallback){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (_delegate && [_delegate respondsToSelector:@selector(touchIDSelectFallback)]) {
                        [_delegate touchIDSelectFallback];
                    }
                });
            }
        }
    }];
}

#pragma mark - Private methods
- (void)setLocalAuthentication
{
    CFErrorRef error = NULL;
    SecAccessControlRef sacObject;
    sacObject = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                                kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                                                kSecAccessControlUserPresence, &error);
    if(sacObject == NULL || error != NULL)
    {
        NSLog(@"can't create sacObject: %@", error);
        return;
    }
    NSDictionary *attributes = @{
                                 (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                                 (__bridge id)kSecAttrService: kServiceName,
                                 (__bridge id)kSecValueData: [@"SECRET_PASSWORD_TEXT" dataUsingEncoding:NSUTF8StringEncoding],
                                 (__bridge id)kSecUseNoAuthenticationUI: @YES,
                                 (__bridge id)kSecAttrAccessControl: (__bridge id)sacObject
                                 };
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        SecItemAdd((__bridge CFDictionaryRef)attributes, nil);
    });
}

- (void)canEvaluatePolicy
{
    if ([self isTouchIDClosed]) {
        if (_delegate && [_delegate respondsToSelector:@selector(appTouchIDClosed)]) {
            [_delegate appTouchIDClosed];
        }
        _status = kTouchIDStatusClose;
        return;
    }
    NSError *error;
    [self canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    if (error.code == kLAErrorPasscodeNotSet) {
        if (_delegate && [_delegate respondsToSelector:@selector(devicePasswordNotSet)]) {
            [_delegate devicePasswordNotSet];
        }
        _status = kTouchIDStatusNone;
        return;
    } else if (error.code == kLAErrorTouchIDNotEnrolled){
        if ([self isUsingTouchID]) {
            if (_delegate && [_delegate respondsToSelector:@selector(touchIDInfomationHaveChange)]) {
                [_delegate touchIDInfomationHaveChange];
            }
            _status = kTouchIDStatusUseless;
        } else {
            if (_delegate && [_delegate respondsToSelector:@selector(touchIDNotEnrolled)]) {
                [_delegate touchIDNotEnrolled];
            }
            _status = kTouchIDStatusNone;
        }
        return;
    } else if (error.code == kLAErrorTouchIDNotAvailable){
        if (_delegate && [_delegate respondsToSelector:@selector(touchIDIsNotAvailableOnThisDevice)]) {
            [_delegate touchIDIsNotAvailableOnThisDevice];
        }
        return;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(touchIDWorkWell)]) {
        [_delegate touchIDWorkWell];
    }
    _status  = kTouchIDStatusNormal;
}

- (BOOL)isUsingTouchID
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    id isClose = [userDefaults objectForKey:kTouchIDClosed];
    id isUsing = [userDefaults objectForKey:kTouchIDUsing];
    if (!isClose) {
        if (isUsing)return YES;
    }
    return NO;
}
- (BOOL)isTouchIDClosed
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    id isClose = [userDefaults objectForKey:kTouchIDClosed];
    
    if (isClose) {
        return YES;
    }
    return NO;
}

#pragma mark - getter & setter
- (void)setDelegate:(id<FMTouchIDDelegate>)delegate
{
    _delegate = delegate;
    [self canEvaluatePolicy];
}


@end

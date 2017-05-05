//
//  STAlertTool.h
//  Ecshop
//
//  Created by 8dage on 16/5/30.
//  Copyright © 2016年 8dage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef void (^ConfirmClickBlock)();
typedef void (^CancelClickBlock)();
@interface STAlertTool : NSObject<UIAlertViewDelegate>
+(void)initWithViewController:(nonnull UIViewController *)viewController title:(nullable NSString*)title  message:(nullable NSString *)messge cancleButtonTitle:(nullable NSString *)cancleButtonTitle OtherButton:(nullable NSString*)otherButton otherButtonClick:(nullable ConfirmClickBlock)otherButtonClick cancelClick:(nullable CancelClickBlock)cancelClick;

@end

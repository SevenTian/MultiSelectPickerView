//
//  STAlertTool.m
//  Ecshop
//
//  Created by 8dage on 16/5/30.
//  Copyright © 2016年 8dage. All rights reserved.
//

#import "STAlertTool.h"
#import <objc/runtime.h>
#define ALERTIOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

const char *AlertViewCancel_Block = "alertViewCancel_Block";
const char *AlertView_Block = "alertView_Block";
@interface UIAlertView(ICInfomationView_Runtime)
-(void)setClickBlock:(ConfirmClickBlock)block;
-(ConfirmClickBlock)clickBlock;
-(void)setCancelClickBlock:(CancelClickBlock)block;
-(CancelClickBlock)cancelClickBlock;
@end
@implementation UIAlertView(ICInfomationView_Runtime)
-(void)setClickBlock:(ConfirmClickBlock)block{
    objc_setAssociatedObject(self, AlertView_Block, block, OBJC_ASSOCIATION_COPY);
}
-(ConfirmClickBlock)clickBlock{
    return objc_getAssociatedObject(self, AlertView_Block);
}
- (void)setCancelClickBlock:(CancelClickBlock)block
{
    objc_setAssociatedObject(self, AlertViewCancel_Block, block, OBJC_ASSOCIATION_COPY);
}
- (CancelClickBlock)cancelClickBlock
{
    return objc_getAssociatedObject(self, AlertViewCancel_Block);
}
@end

@interface STAlertTool ()

@end
@implementation STAlertTool
+(void)initWithViewController:(nonnull UIViewController *)viewController title:(nullable NSString*)title  message:(nullable NSString *)messge cancleButtonTitle:(nullable NSString *)cancleButtonTitle OtherButton:(nullable NSString*)otherButton otherButtonClick:(nullable ConfirmClickBlock)otherButtonClick cancelClick:(nullable CancelClickBlock)cancelClick
{
    if (ALERTIOS8) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:messge preferredStyle:UIAlertControllerStyleAlert];
        if (cancleButtonTitle) {
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancleButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                if (cancelClick) {
                    cancelClick();
                }
                [viewController dismissViewControllerAnimated:YES completion:nil];
            }];
            [alertController addAction:cancelAction];
        }
        if (otherButton) {
            UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButton style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                if (otherButtonClick) {
                    otherButtonClick();
                }
            }];
            [alertController addAction:otherAction];
        }
        
        [viewController presentViewController:alertController animated:YES completion:nil];
    } else {
        UIAlertView  *Al = [[UIAlertView alloc] initWithTitle:title message:messge delegate:self cancelButtonTitle:cancleButtonTitle otherButtonTitles:otherButton, nil];
        Al.clickBlock = otherButtonClick;
        Al.cancelClickBlock = cancelClick;
        [Al show];
    }
}

#pragma mark   UIAlertViewDelegate
+(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if (alertView.clickBlock) {
            alertView.clickBlock();
        }
    }else
    {
        if (alertView.cancelClickBlock) {
            alertView.cancelClickBlock();
        }
    }
}
@end

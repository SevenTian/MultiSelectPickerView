//
//  STAssetPickerRootViewController.h
//  ImagePicker
//
//  Created by 8dage on 16/5/31.
//  Copyright © 2016年 8dage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STAssetPickerViewController.h"
@interface STAssetPickerRootViewController : UINavigationController
/**
 *  调用此方法，模态视图
 *
 *  @param selectedArray 多次选择需要把之前选择好的图片数组传进去，以此标记之前选择好的图片
 *  @param photos        返回选择好的图片数组，利用STAssetModel类获取缩略图或者原图
 *  @param number 限制最多选择图片张数，默认不限制
 */
- (instancetype)initWithSelectedArray:(NSMutableArray *)selectedArray maxImageNumber:(NSInteger)number photos:(void(^)(NSMutableArray *allselectedArray, NSMutableArray *currentSelectedArray))photos;
@end

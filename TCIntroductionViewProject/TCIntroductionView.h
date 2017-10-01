//
//  TCIntoductionView.h
//  trackCar
//
//  Created by yangyh on 2017/9/12.
//  Copyright © 2017年 Jonathan. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kScreen_height_Introduction  [[UIScreen mainScreen] bounds].size.height
#define kScreen_width_Introduction   [[UIScreen mainScreen] bounds].size.width

///!!!:iPhone X适配
#define kDevice_Is_iPhoneX_Introduction ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

@interface TCIntroductionView : UIView

/**
 是否是首次加载

 @return YES为首次加载
 */
+ (BOOL)isFirstLauch;

/**
 带按钮的引导页

 @param imageNames 背景图片数组
 @param btnTitle 按钮标题
 @param buttonImage 按钮的图片
 @param frame 按钮的frame
 @return LaunchIntroductionView 对象
 */
+ (instancetype)sharedWithImages:(NSArray *)imageNames
                   enterBtnTitle:(NSString *)btnTitle
                     buttonImage:(UIImage *)buttonImage
                     buttonFrame:(CGRect)frame;

@end

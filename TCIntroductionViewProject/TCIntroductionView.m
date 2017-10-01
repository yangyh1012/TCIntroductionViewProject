//
//  TCIntoductionView.m
//  trackCar
//
//  Created by yangyh on 2017/9/12.
//  Copyright © 2017年 Jonathan. All rights reserved.
//

#import "TCIntroductionView.h"

static NSString *const kAppVersion = @"appVersion";

@interface TCIntroductionView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *launchScrollView;

@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) NSMutableArray *buttonArrays;

@end

@implementation TCIntroductionView

BOOL isScrollOut;//在最后一页再次滑动是否隐藏引导页
NSString *enterBtnTitle;
CGRect enterBtnFrame;
UIImage *enterBtnImage;
NSArray *images;
static TCIntroductionView *launch = nil;

+ (instancetype)sharedWithImages:(NSArray *)imageNames
                   enterBtnTitle:(NSString *)btnTitle
                     buttonImage:(UIImage *)buttonImage
                     buttonFrame:(CGRect)frame {
    
    images = imageNames;
    isScrollOut = NO;
    enterBtnTitle = btnTitle;
    enterBtnFrame = frame;
    enterBtnImage = buttonImage;
    launch = [[TCIntroductionView alloc] initWithFrame:CGRectMake(0, 0, kScreen_width_Introduction, kScreen_height_Introduction)];
    launch.backgroundColor = [UIColor whiteColor];
    
    return launch;
}

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addObserver:self forKeyPath:@"currentColor" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"nomalColor" options:NSKeyValueObservingOptionNew context:nil];
        
        UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
        [window addSubview:self];
        [self addImages];
    }
    
    return self;
}

#pragma mark - 判断是不是首次登录或者版本更新

+ (BOOL)isFirstLauch {
    
    //获取当前版本号
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *currentAppVersion = infoDic[@"CFBundleShortVersionString"];
    
    //获取上次启动应用保存的appVersion
    NSString *version = [[NSUserDefaults standardUserDefaults] objectForKey:kAppVersion];
    
    //版本升级或首次登录
    if (version == nil || ![version isEqualToString:currentAppVersion]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:currentAppVersion forKey:kAppVersion];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        return YES;
    } else {
        
        return NO;
    }
}

#pragma mark - 添加引导页图片

- (void)addImages {
    
    [self createScrollView];
}

#pragma mark - 创建滚动视图

- (void)createScrollView {
    
    CGFloat height = 0;
    CGFloat orginY = 0;
    if (kDevice_Is_iPhoneX_Introduction) {
        
        height = kScreen_height_Introduction - 145;
        orginY = 100.0f;
    } else {
        
        height = kScreen_height_Introduction;
        orginY = 0;
    }
    self.launchScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, orginY, kScreen_width_Introduction, height)];
    self.launchScrollView.showsHorizontalScrollIndicator = NO;
    self.launchScrollView.bounces = NO;
    self.launchScrollView.pagingEnabled = YES;
    self.launchScrollView.delegate = self;
    self.launchScrollView.contentSize = CGSizeMake(kScreen_width_Introduction * images.count, height);
    [self addSubview:self.launchScrollView];
    for (int i = 0; i < images.count; i ++) {
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * kScreen_width_Introduction, 0, kScreen_width_Introduction, height)];
        imageView.image = [UIImage imageNamed:images[i]];
        [self.launchScrollView addSubview:imageView];
        if (i == images.count - 1) {
            
            //判断要不要添加button
            if (!isScrollOut) {
                
                UIButton *enterButton = [[UIButton alloc] initWithFrame:CGRectMake(enterBtnFrame.origin.x, enterBtnFrame.origin.y - orginY, enterBtnFrame.size.width, enterBtnFrame.size.height)];
                [enterButton setBackgroundImage:enterBtnImage forState:UIControlStateNormal];
                [enterButton setTitle:enterBtnTitle forState:UIControlStateNormal];
                enterButton.titleLabel.font = [UIFont systemFontOfSize:19.0f];
                enterButton.layer.masksToBounds = YES;
                enterButton.layer.cornerRadius = 10.0f;
                [enterButton addTarget:self action:@selector(enterBtnClick) forControlEvents:UIControlEventTouchUpInside];
                [imageView addSubview:enterButton];
                imageView.userInteractionEnabled = YES;
            }
        }
    }
    
    UIButton *button0 = [self buttonInit];
    UIButton *button1 = [self buttonInit];
    UIButton *button2 = [self buttonInit];
    self.buttonArrays = [[NSMutableArray alloc] initWithObjects:button0,button1,button2, nil];
    [self buttonSelectSetWithIndex:0];
    
    button0.frame = CGRectMake((kScreen_width_Introduction - 17)/2.0 - 30, kScreen_height_Introduction - 60, 17, 9);
    [self addSubview:button0];
    
    button1.frame = CGRectMake((kScreen_width_Introduction - 17)/2.0, kScreen_height_Introduction - 60, 17, 9);
    [self addSubview:button1];
    
    button2.frame = CGRectMake((kScreen_width_Introduction - 17)/2.0 + 30, kScreen_height_Introduction - 60, 17, 9);
    [self addSubview:button2];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, kScreen_height_Introduction - 50, kScreen_width_Introduction, 30)];
    self.pageControl.numberOfPages = images.count;
    [self addSubview:self.pageControl];
    self.pageControl.hidden = YES;
}

- (UIButton *)buttonInit {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"introduction_button_normal"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"introduction_button_select"] forState:UIControlStateSelected];
    
    return button;
}

- (void)buttonSelectSetWithIndex:(NSInteger)index {
    
    for (UIButton *button in self.buttonArrays) {
        
        button.selected = NO;
    }
    
    UIButton *currentButton = self.buttonArrays[index];
    currentButton.selected = YES;
}

#pragma mark - 进入按钮

- (void)enterBtnClick {
    
    [self hideGuidView];
}

#pragma mark - 隐藏引导页

- (void)hideGuidView {
    [UIView animateWithDuration:0.5 animations:^{
        
        self.alpha = 0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self removeFromSuperview];
        });
    }];
}

#pragma mark - scrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    NSInteger cuttentIndex = (NSInteger)(scrollView.contentOffset.x + kScreen_width_Introduction / 2) / kScreen_width_Introduction;
    if (cuttentIndex == images.count - 1) {
        
        if ([self isScrolltoLeft:scrollView]) {
            
            if (!isScrollOut) {
                
                return ;
            }
            
            [self hideGuidView];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView == self.launchScrollView) {
        
        NSInteger cuttentIndex = (NSInteger)(scrollView.contentOffset.x + kScreen_width_Introduction / 2) / kScreen_width_Introduction;
        self.pageControl.currentPage = cuttentIndex;
        [self buttonSelectSetWithIndex:cuttentIndex];
    }
}

#pragma mark - 判断滚动方向

- (BOOL)isScrolltoLeft:(UIScrollView *)scrollView {
    
    //返回YES为向左反动，NO为右滚动
    if ([scrollView.panGestureRecognizer translationInView:scrollView.superview].x < 0) {
        
        return YES;
    } else {
        
        return NO;
    }
}

@end

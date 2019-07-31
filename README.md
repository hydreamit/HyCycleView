# HYCycleView

 HyCycleView(可定制轮播:支持view/controller, 左右上下四个方向);  <br>  

 HyCyclePageView(可定制PageView:支持无限循环、view/controller、scrollView嵌套悬停(两种解决方案)); <br>  

 HySegmentView(可定制SegmentView:支持自定义每一个item及动画view);


## 如何导入

__Podfile__

```
pod 'HyCycleView'
```

__手动导入__

直接将`HyCycleView`文件夹拖入项目中

## 如何使用

### HyCycleView

* .h头文件

```objc

@interface HyCycleView : UIView

/**
 create cycleView

 @param frame frame
 @param configureBlock config the params
 @return HyCycleView
 */
+ (instancetype)cycleViewWithFrame:(CGRect)frame
                    configureBlock:(void (^)(HyCycleViewConfigure *configure))configureBlock;

@property (nonatomic, strong, readonly) HyCycleViewConfigure *configure;

/**
 scroll to next page

 @param animated animated
 */
- (void)scrollToNextPageWithAnimated:(BOOL)animated;

/**
 scroll to last page
 
 @param animated animated
 */
- (void)scrollToLastPageWithAnimated:(BOOL)animated;

/**
 scroll to the page

 @param page page
 @param animated animated
 */
- (void)scrollToPage:(NSInteger)page animated:(BOOL)animated;

@end
```


* 链式用法

```objc
__weak typeof(self) weakSelf = self;
UIPageControl *pageControl = [[UIPageControl alloc] init];
pageControl.currentPageIndicatorTintColor = UIColor.orangeColor;

[HyCycleView cycleViewWithFrame:CGRectMake(30, 100, 150, 130)
                 configureBlock:^(HyCycleViewConfigure *configure) {

                     configure
                     .totalPage(weakSelf.imageNameArray.count)
                     .cycleClasses(@[UIImageView.class])
                     .viewWillAppear(^(HyCycleView *cycleView,
                                       UIImageView *imageView,
                                       NSInteger index,
                                       BOOL isfirstLoad){
                         if (isfirstLoad) {
                             imageView.contentMode = UIViewContentModeScaleAspectFill;
                             imageView.image = [UIImage imageNamed:weakSelf.imageNameArray[index]];
                         }
                     })
                     .roundingPageChange(^(HyCycleView *cycleView,
                                           NSInteger totalPage,
                                           NSInteger currentPage){

                         if (!pageControl.superview && totalPage > 1) {
                             CGFloat pageW = 15 * totalPage;
                             CGFloat pageH = 20;
                             CGFloat pageX = (cycleView.frame.size.width - pageW) / 2;
                             CGFloat pageY = cycleView.frame.size.height - pageH;
                             pageControl.frame = CGRectMake(pageX, pageY, pageW, pageH);
                             [cycleView addSubview:pageControl];
                             pageControl.numberOfPages = totalPage;
                         }
                         pageControl.currentPage = currentPage;
                     })
                     .clickAction(^(HyCycleView *cycleView, NSInteger index){

                         NSLog(@"clickAction====%tu", index);
                     });
                 }];
```

* Demo图片 <br>
图片轮播:![图片轮播](https://github.com/hydreamit/HyCycleView/blob/master/Pictures/HyCycleView_One.gif)
自定义轮播:![自定义轮播](https://github.com/hydreamit/HyCycleView/blob/master/Pictures/HyCycleView_Two.gif)
控制器轮播:![控制器轮播](https://github.com/hydreamit/HyCycleView/blob/master/Pictures/HyCycleView_Three.gif)


### HyCyclePageView



### HySegmentView

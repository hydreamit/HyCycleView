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

#### .h头文件

```objc
@interface HyCycleViewConfigure : NSObject

// currentPage (当前页面)
@property (nonatomic,assign,readonly) NSInteger currentPage;

// cycle loop default yes (是否为无限循环轮播 默认为YES)
- (HyCycleViewConfigure *(^)(BOOL))isCycleLoop;
// total Pages (总页数)
- (HyCycleViewConfigure *(^)(NSInteger))totalPage;
// start page (开始页)
- (HyCycleViewConfigure *(^)(NSInteger))startPage;
// timeInterval default 2.0 s (自动轮播时间间隔 默认2秒)
- (HyCycleViewConfigure *(^)(NSTimeInterval))timeInterval;

// auto or static scroll style (轮播方式：自动/手动, 默认是自动)
- (HyCycleViewConfigure *(^)(HyCycleViewScrollStyle))scrollStyle;
// cycle view load style (轮播View/Controller加载方式: 滑动出现立即加载/滑动到整个页面再加载)
- (HyCycleViewConfigure *(^)(HyCycleViewScrollLoadStyle))loadStyle;
// scroll direction (轮播方向:左、右、上、下)
- (HyCycleViewConfigure *(^)(HyCycleViewScrollDirection))scrollDirection;

// cycle views or controllers of class (轮播传入的是Class：view class 或者 controller class)
- (HyCycleViewConfigure *(^)(NSArray<Class> *))cycleClasses;
- (HyCycleViewConfigure *(^)(Class (^)(HyCycleView *, NSInteger)))cycleClass;
// cycle views or controllers (轮播传入的是实例对象：view 或者 controller)
- (HyCycleViewConfigure *(^)(NSArray *))cycleInstances;
- (HyCycleViewConfigure *(^)(id (^)(HyCycleView *, NSInteger)))cycleInstance;

// click cycleView action (点击某个轮播view的回调)
- (HyCycleViewConfigure *(^)(void(^)(HyCycleView *, NSInteger)))clickAction;

// one cycle will appear callback (当轮播view/controllerView出现的回调)
- (HyCycleViewConfigure *(^)(void(^)(HyCycleView *,  // HyCycleView
                                     id,            // cycleView
                                     NSInteger,    // currentIndex
                                     BOOL))       // is first load
                                     )viewWillAppear;

// totalPage and currentPage change (总页/当前页发生改变的回调)
- (HyCycleViewConfigure *(^)(void(^)(HyCycleView *, // HyCycleView
                                     NSInteger,    // totalPage
                                     NSInteger))  // currentPage
                                     )currentPageChange;

// totalPage and roundingPage change (总页/当前页(四舍五入)发生改变的回调)
- (HyCycleViewConfigure *(^)(void(^)(HyCycleView *, // HyCycleView
                                     NSInteger,    // totalPage
                                     NSInteger))  // roundingPage
                                     )roundingPageChange;

// scroll progress (滑动进度的回调)
- (HyCycleViewConfigure *(^)(void(^)(HyCycleView *, // HyCycleView
                                     NSInteger,    // fromPage
                                     NSInteger,   // toPage
                                     CGFloat))   // progress
                                    )scrollProgress;
@end


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


#### 链式用法

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

#### Demo图片 

* 图片轮播<br>
![图片轮播](https://github.com/hydreamit/HyCycleView/blob/master/Pictures/HyCycleView_One.gif)
* 自定义轮播<br>
![自定义轮播](https://github.com/hydreamit/HyCycleView/blob/master/Pictures/HyCycleView_Two.gif)
* 控制器轮播<br>
![控制器轮播](https://github.com/hydreamit/HyCycleView/blob/master/Pictures/HyCycleView_Three.gif)


### HyCyclePageView

#### .h头文件
```objc
@interface HyCyclePageViewConfigure : NSObject

// currentPage
@property (nonatomic,assign,readonly) NSInteger currentPage;

// gesture Style(需要悬停嵌套scrollView时的 手势处理方式)
- (HyCyclePageViewConfigure *(^)(HyCyclePageViewGestureStyle))gestureStyle;
// header refresh style
- (HyCyclePageViewConfigure *(^)(HyCyclePageViewHeaderRefreshStyle))headerRefreshStyle;

// header view (头部视图)
- (HyCyclePageViewConfigure *(^)(UIView *))headerView;
// header view height (头部视图高度)
- (HyCyclePageViewConfigure *(^)(CGFloat ))headerViewHeight;
// header view up Animation(头部视图上滑动画)
- (HyCyclePageViewConfigure *(^)(HyCyclePageViewHeaderViewUpAnimation))headerViewUpAnimation;
// header view down Animation(头部视图下拉动画)
- (HyCyclePageViewConfigure *(^)(HyCyclePageViewHeaderViewDownAnimation))headerViewDownAnimation;

// hover view (悬停视图)
- (HyCyclePageViewConfigure *(^)(UIView *))hoverView;
// hover view (悬停视图高度)
- (HyCyclePageViewConfigure *(^)(CGFloat))hoverViewHeight;
//hover offset default 0 (悬停位置偏移量 默认为0)
- (HyCyclePageViewConfigure *(^)(CGFloat))hoverOffset;

// cycle page loop default yes (是否为无限循环 默认为YES)
- (HyCyclePageViewConfigure *(^)(BOOL))isCycleLoop;
// start page (开始页)
- (HyCyclePageViewConfigure *(^)(NSInteger))startPage;
// total Pages (总页数)
- (HyCyclePageViewConfigure *(^)(NSInteger))totalPage;

// cycle page view load style (view/Controller加载方式: 滑动出现立即加载/滑动到整个页面再加载)
- (HyCyclePageViewConfigure *(^)(HyCycleViewScrollLoadStyle))loadStyle;
// cycle views/controllers of class (传入的是class)
- (HyCyclePageViewConfigure *(^)(Class (^)(HyCyclePageView *, NSInteger)))cyclePageClass;
// cycle page views/controllers (传入的是实例对象)
- (HyCyclePageViewConfigure *(^)(id (^)(HyCyclePageView *, NSInteger)))cyclePageInstance;


// one page view will appear callback (view 即将出现的回调)
- (HyCyclePageViewConfigure *(^)(void(^)(HyCyclePageView *,  // HyCyclePageView
                                         id,                // cycleView
                                         NSInteger,        // currentIndex
                                         BOOL))           // is first load
                                        )viewWillAppear;

// totalPage and currentPage change (总页/当前页发生改变的回调)
- (HyCyclePageViewConfigure *(^)(void(^)(HyCyclePageView *, // HyCycleView
                                         NSInteger,        // totalPage
                                         NSInteger))      // currentPage
                                         )currentPageChange;

// totalPage and roundingPage change (总页/当前页(四舍五入)发生改变的回调)
- (HyCyclePageViewConfigure *(^)(void(^)(HyCyclePageView *, // HyCycleView
                                         NSInteger,        // totalPage
                                         NSInteger))      // roundingPage
                                        )roundingPageChange;


// horizontal scroll progress (水平滑动进度的回调)
- (HyCyclePageViewConfigure *(^)(void(^)(HyCyclePageView *, // HyCyclePageView
                                         NSInteger,        // fromPage
                                         NSInteger,       // toPage
                                         CGFloat))       // progress
                                        )horizontalScroll;

// vertical scroll  (上下滑动的回调)
- (HyCyclePageViewConfigure *(^)(void(^)(HyCyclePageView *, // HyCyclePageView
                                         CGFloat ,         // contentOffset y
                                         NSInteger))      // currentPage
                                         )verticalScroll;

// header refresh
- (HyCyclePageViewConfigure *(^)(void(^)(HyCyclePageView *, // HyCyclePageView
                                         UIScrollView *,   // scrollView
                                         NSInteger))      // currentPage
                                         )headerRefresh;

// footer refresh
- (HyCyclePageViewConfigure *(^)(void(^)(HyCyclePageView *, // HyCyclePageView
                                         UIScrollView *,   // scrollView
                                         NSInteger))      // currentPage
                                         )footerRefresh;

@end


@interface HyCyclePageView : UIView

/**
 create cyclePageView
 
 @param frame frame
 @param configureBlock config the params
 @return HyCyclePageView
 */
+ (instancetype)cyclePageViewWithFrame:(CGRect)frame
                        configureBlock:(void (^)(HyCyclePageViewConfigure *configure))configureBlock;


@property (nonatomic, strong, readonly) HyCyclePageViewConfigure *configure;

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
#### 链式用法
```objc
- (HyCyclePageView *)cyclePageView {
    if (!_cyclePageView){
         __weak typeof(self) weakSelf = self;
        _cyclePageView = [HyCyclePageView cyclePageViewWithFrame:_scrollView.bounds
                                                  configureBlock:^(HyCyclePageViewConfigure * _Nonnull configure) {
                                                      
                                                      configure
                                                      .totalPage(9)
                                                      .hoverView(weakSelf.hoverView)
                                                      .headerView(weakSelf.headerView)
                                                      .gestureStyle(weakSelf.gestureStyle)
                                                      .cyclePageInstance(^id(HyCyclePageView *pageView, NSInteger currentIndex){
                                                          return [weakSelf creatTableViewWithPageNumber:currentIndex];
                                                      })
                                                      .horizontalScroll(^(HyCyclePageView *cyclePageView,
                                                                          NSInteger fromPage,
                                                                          NSInteger toPage,
                                                                          CGFloat progress) {
                                                                          
                                                          [weakSelf.segmentView clickItemFromIndex:fromPage
                                                                                           toIndex:toPage
                                                                                          progress:progress];
                                                      });
                                                  }];
    }
    return _cyclePageView;
}
```

#### Demo图片 

* 无头部<br>
![图片轮播](https://github.com/hydreamit/HyCycleView/blob/master/Pictures/HyCyclePageView_One.gif)
* 有头部scrollView嵌套<br>
![自定义轮播](https://github.com/hydreamit/HyCycleView/blob/master/Pictures/HyCyclePageView_Two.gif)
* 有头部scrollView嵌套 动画<br>
![控制器轮播](https://github.com/hydreamit/HyCycleView/blob/master/Pictures/HyCyclePageView_Three.gif)
* 有头部scrollView嵌套 动画 自定义悬停View<br>
![控制器轮播](https://github.com/hydreamit/HyCycleView/blob/master/Pictures/HyCyclePageView_Four.gif)

### HySegmentView
* Demo图片<br> 
![控制器轮播](https://github.com/hydreamit/HyCycleView/blob/master/Pictures/HySegmentView.gif)

//
//  HYInfiniteScrollView.swift
//  ScrollViewDemo
//
//  Created by Harry Yan on 15/1/20.
//  Copyright (c) 2015年  Harry Yan. All rights reserved.
//

import UIKit

protocol HYInfiniteScrollViewDelegate {
    func didClickPageAtIndex(scrollView: UIScrollView, pageIndex: Int)
    func didSwipeToPage(scrollView: UIScrollView, pageIndex: Int)
}

class HYInfiniteScrollView: UIView, UIScrollViewDelegate{
    
    var isSliderBarControl: Bool = true
    var isPagesControl: Bool = false
    var isDragging: Bool = false                      //用户是否拖拽
    var currentPageIndex: Int = 0                     //当前页面
    var items: NSArray?                               //内容item
    var contentViews: NSMutableArray?                 //页面内容view
    var pictureViews: NSMutableArray?                 //图片数组
    var extraImageViews:NSMutableArray?               //当total page count为两个时的容器
    var scrollView: UIScrollView!                     //容器
    var animationTimer: NSTimer?                      //定时器
    var pageControl: UIPageControl? = nil             //系统默认page control
    
    var delegate: HYInfiniteScrollViewDelegate?       //代理
    
    //是否启用动画
    var animationEnable: Bool = true {
        willSet {
            if newValue {
                if (nil != self.animationTimer) {
                    self.animationTimer?.invalidate();
                    self.animationTimer = nil;
                }
                
                animationTimer = NSTimer.scheduledTimerWithTimeInterval(_animationDuration, target: self, selector: "animationTimerDidFired:", userInfo: nil, repeats: true)
                
                self.animationTimer?.pauseTimer()
            }
        }
    }
    
    var slideBarEnable: Bool = true {
        willSet{
            if newValue {
                isSliderBarControl = true
                isPagesControl = false
                sliderPageControl.hidden = false
            }else {
                sliderPageControl.hidden = true;
            }
        }
    }
    
    var _animationDuration: NSTimeInterval = 3.0      //滚动的时间间隔
    var animationDuration: NSTimeInterval? {
        willSet {
            _animationDuration = newValue!
        }
    }
    
    var _totalPageCount: Int? = 0                   //页面个数
    var totalPageCount: Int? {
        willSet(totalPage){
            _totalPageCount = totalPage
            
            if isPagesControl {
                pageControl?.numberOfPages = totalPage!
            }
            
            _sliderPageControl?.pageCount = totalPage!
            
            if _totalPageCount == 1 {
                self.configContenViews()
            }else if _totalPageCount > 1 {
                self.configContenViews()
                self.animationTimer?.resumeTimerAfterTimeInterval(_animationDuration)
                
            }
            
            self.updateSliderProgress()
        }
    }
    
    
    var _sliderPageControl:HYPageControlView? = nil
    //计算属性 类似OC get方法
    var sliderPageControl: HYPageControlView {
        get{
            if _sliderPageControl == nil {
                let pageRect = CGRectMake(0, self.bounds.size.height - 3, self.bounds.size.width, 3);
                _sliderPageControl = HYPageControlView(frame:pageRect)
                _sliderPageControl?.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleTopMargin
                
                self.addSubview(_sliderPageControl!)
            }
            
            return _sliderPageControl!
        }
        
        set{
            //TODO
        }
        
    }
    
    
    //MARK: Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.autoresizesSubviews = true
        
        self.scrollView = UIScrollView(frame: self.bounds)
        self.scrollView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        self.scrollView.contentMode = UIViewContentMode.Center
        self.scrollView.contentSize = CGSizeMake(3 * CGRectGetWidth(self.scrollView!.frame), 0)
        self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView!.frame), 0);
        self.scrollView.pagingEnabled = true;
        self.scrollView.scrollsToTop = false;
        self.scrollView.delegate = self
        
        self.addSubview(self.scrollView)
    }
    
    override func layoutSubviews() {
        self.scrollView?.contentSize = CGSizeMake(3 * CGRectGetWidth(self.scrollView!.frame), 0)
        self.configContenViews()
    }
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //MARK: Private
    
    func configContenViews() {
        self.removeSubViewsFromScrollView()
        self.configScrollViewContentDataSource()
        
        var counter: CGFloat = 0
        
        for contentView in self.contentViews! {
            (contentView as UIImageView).userInteractionEnabled = true
            var rightRect: CGRect = self.scrollView.bounds;
            rightRect.origin = CGPointMake(CGRectGetWidth(self.scrollView.frame) * (counter++), 0)
            (contentView as UIImageView).frame = rightRect
            
            self.scrollView.addSubview(contentView as UIImageView)
        }
        
        if _totalPageCount == 1 {
            self.animationEnable = false
            self.scrollView.scrollEnabled = false
            self.scrollView.contentSize = CGSizeZero
            self.scrollView.contentOffset = CGPointZero
        }else {
            self.scrollView.scrollEnabled = true
            self.scrollView.contentOffset = CGPointMake(self.scrollView.bounds.size.width, 0)
        }
        
    }
    
    
    func removeSubViewsFromScrollView() {
        let scrollViewSubviews: NSArray = self.scrollView.subviews
        
        for view in scrollViewSubviews {
            view.removeFromSuperview()
        }
    }
    
    
    func configScrollViewContentDataSource() {
        let previousPageIndex: Int = self.turnToValidNextPageWithPageIndex(self.currentPageIndex - 1)
        let rearPageIndex: Int = self.turnToValidNextPageWithPageIndex(self.currentPageIndex + 1)
        
        if self.contentViews == nil {
            self.contentViews = NSMutableArray()
        }
        
        self.contentViews?.removeAllObjects()
        
        //强类型检查
        if self.pictureViews?.count > 2 {
            self.contentViews?.addObject(self.pictureViewAtPageIndex(previousPageIndex)!)
            self.contentViews?.addObject(self.pictureViewAtPageIndex(self.currentPageIndex)!)
            self.contentViews?.addObject(self.pictureViewAtPageIndex(rearPageIndex)!)
        }else if self.pictureViews?.count == 1 {
            self.contentViews?.addObject(self.pictureViews?.firstObject as UIImageView)
        }else if self.pictureViews?.count == 2 {
            self.contentViews?.addObject(self.pictureViewAtPageIndex(previousPageIndex)!)
            self.contentViews?.addObject(self.pictureViewAtPageIndex(self.currentPageIndex)!)
            
            if rearPageIndex < self.extraImageViews?.count {
                self.contentViews?.addObject(self.extraImageViews?.objectAtIndex(rearPageIndex) as UIImageView)
            }
        }
    }
    
    
    func updateSliderProgress() {
        if  _totalPageCount == 0 {
            return
        }
        
        let scrollViewWidth: CGFloat = self.scrollView.frame.width
        let totalLength: CGFloat = scrollViewWidth * CGFloat(_totalPageCount!)
        var dynamicLength: CGFloat = (CGFloat(self.currentPageIndex - 1) * scrollViewWidth + self.scrollView.contentOffset.x)
        var progress: CGFloat = dynamicLength / totalLength
        
        self.sliderPageControl.slideWithProgress(progress)
    }
    
    
    //统一接口入口, 将从网络取下的内容添加到里面
    func reloadActivityItem(items: NSArray){
        if (items.count == 0) {
            self.scrollView.contentSize = CGSizeMake(0,0);
            self.scrollView.scrollEnabled = false;
            self.items = nil;
        }
        
        if (items == self.items) {
            return;
        }
        
        self.items = items
        self.pictureViews = NSMutableArray(capacity: self.items!.count)
        
        var count: Int = 0
        
        for item in items {
            var imageView: UIImageView = UIImageView(frame: CGRectMake(0,0,self.bounds.size.width,self.scrollView.frame.size.height))
            imageView.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
            imageView.contentMode = UIViewContentMode.ScaleAspectFill
            imageView.clipsToBounds = true
            imageView.image = UIImage(named: "\(count++)")
            
            self.pictureViews?.addObject(imageView)
        }
        
        count = 0
        
        if self.pictureViews!.count == 2 {
            self.extraImageViews = NSMutableArray()
            
            for item in items {
                var imageView: UIImageView = UIImageView(frame: CGRectMake(0,0,self.bounds.size.width,self.scrollView.frame.size.height))
                imageView.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
                imageView.contentMode = UIViewContentMode.ScaleAspectFill
                imageView.image = UIImage(named: "\(count++)")
                imageView.clipsToBounds = true
                
                self.extraImageViews?.addObject(imageView)
            }
        }
        
        self.currentPageIndex = 0;
        self.scrollView.contentOffset = CGPointZero;
        self.totalPageCount = self.pictureViews?.count
    }
    
    
    func turnToValidNextPageWithPageIndex(currentPageIndex: Int) -> Int {
        if(currentPageIndex == -1) {
            return _totalPageCount! - 1;
        } else if (currentPageIndex == _totalPageCount) {
            return 0;
        } else {
            return currentPageIndex;
        }
    }
    
    
    func pictureViewAtPageIndex(index: Int) -> UIImageView? {
        
        if index < 0 || index >= self.pictureViews?.count {
            return nil;
        }
        
        return self.pictureViews?.objectAtIndex(index) as? UIImageView
    }
    
    
    //MARK: UIScrollView Delegate
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.animationTimer!.pauseTimer()
    }
    
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.animationTimer!.resumeTimerAfterTimeInterval(_animationDuration)
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var contentOffsetX: CGFloat = scrollView.contentOffset.x
        var scrollViewWidth: CGFloat = CGRectGetWidth(scrollView.frame)
        
        if(contentOffsetX >= (2 * scrollViewWidth) && _totalPageCount > 1) {
            currentPageIndex = turnToValidNextPageWithPageIndex(currentPageIndex + 1)
            configContenViews()
        }
        if(contentOffsetX <= 0 && _totalPageCount > 1){
            self.currentPageIndex = turnToValidNextPageWithPageIndex(currentPageIndex - 1)
            configContenViews()
        }
        
        updateSliderProgress()
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.scrollView.setContentOffset(CGPointMake(self.scrollView.bounds.width, 0), animated: true)
    }
    
    
    
    //MARK: Action
    
    func animationTimerDidFired(timer: NSTimer) {
        var offsetX: CGFloat = floor(self.scrollView.contentOffset.x / CGRectGetWidth(self.scrollView.frame)) *  CGRectGetWidth(self.scrollView.frame);
        var newOffset: CGPoint = CGPointMake(offsetX + CGRectGetWidth(self.scrollView.frame), self.scrollView.contentOffset.y);
        self.scrollView.setContentOffset(newOffset, animated: true)
    }
}



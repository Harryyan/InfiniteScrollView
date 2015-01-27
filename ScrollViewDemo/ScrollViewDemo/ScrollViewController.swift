//
//  ViewController.swift
//  ScrollViewDemo
//
//  Created by Harry Yan on 15/1/20.
//  Copyright (c) 2015年  Harry Yan. All rights reserved.
//

import UIKit

class ScrollViewController: UIViewController, HYInfiniteScrollViewDelegate, UIScrollViewDelegate{
    
    var scrollView: HYInfiniteScrollView!     //无限滑动scrollview

    //MARK : Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "ScrollView Demo"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.automaticallyAdjustsScrollViewInsets = false
        
        //初始化ScrollView
        let scrollViewRect: CGRect = CGRectMake(0, self.navigationController!.navigationBar.bounds.height, self.view.bounds.width, 200)
        self.scrollView = HYInfiniteScrollView.init(frame: scrollViewRect)
        self.scrollView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        self.scrollView.animationEnable = true
        self.scrollView.animationDuration = 3.0
        self.scrollView.slideBarEnable = true
        self.scrollView.delegate = self
        
        //这里只是做一个简单的循环, 可扩展成从网络上拉数据，自己封装数据结构传值
        let imgArr: NSArray = [1,2,3,4,5]
        self.scrollView.reloadActivityItem(imgArr)
        
        self.view.addSubview(self.scrollView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    //MARK: Private
    
    
    //Mark: HYInfiniteScrollViewDelegate
    
    func didClickPageAtIndex(scrollView: UIScrollView, pageIndex: Int) {
        
    }
    
    func didSwipeToPage(scrollView: UIScrollView, pageIndex: Int) {
        
    }

}


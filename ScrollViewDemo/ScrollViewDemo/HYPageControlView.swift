//
//  HYPageControlView.swift
//  ScrollViewDemo
//
//  Created by Harry Yan on 15/1/20.
//  Copyright (c) 2015年  Harry Yan. All rights reserved.
//

import UIKit

class HYPageControlView: UIView {
    
    var pageIndex: Int = 0
    var progress: CGFloat = 0.0
    
    var currentCursor: UIView?
    var fakeCursor: UIView?
    var tempCursor: UIView?
    var bottomBar: UIView?
    
    var numberOfPages: Int = 0
    var pageCount: Int {
        get{
            return numberOfPages
        }
        
        set{
            if numberOfPages != newValue {
                numberOfPages = newValue
                self.setNeedsLayout()
            }
        }
    }
    
    //MARK: Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(white: 0, alpha: 0.3)
        self.currentCursor = buildCursorView()
        self.fakeCursor = buildCursorView()
        
        self.addSubview(self.currentCursor!)
        self.addSubview(self.fakeCursor!)
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not suppport")
    }
    
    
    override func layoutSubviews() {
        if (1 >= self.numberOfPages) {
            self.currentCursor!.frame = CGRectZero;
            self.fakeCursor!.frame = CGRectZero;
            self.hidden = true;
            return;
        }
        
        self.hidden = false;
        let cursorWidth: CGFloat = self.frame.size.width / CGFloat(self.numberOfPages);
        self.currentCursor!.frame = CGRectMake(CGFloat(self.pageIndex) * cursorWidth, 0,  cursorWidth, self.frame.size.height);
        self.fakeCursor!.frame = CGRectMake(-cursorWidth,  0,  cursorWidth, self.frame.size.height);
    }
    
    //MARK: Public
    
    func slideWithProgress(progress: CGFloat) {
        self.progress = progress
        let originX: CGFloat = self.bounds.size.width * progress;
        var currentFrame: CGRect = self.currentCursor!.frame;
        currentFrame.origin.x = originX;
        self.currentCursor!.frame = currentFrame;
        
        var fakeFrame: CGRect = self.fakeCursor!.frame;
        var fakeOriginX: CGFloat = -fakeFrame.origin.x;
        
        //三种情况
        if (originX + currentFrame.size.width > self.bounds.size.width) { //1.右边超出
            fakeOriginX = -(self.bounds.size.width - originX);
        } else if (originX < 0) { //左边超出
            fakeOriginX = self.bounds.size.width + originX;
        } else { //在中间， fake应该隐藏掉
            fakeOriginX = -self.bounds.size.width;
        }
        
        fakeFrame.origin.x = fakeOriginX;
        self.fakeCursor!.frame = fakeFrame;
        
        //假如fake完全显示了，则与currentCursor交换
        if (fakeOriginX > 0 && fakeOriginX < self.bounds.size.width) {
            let tempView: UIView = self.currentCursor!;
            self.currentCursor = self.fakeCursor;
            self.fakeCursor = tempView;
        }
    }
    
    
    
    //MARK: Private
    
    func buildCursorView() -> UIView {
        var cursorView: UIView = UIView(frame: CGRectMake(-10, 0, 10, self.bounds.size.height))
        
        //TODO 宏定义颜色值
        cursorView.backgroundColor = UIColorFromRGB(0xf26052)
        cursorView.layer.cornerRadius = 1.0
        cursorView.layer.masksToBounds = true
        
        return cursorView
    }
}

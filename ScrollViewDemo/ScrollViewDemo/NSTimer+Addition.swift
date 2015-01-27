//
//  NSTimer+Addition.swift
//  ScrollViewDemo
//
//  Created by Harry Yan on 15/1/24.
//  Copyright (c) 2015年  Harry Yan. All rights reserved.
//

import Foundation

extension NSTimer{
    
    func pauseTimer(){
        if !self.valid {
            return
        }
        
        self.fireDate = NSDate.distantFuture() as NSDate
    }
    
    func resumeTimer(){
        if !self.valid {
            return
        }
        
        self.fireDate = NSDate.distantPast() as NSDate
    }
    
    func resumeTimerAfterTimeInterval(interVal: NSTimeInterval){
        if !self.valid {
            return
        }
        
        self.fireDate = NSDate(timeIntervalSinceNow:interVal)
    }
}

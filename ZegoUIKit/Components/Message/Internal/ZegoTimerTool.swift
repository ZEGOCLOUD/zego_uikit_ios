//
//  ZegoTimerTool.swift
//  ZegoUIKitSDK
//
//  Created by zego on 2022/10/9.
//

import UIKit

class ZegoTimerTool: NSObject {
    private(set) var _timer: Timer!
       fileprivate weak var _aTarget: AnyObject!
       fileprivate var _aSelector: Selector!
       var fireDate: Date {
           get{
               return _timer.fireDate
           }
           set{
               _timer.fireDate = newValue
           }
       }
       
       class func scheduledTimer(timeInterval ti: TimeInterval, target aTarget: AnyObject, selector aSelector: Selector, userInfo: Any?, repeats yesOrNo: Bool) -> ZegoTimerTool {
           let timer = ZegoTimerTool()
           
           timer._aTarget = aTarget
           timer._aSelector = aSelector
           timer._timer = Timer.scheduledTimer(timeInterval: ti, target: timer, selector: #selector(ZegoTimerTool.zj_timerRun), userInfo: userInfo, repeats: yesOrNo)
           return timer
       }
       
       func fire() {
           _timer.fire()
       }
       
       func invalidate() {
           _timer.invalidate()
       }
       
       @objc func zj_timerRun() {
           //如果崩在这里，说明你没有在使用Timer的VC里面的deinit方法里调用invalidate()方法
           _ = _aTarget.perform(_aSelector)
       }
       
       deinit {
           
       }
}

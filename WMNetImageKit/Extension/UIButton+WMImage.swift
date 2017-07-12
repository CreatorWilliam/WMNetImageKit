//
//  UIButton+WMImage.swift
//  WMSDK
//
//  Created by William on 20/12/2016.
//  Copyright © 2016 William. All rights reserved.
//

import Foundation

public extension UIButton {
  
  /// 设置图片
  ///
  /// - Parameters:
  ///   - url: 图片地址
  ///   - placeholder: 站位图
  ///   - loadType: 图片加载方式
  ///   - mode: 图片绘制模式,默认为none
  ///   - state: 显示图片的状态
  ///   - ignore: 是否忽略设置历史
  ///   - handle: 设置图片后的操作
  public func wm_setBackgroundImage(url: URL,
                                    placeholder: String? = nil,
                                    loadType: LoadType = .none,
                                    mode: UIImage.WMDrawMode = .default,
                                    ignore: Bool = false,
                                    for state: UIControlState,
                                    handle: (() -> Void)? = nil) {
    
    wm_showImage(url: url,
                 placeholder: placeholder,
                 loadType: loadType,
                 mode: mode,
                 ignore: ignore) { (image) in
                  
                  self.setBackgroundImage(image, for: state)
                  handle?()
    }
    
  }
  
  /// 设置图片
  ///
  /// - Parameters:
  ///   - url: 图片地址
  ///   - placeholder: 站位图
  ///   - loadType: 图片加载方式
  ///   - mode: 图片绘制模式,默认为default
  ///   - state: 显示图片的状态
  ///   - handle: 设置图片后的操作
  public func wm_setImage(url: URL,
                          placeholder: String? = nil,
                          loadType: LoadType = .realTime,
                          mode: UIImage.WMDrawMode = .default,
                          for state: UIControlState,
                          handle: (() -> Void)? = nil) {
    
    wm_showImage(url: url,
                 placeholder: placeholder,
                 loadType: loadType,
                 mode: mode) { (image) in
                  
                  self.setImage(image, for: state)
                  handle?()
    }
    
  }
}

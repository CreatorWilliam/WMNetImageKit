
//
//  UIImageView+WMImage.swift
//  WMSDK
//
//  Created by William on 20/12/2016.
//  Copyright © 2016 William. All rights reserved.
//

import Foundation

public extension UIImageView {
  
  /// 设置网络图片
  ///
  /// - Parameters:
  ///   - url: 图片地址
  ///   - placeholder: 占位图
  ///   - loadType: 图片加载方式
  ///   - mode: 图片绘制模式,默认为default
  ///   - ignore: 是否忽略设置历史
  ///   - handle: 设置图片后的操作
  public func wm_setImage(url: Any?,
                          placeholder: String? = nil,
                          loadType: LoadType = .none,
                          mode: UIImage.WMDrawMode = .default,
                          ignore: Bool = false,
                          handle: (() -> Void)? = nil) {
    
    wm_showImage(url, placeholder: placeholder, loadType: loadType, mode: mode, ignore: ignore) { (image) in
      
      self.image = image
      handle?()
    }
        
  }
  
  
  /// 设置本地图片
  ///
  /// - Parameters:
  ///   - nameed: 图片名
  ///   - mode: 图片绘制模式,默认为default
  public func wm_setImage(_ name: String, mode: UIImage.WMDrawMode = .default) {
    
    switch mode {
    case .fill:
      
      self.contentMode = .scaleAspectFill
      self.clipsToBounds = true
      
    case .fit:
      
      self.contentMode = .scaleAspectFit
      
    default:
      
      self.contentMode = .scaleToFill
      
    }
    
    if let path = Bundle.main.path(forResource: name, ofType: nil) {
      
      self.image = UIImage(contentsOfFile: path)?.wm_draw(self.bounds.size, mode: mode)
    }
  }

}



















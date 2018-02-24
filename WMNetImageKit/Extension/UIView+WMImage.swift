//
//  UIView+WMImage.swift
//  WMSDK
//
//  Created by William on 23/12/2016.
//  Copyright © 2016 William. All rights reserved.
//

import Foundation


private var downloadingImageKey: Void?
private var indicatorKey: Void?
private var progressKey: Void?

// MARK: - UIView相关加载视图
extension UIView {
  
  /// 图片加载方式
  ///
  /// - none: 无任何效果
  /// - indicator: 指示器
  /// - progress: 进度条
  /// - realTime: 实时显示图片,将占用较高的内存
  public enum LoadType {
    
    case none
    case indicator
    case progress
    case realTime
  }
  
  var downloadingImageURL: URL? {
    
    set {
      
      objc_setAssociatedObject(self,
                               &downloadingImageKey,
                               newValue,
                               .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    get {
      
      return objc_getAssociatedObject(self, &downloadingImageKey) as? URL
    }
    
  }
  
  /// 活动指示器
  var indicatorView: UIActivityIndicatorView {
    
    var view: UIActivityIndicatorView
    if let temp = objc_getAssociatedObject(self, &indicatorKey) {
      
      view = temp as! UIActivityIndicatorView
      view.isHidden = true
      
      return view
    }
    
    view = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    objc_setAssociatedObject(self, &indicatorKey, view, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    self.addSubview(view)
    
    view.center = self.center
    
    return view
  }
  
  /// 进度指示器
  var progressView: UIProgressView {
    
    var view: UIProgressView
    if let temp = objc_getAssociatedObject(self, &progressKey) {
      
      view = temp as! UIProgressView
      view.isHidden = true
      
      return view
    }
    
    //只会创建一次
    view = UIProgressView(progressViewStyle: .bar)
    objc_setAssociatedObject(self, &progressKey, view, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    self.addSubview(view)
    view.center = self.center
    
    return view
  }
  
  /// 设置图片
  ///
  /// - Parameters:
  ///   - originURL: 图片地址
  ///   - placeholder: 站位图
  ///   - loadType: 图片加载方式
  ///   - mode: 图片绘制模式
  ///   - ignore: 是否忽略设置历史。说明：视图与地址绑定后，之后若因其他原因设置视图图片为nil，会导致下次设置同样的地址时，无法显示图片，设置为true可以忽略此问题，默认为false是解决视图频繁设置图片导致的图片闪动
  ///   - handle: 如何设置图片
  internal func wm_showImage(_ originURL: Any?,
                   placeholder: String?,
                   loadType: LoadType,
                   mode: UIImage.WMDrawMode,
                   ignore: Bool = false,
                   handle: @escaping ((UIImage?) -> Void)) {
    
    guard let urlString = originURL as? String else {
      
      guard let placeholder = placeholder else { return }
      handle(UIImage(named: placeholder)?.wm_draw())
      return
    }
    guard let url = URL(string: urlString) else {
      
      guard let placeholder = placeholder else { return }
      handle(UIImage(named: placeholder)?.wm_draw())
      return
    }
    
    //过滤多次相同地址赋值
    if self.downloadingImageURL == url && !ignore { return }
    
    //若设置了占位图，则显示站位图
    if let placeholder = placeholder, let placeholderImage = UIImage(named: placeholder)?.wm_draw() {
      
      handle(placeholderImage)
      
    } else {
      
      handle(nil)
    }
    
    //将视图与对应URL绑定，确保重用过程中，图片刷新不错乱
    if let oldURL = self.downloadingImageURL {
      
      //处理旧地址对应的图片
      WMImageManager.hideImage(url: oldURL, target: self)
    }
    self.downloadingImageURL = url
    
    //设置进度监听
    let progress: WMImageManager.ProgressingAction = { [weak self] (received, total, partialImage) in
      
      //确保重用过程中，图片局部刷新不错乱
      if self?.downloadingImageURL != url {
        
        return
      }
      
      switch loadType {
        
      case .indicator:
        
        self?.indicatorView.isHidden = false
        self?.indicatorView.startAnimating()
        self?.progressView.isHidden = true
        
      case .progress:
        
        self?.indicatorView.isHidden = true
        self?.indicatorView.stopAnimating()
        self?.progressView.isHidden = false
        self?.progressView.progress = Float(received)/Float(total)
        
      case .realTime:
        
        self?.indicatorView.isHidden = true
        self?.indicatorView.stopAnimating()
        self?.progressView.isHidden = true
        handle(partialImage)
        
      default:
        
        self?.indicatorView.isHidden = true
        self?.indicatorView.stopAnimating()
        self?.progressView.isHidden = true

      }
      
    }
    
    //设置完成监听
    let complete: WMImageManager.CompleteAction = { [weak self] (image) in
      
      //确保重用过程中，图片完整刷新不错乱
      if self?.downloadingImageURL != url {
        
        return
      }
      
      switch loadType {
        
      case .indicator:
        
        self?.indicatorView.stopAnimating()
        self?.indicatorView.isHidden = true
        
      case .progress:
        
        self?.progressView.progress = 0
        self?.progressView.isHidden = true
        
      default:
        
        self?.indicatorView.isHidden = true
        self?.progressView.isHidden = true
        break
      }
      
      handle(image)
      
    }
    
//    switch mode {
//    case .fill:
//      
//      self.contentMode = .scaleAspectFill
//      self.clipsToBounds = true
//      
//    case .fit:
//      
//      self.contentMode = .scaleAspectFit
//      
//    default:
//      
//      self.contentMode = .scaleToFill
//      
//    }
    
    //设置图片
    WMImageManager.showImage(from: url,
                             for: self,
                             mode: mode,
                             progress: progress,
                             complete: complete)
    
  }
  
}

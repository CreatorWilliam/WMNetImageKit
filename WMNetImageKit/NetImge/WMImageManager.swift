//
//  WMImageManager.swift
//  WMSDK
//
//  Created by William on 20/12/2016.
//  Copyright © 2016 William. All rights reserved.
//

import UIKit

public class WMImageManager: NSObject {
  
  public typealias ProgressingAction = (_ received : Int64 ,_ total : Int64, _ partialImage: UIImage) -> Void
  public typealias CompleteAction = (_ image: UIImage) -> Void
  
  fileprivate static let `default` = WMImageManager()
  fileprivate let imageQueue : OperationQueue = OperationQueue()
  
  override init() {
    super.init()
    
    self.imageQueue.maxConcurrentOperationCount = 3
  }
  
  /// 显示图片
  ///
  /// - Parameters:
  ///   - url: 图片地址
  ///   - target: 设置图片的视图
  ///   - progress: 监听进度
  ///   - complete: 监听完成
  public class func showImage(from url: URL,
                              for target: UIView,
                              mode: UIImage.WMDrawMode = .default,
                              progress: ProgressingAction?,
                              complete: @escaping CompleteAction) {
    
    let size = target.bounds.size
    
      //从内存获取
      let drawedImage: UIImage? = WMImageStore.fromMemory(with: url)
      
      if let drawedImage = drawedImage,
        Int(drawedImage.size.width) >= Int(size.width),
        Int(drawedImage.size.height) >= Int(size.height) {
        
        DispatchQueue.main.async {
          
          complete(drawedImage)
        }
        return
      }
      
      //从磁盘获取
      if let drawedImage = WMImageStore.fromDisk(with: url)?.wm_draw(size, mode: mode) {
        
        WMImageStore.toMemory(for: drawedImage, with: url)
        
        DispatchQueue.main.async {
          
          complete(drawedImage)
        }
        return
      }
      
      //从网络获取
      WMImageDownloader.fromInternet(url, progress: { (recieved, total, partialData) in
        
        guard let imageData = partialData, let drawedImage = UIImage(data: imageData)?.wm_draw(size, mode: mode) else { return }
        DispatchQueue.main.async {
          
          progress?(recieved, total, drawedImage)
        }
        
      }, complete: { (imageData) in
        
        guard let image = UIImage(data: imageData) else { return }
        WMImageStore.toDisk(for: imageData, with: url)
        guard let drawedImage = image.wm_draw(size, mode: mode) else { return }
        WMImageStore.toMemory(for: drawedImage, with: url)
        
        DispatchQueue.main.async {
          
          complete(drawedImage)
        }
      })
    
  }
  
  /// 隐藏图片，同时也会停止相应的图片下载任务
  ///
  /// - Parameters:
  ///   - url: 图片地址
  ///   - target: 隐藏图片的视图
  public class func hideImage(url: URL, target: UIView) {
    
    DispatchQueue.global().async {
      
      WMImageDownloader.pause(url)
      
    }
  }
  
  /// 获取磁盘缓存的图片总大小
  ///
  /// - Returns: 缓存的图片大小，单位B
  public class func sizeOfDiskCache() -> Int64 {
        
    return WMImageStore.chacheSize()
  }
  
  /// 清除磁盘缓存
  public class func clearDiskCache() {
    
    WMImageStore.clearDiskCache()
  }
  
  
  /// 将通过ImagePicker获得的图片储存到本地
  ///
  /// - Parameters:
  ///   - image: 图片
  ///   - name: 图片名
  /// - Returns: 缓存图片所在地址
  public class func storeImageFromImagePicker(_ image: UIImage, with name: String) -> URL? {
    
    let path = WMImageStore.imagePath(with: name)
    let url = URL(fileURLWithPath: path)
    
    guard let imageData = UIImageJPEGRepresentation(image, 1) else { return nil }
    
    WMImageStore.toDisk(for: imageData, with: url, isReplace: true)
    
    return url
  }
  
  public class func storeImageFromInternet(_ url: URL, complete: @escaping CompleteAction) {
    
    DispatchQueue.global().async {
      
      //从磁盘获取
      if let image = WMImageStore.fromDisk(with: url) {
        
        complete(image)
        return
      }
      
      //从网络获取
      WMImageDownloader.fromInternet(url, progress: { (recieved, total, partialData) in
        

      }, complete: { (imageData) in
        
        guard let image = UIImage(data: imageData) else { return }
        
        WMImageStore.toDisk(for: imageData, with: url)
        
          complete(image)
        })
      
      
    }

  }
}


public extension UIImage {
  
  /// 裁剪模式不会造成图片比例失真，配合wm_draw函数使用
  ///
  /// - default: 按原图宽高比进行缩放，图片宽度等于给定（默认）宽度，图片高度可能不等于（大于或小于）给定（默认）高度
  /// - fill: 按原图宽高比进行缩放，填充给定（默认）大小，保证图片宽度等于给定（默认）的宽度，图片高度不小于给定（默认）的高度，或者图片高度等于给定（默认）的高度，图片宽度不小于给定（默认）的宽度
  /// - fit: 按原图宽高比进行缩放，适应给定（默认）大小，保证图片宽度等于给定（默认）的宽度，图片高度不大于给定（默认）的高度，或者图片高度等于给定（默认）的高度，图片宽度不大于给定（默认）的宽度
  enum WMDrawMode {
    
    case `default`
    case fill
    case fit
    
  }
  
  
  func wm_draw(_ size: CGSize = UIScreen.main.bounds.size,
              mode: WMDrawMode = .default) -> UIImage? {
    
    var drawedSize = size
    let imageSize = self.size

    if drawedSize.equalTo(CGSize.zero) {
      
      drawedSize = UIScreen.main.bounds.size
    }
    var scale: CGFloat
    
    switch mode {
      
    case .fill:
      
      let imageScale = imageSize.width / imageSize.height
      let drawedScale = drawedSize.width / drawedSize.height
      
      scale = imageScale > drawedScale
        ? drawedSize.height / imageSize.height
        : drawedSize.width / imageSize.width
      
    case .fit:
      
      let imageScale = imageSize.width / imageSize.height
      let tailoredScale = drawedSize.width / drawedSize.height
      
      scale = imageScale > tailoredScale
        ? drawedSize.width / imageSize.width
        : drawedSize.height / imageSize.height
      
    default:
      
      scale = drawedSize.width / imageSize.width
      break
      
    }
    drawedSize = CGSize(width: Int(imageSize.width * scale),
                          height: Int(imageSize.height * scale))
    
    let tailoredRect = CGRect(origin: CGPoint.zero,
                              size: drawedSize)
    
    UIGraphicsBeginImageContextWithOptions(drawedSize, true, 0)
    self.draw(in: tailoredRect)
    let tailoredImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return tailoredImage
  }
  
}













































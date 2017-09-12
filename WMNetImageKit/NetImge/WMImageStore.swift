//
//  WMImageStore.swift
//  WMSDK
//
//  Created by William on 22/12/2016.
//  Copyright © 2016 William. All rights reserved.
//

import Foundation

internal class WMImageStore {
  
  //let imageCache = NSCache<NSURL, UIImage>()
  var imageCache: [URL : UIImage] = [:]
  fileprivate static let `default` = WMImageStore()
  
  init() {
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(clearMemoryCache),
                                           name: .UIApplicationDidReceiveMemoryWarning,
                                           object: nil)
  }
}

// MARK: - WriteImage
internal extension WMImageStore {
  
  /// 缓存图片到内存
  ///
  /// - Parameters:
  ///   - image: 缓存的图片
  ///   - imageURL: 图片地址
  class func toMemory(for image: UIImage, with imageURL: URL) {
    
    WMImageStore.default.imageCache[imageURL] = image
    
  }
  
  
  /// 缓存图片到磁盘
  ///
  /// - Parameters:
  ///   - imageData: 缓存的图片
  ///   - imageURL: 图片地址
  class func toDisk(for imageData: Data, with imageURL: URL, isReplace: Bool = false) {
    
    let name = imageName(with: imageURL)
    
    let path = imagePath(with: name)
    
    if FileManager.default.fileExists(atPath: path) {
      
      if isReplace {
        
        do {
          
          try FileManager.default.removeItem(atPath: path)
          
        } catch {
          
          return
        }
        
      } else {
        
        return
      }
    }
    
    do {
      
      try imageData.write(to: URL(fileURLWithPath: path))
      
    } catch {
      
      // TODO:图片写入磁盘异常处理(TODO)
      return
    }
    
  }
  
}

// MARK: - ReadImage
internal extension WMImageStore {
  
  /// 从内存中获取图片
  ///
  /// - Parameter imageURL: 图片ID
  /// - Returns: 读取的图片
  class func fromMemory(with imageURL: URL) -> UIImage? {
    
    
    return WMImageStore.default.imageCache[imageURL]
  }
  
  
  /// 从磁盘中获取来自网络的图片
  ///
  /// - Parameter imageURL: 图片ID
  /// - Returns: 读取的图片
  class func fromDisk(with imageURL: URL) -> UIImage? {
    
    let name = imageName(with: imageURL)
    
    let path = imagePath(with: name)
    
    guard let imageData = try? Data(contentsOf: URL(fileURLWithPath: path, isDirectory: false)) else {
      
      return nil
    }
    return UIImage(data: imageData)
  }
  
}


// MARK: - RemoveImage
internal extension WMImageStore {
  
  /// 清除内存缓存的图片
  @objc func clearMemoryCache() -> Void {
    
    self.imageCache.removeAll()
  }
  
  
  /// 清除磁盘缓存的图片
  class func clearDiskCache() -> Void {
    
    let path = cacheDirectoryPath()
    
    guard let subpaths = FileManager.default.subpaths(atPath: path) else { return }
    
    for subpath in subpaths {
      
      let imagePath = path.appendingFormat("/%@", subpath)
      do {
        
        try FileManager.default.removeItem(atPath: imagePath)
        
      } catch {
        
        // TODO:移除文件异常处理（TODO）
        
      }
    }
    
  }
  
  
  /// 磁盘缓存的图片总大小
  ///
  /// - Returns: 缓存的图片大小，单位B
  class func chacheSize() -> Int64 {
    
    let path = WMImageStore.cacheDirectoryPath()
    var size: Int64 = 0
    let fileManager = FileManager.default
    
    guard let subpaths = FileManager.default.subpaths(atPath: path) else { return 0 }
    
    //遍历缓存文件夹下所有文件的大小
    for subpath in subpaths {
      
      let imagePath = path.appendingFormat("/%@", subpath)
      
      do {
        
        let fileAttributes =  try fileManager.attributesOfItem(atPath: imagePath)
        
        let imageSize: Int64 = fileAttributes[FileAttributeKey.size] as? Int64 ?? 0

        size += imageSize
        
      } catch {
        
      }
      
      
    }
    
    return size
  }
  
  
  
}


internal extension WMImageStore {
  
  /// 根据图片地址生成图片名
  ///
  /// - Parameter imageSourceURL: 图片地址
  /// - Returns: 图片名
  fileprivate class func imageName(with imageSourceURL: URL) -> String {
    
    return imageSourceURL.absoluteString.wm_md5
  }
  
  /// 根据图片名称获取图片缓存地址
  ///
  /// - Parameter name: 图片名
  /// - Returns: 图片所在路径
  class func imagePath(with name: String) -> String {
    
    return WMImageStore.cacheDirectoryPath().appendingFormat("/%@", name)
  }
  
  /// 图片缓存文件夹路径
  ///
  /// - Returns: 文件夹地址
  class func cacheDirectoryPath() -> String {
    
    let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!
    let imageDiskCacheDirectoryPath = libraryPath.appending("/ImageCache")
    
    if FileManager.default.fileExists(atPath: imageDiskCacheDirectoryPath) { return imageDiskCacheDirectoryPath }
    
    do {
      
      try FileManager.default.createDirectory(atPath: imageDiskCacheDirectoryPath,
                                              withIntermediateDirectories: true,
                                              attributes: [URLResourceKey.isExcludedFromBackupKey.rawValue : true])
      
    } catch  {
      
      //fatalError("Create image cache directory is failed")
    }
    
    return imageDiskCacheDirectoryPath
  }
  
  
}


















//
//  WMImageDownloader.swift
//  WMSDK
//
//  Created by William on 22/12/2016.
//  Copyright © 2016 William. All rights reserved.
//

import Foundation

extension Notification.Name {
 
  /// 下载进度通知，UserInfo为：["ImageURL" : URL]
  static let WMImageDownloadProgressNotification: Notification.Name = Notification.Name("WMImageDownloadProgressNotification")
  
  /// 下载完成通知（暂未提供）
  static let WMImageDowmloadCompleteNotification: Notification.Name = Notification.Name("WMImageDowmloadCompleteNotification")
  
}

internal class WMImageDownloader: NSObject {
  
  typealias ProgressingAction = (_ received : Int64 ,_ total : Int64, _ partialData: Data?) -> Void
  typealias CompleteAction = (_ data: Data) -> Void
  
  static let `default` = WMImageDownloader()
  
  private var session: URLSession?
  
  private lazy var sessionQueue: OperationQueue = OperationQueue()
  
  private var tasks = [URL : URLSessionTask]()
  private var datas = [URL : NSMutableData]()
  private var progressingActions = [URL : [ProgressingAction]]()
  private var completeActions = [URL : [CompleteAction]]()
  
  override init() {
    super.init()
    
    self.sessionQueue.maxConcurrentOperationCount = 3
    let configuration = URLSessionConfiguration.default
    configuration.httpMaximumConnectionsPerHost = 3
    self.session = URLSession(configuration: configuration, delegate: self, delegateQueue: self.sessionQueue)
    //
    
  }
  
  deinit {
    
    self.session?.invalidateAndCancel()
  }
  
}

internal extension WMImageDownloader {
  
  /// 从网络获取图片
  ///
  /// - Parameter imageURL: 图片的网络地址
  class func fromInternet(_ imageURL: URL, progress: ProgressingAction?, complete: @escaping CompleteAction) {
    
    let downloader = WMImageDownloader.default
    
    if let progress = progress {
      
      if downloader.progressingActions[imageURL] == nil {
        
        downloader.progressingActions[imageURL] = []
      }
      downloader.progressingActions[imageURL]?.append(progress)
    }
    if downloader.completeActions[imageURL] == nil {
      
      downloader.completeActions[imageURL] = []
    }
    downloader.completeActions[imageURL]?.append(complete)
    
    let task = downloader.session?.dataTask(with: imageURL)
    task?.resume()
    
    downloader.tasks[imageURL] = task
    downloader.datas[imageURL] = NSMutableData()
    
  }
  
  class func pause(_ imageURL: URL) {
    
    let downloader = WMImageDownloader.default
    
    //将要对应任务取消，同时去除相关的回调及任务和数据
    downloader.tasks[imageURL]?.cancel()
    downloader.tasks.removeValue(forKey: imageURL)
    downloader.datas.removeValue(forKey: imageURL)
    downloader.progressingActions.removeValue(forKey: imageURL)
    downloader.completeActions.removeValue(forKey: imageURL)
    
  }
  
}

// MARK: - For ImageDataTask URLSessionDataDelegate
extension WMImageDownloader: URLSessionDataDelegate {
  
  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    
    /// 获取图片标识URL
    guard let imageURL = dataTask.originalRequest?.url else { return }
    
    /// 获取对应的图片数据
    guard let imageData = self.datas[imageURL] else { return }
    var isPostNotification: Bool = false
    if imageData.length == 0 {
      
      isPostNotification = true
    }
    imageData.append(data)
    let recieved: Int64 = Int64(imageData.length)
    var total: Int64 = 0
    if let expectedContentLength = dataTask.response?.expectedContentLength {
      
      total = expectedContentLength
    }
   
    guard let progressingActions = self.progressingActions[imageURL] else { return }
    for action in progressingActions {
      
      action(recieved, total, imageData as Data)
    }
    
    if isPostNotification {
      
      NotificationCenter.default.post(name: .WMImageDownloadProgressNotification, object: nil, userInfo: ["ImageURL" : imageURL])
    }
  }
  
}


// MARK: - For ImageDataTask And ImageDownloadTask URLSessionDelegate
extension WMImageDownloader: URLSessionTaskDelegate {
  
  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    
    guard let imageURL = task.originalRequest?.url else { return }
    
    defer {
      
      self.tasks.removeValue(forKey: imageURL)
      self.datas.removeValue(forKey: imageURL)
      self.progressingActions.removeValue(forKey: imageURL)
      self.completeActions.removeValue(forKey: imageURL)
    }
    
    guard let imageData = self.datas[imageURL] else { return }
    
    if let _ = error { return }
    if let actions = self.completeActions[imageURL] {
      
      for action in actions {
        
        action(imageData as Data)
      }
      
    }
    
  }
  
}




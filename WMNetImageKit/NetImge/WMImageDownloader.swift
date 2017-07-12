//
//  WMImageDownloader.swift
//  WMSDK
//
//  Created by William on 22/12/2016.
//  Copyright © 2016 William. All rights reserved.
//

import Foundation

extension Notification.Name {
 
  static let WMImageDownloadProgressNotification: Notification.Name = Notification.Name("WMImageDownloadProgressNotification")
  static let WMImageDowmloadCompleteNotification: Notification.Name = Notification.Name("WMImageDowmloadCompleteNotification")
}

internal class WMImageDownloader : NSObject {
  
  typealias ProgressingAction = (_ received : Int64 ,_ total : Int64, _ partialData: Data?) -> Void
  typealias CompleteAction = (_ data: Data) -> Void
  
  static let `default` = WMImageDownloader()
  
  fileprivate lazy var session: URLSession = {
    
    let configuration = URLSessionConfiguration.ephemeral
    configuration.httpMaximumConnectionsPerHost = 4
    
    return URLSession(configuration: configuration,
                      delegate: self,
                      delegateQueue: self.sessionQueue)
    
  }()
  
  fileprivate lazy var sessionQueue: OperationQueue = OperationQueue()
  
  fileprivate var tasks = [URL : URLSessionTask]()
  fileprivate var datas = [URL : NSMutableData]()
  fileprivate var progressingActions = [URL : [ProgressingAction]]()
  fileprivate var completeActions = [URL : [CompleteAction]]()
  
  override init() {
    super.init()
    
    //
    sessionQueue.maxConcurrentOperationCount = 1
   
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
    
    var task = downloader.tasks[imageURL]
    if let task = task {
      
      switch task.state {
        
      case .suspended:
        
        task.resume()
        return
        
      case .running:
        
        return
        
      default: break
        
      }
      
    } else {
      
      task = downloader.session.dataTask(with: imageURL)
    }
    task?.resume()
    
    downloader.tasks[imageURL] = task
    downloader.datas[imageURL] = NSMutableData()
    
  }
  
  class func pause(_ imageURL: URL) {
    
    let downloader = WMImageDownloader.default
    guard let task = downloader.tasks[imageURL] else {
      
      return
    }
    
    switch task.state {
    case .running:
      
      task.suspend()
      
    default:
      return
    }
  }
}

// MARK: - For ImageDataTask URLSessionDataDelegate
extension WMImageDownloader : URLSessionDataDelegate {
  
  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    
    guard let imageURL = dataTask.originalRequest?.url else {
      
      return
    }
    
    guard let imageData = self.datas[imageURL] else {
      
      return
    }
    
    var isPostNotification : Bool = false
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
extension WMImageDownloader : URLSessionDelegate {
  
  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    
    guard let imageURL = task.originalRequest?.url else {
      
      return
    }
    
    guard let imageData = self.datas[imageURL] else {
      
      return
    }
    
    if let _ = error { return }
    if let actions = self.completeActions[imageURL] {
      
      for action in actions {
        
        action(imageData as Data)
      }
    }
    
    self.tasks.removeValue(forKey: imageURL)
    self.datas.removeValue(forKey: imageURL)
    self.progressingActions.removeValue(forKey: imageURL)
    self.completeActions.removeValue(forKey: imageURL)
    
  }
  
}




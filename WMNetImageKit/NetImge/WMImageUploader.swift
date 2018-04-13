//
//  WMImageUploader.swift
//  WMSDK
//
//  Created by William on 15/02/2017.
//  Copyright © 2017 William. All rights reserved.
//

import Foundation

class WMImageUploader : NSObject {
  
  typealias ProgressingAction = (_ send : Int64 ,_ total : Int64) -> Void
  typealias CompleteAction = () -> Void
  
  static let `default` = WMImageDownloader()
  
  private lazy var session: URLSession = {
    
    let configuration = URLSessionConfiguration.ephemeral
    configuration.httpMaximumConnectionsPerHost = 4
    
    return URLSession(configuration: configuration,
                      delegate: self,
                      delegateQueue: self.sessionQueue)
    
  }()
  
  private lazy var sessionQueue: OperationQueue = OperationQueue()
  
  private var tasks = [URL : URLSessionTask]()
  private var datas = [URL : NSMutableData]()
  private var progressingActions = [URL : [ProgressingAction]]()
  private var completeActions = [URL : [CompleteAction]]()
  
  override init() {
    super.init()
    
    //
    sessionQueue.maxConcurrentOperationCount = 1
    
  }

}

extension WMImageUploader {
  
  class func toInternet(_ imageBase64: String, progress: ProgressingAction?, complete: @escaping CompleteAction) {
    
//    let uploader = WMImageUploader.default
//    
//    if let progress = progress {
//      
//      if uploader.progressingActions[imageURL] == nil {
//        
//        uploader.progressingActions[imageURL] = []
//      }
//      uploader.progressingActions[imageURL]?.append(progress)
//    }
//    if uploader.completeActions[imageURL] == nil {
//      
//      uploader.completeActions[imageURL] = []
//    }
//    uploader.completeActions[imageURL]?.append(complete)
//    
//    var task = uploader.tasks[imageURL]
//    if let task = task {
//      
//      switch task.state {
//        
//      case .suspended:
//        
//        task.resume()
//        return
//        
//      case .running:
//        
//        return
//        
//      default: break
//        
//      }
//      
//    } else {
//      
//      task = uploader.session.dataTask(with: imageURL)
//    }
//    task?.resume()
//    
//    uploader.tasks[imageURL] = task
    
  }
}

extension WMImageUploader : URLSessionDataDelegate {
  
  func urlSession(_ session: URLSession,
                  task: URLSessionTask,
                  didSendBodyData bytesSent: Int64,
                  totalBytesSent: Int64,
                  totalBytesExpectedToSend: Int64) {
    
  }
}

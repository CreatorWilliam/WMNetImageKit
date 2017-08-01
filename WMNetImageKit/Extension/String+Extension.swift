//
//  String+Extension.swift
//  WMNetImageKit
//
//  Created by Willima Lee on 12/07/2017.
//  Copyright © 2017 William Lee. All rights reserved.
//

import Foundation

#if os(OSX)
  import WMCommonCryptoMacOS
#elseif os(iOS)
#if (arch(i386) || arch(x86_64))
  import WMCommonCryptoiPhoneSimulator
  #else
  import WMCommonCryptoiPhoneOS
#endif
#elseif os(watchOS)
#if (arch(i386) || arch(x86_64))
  import WMCommonCryptoWatchSimulator
  #else
  import WMCommonCryptoWatchOS
#endif
#endif



//enum CryptoAlgorithm {
//  case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
//
//  var HMACAlgorithm: CCHmacAlgorithm {
//    var result: Int = 0
//    switch self {
//    case .MD5:      result = kCCHmacAlgMD5
//    case .SHA1:     result = kCCHmacAlgSHA1
//    case .SHA224:   result = kCCHmacAlgSHA224
//    case .SHA256:   result = kCCHmacAlgSHA256
//    case .SHA384:   result = kCCHmacAlgSHA384
//    case .SHA512:   result = kCCHmacAlgSHA512
//    }
//    return CCHmacAlgorithm(result)
//  }
//
//  var digestLength: Int {
//    var result: Int32 = 0
//    switch self {
//    case .MD5:      result = CC_MD5_DIGEST_LENGTH
//    case .SHA1:     result = CC_SHA1_DIGEST_LENGTH
//    case .SHA224:   result = CC_SHA224_DIGEST_LENGTH
//    case .SHA256:   result = CC_SHA256_DIGEST_LENGTH
//    case .SHA384:   result = CC_SHA384_DIGEST_LENGTH
//    case .SHA512:   result = CC_SHA512_DIGEST_LENGTH
//    }
//    return Int(result)
//  }
//}

public extension String  {
  
  var wm_md5: String {
    
    let str = self.cString(using: String.Encoding.utf8)
    let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
    let digestLen = Int(CC_MD5_DIGEST_LENGTH)
    let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
    CC_MD5(str!, strLen, result)
    return stringFromBytes(bytes: result, length: digestLen)
  }
  
  var wm_sha1: String! {
    
    let str = self.cString(using: String.Encoding.utf8)
    let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
    let digestLen = Int(CC_SHA1_DIGEST_LENGTH)
    let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
    CC_SHA1(str!, strLen, result)
    return stringFromBytes(bytes: result, length: digestLen)
  }
  
  var wm_sha256: String! {
    
    let str = self.cString(using: String.Encoding.utf8)
    let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
    let digestLen = Int(CC_SHA256_DIGEST_LENGTH)
    let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
    CC_SHA256(str!, strLen, result)
    return stringFromBytes(bytes: result, length: digestLen)
  }
  
  var wm_sha512: String! {
    
    let str = self.cString(using: String.Encoding.utf8)
    let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
    let digestLen = Int(CC_SHA512_DIGEST_LENGTH)
    let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
    CC_SHA512(str!, strLen, result)
    return stringFromBytes(bytes: result, length: digestLen)
  }
  
  private func stringFromBytes(bytes: UnsafeMutablePointer<CUnsignedChar>, length: Int) -> String {
    
    let hash = NSMutableString()
    for i in 0..<length {
      hash.appendFormat("%02x", bytes[i])
    }
    bytes.deallocate(capacity: length)
    return String(format: hash as String)
  }
  
  //  func hmac(algorithm: CryptoAlgorithm, key: String) -> String {
  //
  //    let str = self.cString(using: String.Encoding.utf8)
  //    let strLen = Int(self.lengthOfBytes(using: String.Encoding.utf8))
  //    let digestLen = algorithm.digestLength
  //    let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
  //    let keyStr = key.cString(using: String.Encoding.utf8)
  //    let keyLen = Int(key.lengthOfBytes(using: String.Encoding.utf8))
  //
  //    CCHmac(algorithm.HMACAlgorithm, keyStr!, keyLen, str!, strLen, result)
  //
  //    let digest = stringFromResult(result: result, length: digestLen)
  //
  //    result.deallocate(capacity: digestLen)
  //
  //    return digest
  //  }
  
  private func stringFromResult(result: UnsafeMutablePointer<CUnsignedChar>, length: Int) -> String {
    
    let hash = NSMutableString()
    for i in 0..<length {
      hash.appendFormat("%02x", result[i])
    }
    return String(hash)
  }
}
  
 



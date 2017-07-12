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


// MARK: - Regular
public extension String {
  
  enum RegularKind : String {
    
    case email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
    case mobil = "^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$"
    case account = "^[A-Za-z0-9]{4,20}+$"
    case password = "^[a-zA-Z0-9]{6,20}+$"
    case identityCard = "^(\\d{14}|\\d{17})(\\d|[xX])$"
    case bankCard = "^(\\d{15,30})"
    case bankLast4Byte = "^(\\d{4})"
    
    case month = "(^(0)([0-9])$)|(^(1)([0-2])$)"
    case year = "^([1-3])([0-9])$"
    
    //case nickName = "([\u4e00-\u9fa5]{2,5})(&middot;[\u4e00-\u9fa5]{2,5})*
    //case carNo = "^[\u4e00-\u9fa5]{1}[a-zA-Z]{1}[a-zA-Z_0-9]{4}[a-zA-Z_0-9_\u4e00-\u9fa5]$"
    //case carType = "^[\u4E00-\u9FFF]+$"
    
  }
  
  func wm_regual(_ kind: RegularKind) -> Bool {
    
    let predicate = NSPredicate(format: "SELF MATCHES %@", kind.rawValue)
    
    return predicate.evaluate(with: self)
  }
  
  func wm_isEmpty() -> Bool {
    
    if self.characters.count == 0 { return true }
    
    return false
  }
  
  //验证内容是否只包含空格，换行符，制表符
  var wm_isValidateText: Bool {
    
    do {
      
      let regularExpression = try NSRegularExpression(pattern: "[^ \r\t\n]",
                                                      options: .caseInsensitive)
      let result = regularExpression.firstMatch(in: self,
                                                options: .reportProgress,
                                                range: NSMakeRange(0, self.characters.count))
      
      if let _ = result { return true }
      
    } catch {
      
      print("\(error.localizedDescription)")
    }
    
    return false
  }
  
  
  
  
  /*
   - (BOOL) wm_isContainEmoji {
   
   __block BOOL isContain = NO;
   
   [self enumerateSubstringsInRange:NSMakeRange(0, self.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
   
   
   const unichar high = [substring characterAtIndex: 0];
   
   // Surrogate pair (U+1D000-1F77F)
   if (0xd800 <= high && high <= 0xdbff) {
   const unichar low = [substring characterAtIndex: 1];
   const int codepoint = ((high - 0xd800) * 0x400) + (low - 0xdc00) + 0x10000;
   
   isContain = (0x1d000 <= codepoint && codepoint <= 0x1f77f);
   
   // Not surrogate pair (U+2100-27BF)
   } else {
   isContain = (0x2100 <= high && high <= 0x27bf);
   }
   if (isContain) {
   
   *stop = YES;
   }
   
   }];
   return isContain;
   }
   
   - (NSString *) wm_removeEmoji {
   
   NSMutableString* __block tailoredString = [NSMutableString stringWithCapacity:[self length]];
   
   [self enumerateSubstringsInRange:NSMakeRange(0, [self length])
   options:NSStringEnumerationByComposedCharacterSequences
   usingBlock: ^(NSString* substring, NSRange substringRange, NSRange enclosingRange, BOOL* stop) {
   
   BOOL isContain = NO;
   const unichar high = [substring characterAtIndex: 0];
   
   // Surrogate pair (U+1D000-1F77F)
   if (0xd800 <= high && high <= 0xdbff) {
   const unichar low = [substring characterAtIndex: 1];
   const int codepoint = ((high - 0xd800) * 0x400) + (low - 0xdc00) + 0x10000;
   
   isContain = (0x1d000 <= codepoint && codepoint <= 0x1f77f);
   
   // Not surrogate pair (U+2100-27BF)
   } else {
   isContain = (0x2100 <= high && high <= 0x27bf);
   }
   [tailoredString appendString:(isContain)? @"": substring];
   
   }];
   return [tailoredString copy];
   }
   */
  
}


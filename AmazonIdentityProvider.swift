//
//  AmazonIdentityProvider.swift
//
//  Created by Alex on 11/16/17.
//

import Foundation
import AWSS3
import AWSCore
import AWSCognito

final class DeveloperAuthenticatedIdentityProvider: AWSCognitoCredentialsProviderHelper {
  
  public var token_s:String?
  public var identityId_s: String?
  
  override func token() -> AWSTask<NSString> {
    self.identityId = self.identityId_s
    return AWSTask(result: self.token_s as NSString?)
  }
}

class AmazonAuth {
    
    static let sharedInstance = AmazonAuth()
    
    var json = JSON() {
        didSet {
            AmazonAuth.sharedInstance.bucket = json["bucket"].stringValue
            AmazonAuth.sharedInstance.roleArn = json["roleArn"].stringValue
            AmazonAuth.sharedInstance.token = json["token"].stringValue
            AmazonAuth.sharedInstance.identityId = json["identityId"].stringValue
        }
    }
    
    var roleArn = ""
    var bucket = ""
    var token = ""
    var identityId = ""
}




//
//  PresenterAddNewUser.swift
//  
//
//  Created by Alex on 10/31/17.
//

import Foundation
import AWSS3
import AWSCore
import AWSCognito
import AWSSNS
import Alamofire


class PresenterAddNewUser: NSObject, Presenter {
    
    typealias PresenterView = AddNewUserViewController
    
    weak var view: PresenterView!
    
    let service:RestServiceManager

    required init(view: PresenterView ,service:RestServiceManager = RestServiceManager()) {
        self.view = view
        self.service = service
    }
  
  func makeConfig() {
    let devAuth = DeveloperAuthenticatedIdentityProvider(regionType: .USEast1, identityPoolId: "us-east-1:xxx-xxx-xxx-xxx", useEnhancedFlow: true, identityProviderManager:nil)
    devAuth.token_s = AmazonAuth.sharedInstance.token
    devAuth.identityId_s = AmazonAuth.sharedInstance.identityId

    let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityProvider:devAuth)
    let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider:credentialsProvider)
    configuration?.timeoutIntervalForRequest = 10
    configuration?.timeoutIntervalForResource = 10
    AWSServiceManager.default().defaultServiceConfiguration = configuration
    
  }
  
  func getImageFromAws(imageName: String, completion: @escaping (_ pathToImage: String?) -> Void) {
    self.makeConfig()
    let request = AWSS3GetPreSignedURLRequest()
    request.bucket = AmazonAuth.sharedInstance.bucket
    request.key = imageName
    request.expires =  Date(timeIntervalSinceNow: 3600)
    request.httpMethod = .GET
    
    let urlTask = AWSS3PreSignedURLBuilder.default().getPreSignedURL(request)
    urlTask.continueWith(block: { (task) -> Any? in
      print(task.result)
      completion(task.result?.absoluteString)
    return nil
    })
  }
  
  func sendImageToAws(localPath: URL, completion: @escaping (_ pathToImage: String) -> Void) {
    self.makeConfig()

    let url = localPath
    let remoteName = "\(Utils.randomString(length: 14)).jpg"
    
    let uploadRequest = AWSS3TransferManagerUploadRequest()!
    uploadRequest.body = url
    uploadRequest.key = remoteName
    uploadRequest.bucket = AmazonAuth.sharedInstance.bucket
    
    let transferManager = AWSS3TransferManager.default()
    
    transferManager.upload(uploadRequest).continueWith {(task) -> Any? in
      if let error = task.error {
        print("Upload failed with error: (\(error.localizedDescription))")
      }
      
      if task.result != nil {
        let url = AWSS3.default().configuration.endpoint.url
        let publicURL = url?.appendingPathComponent(uploadRequest.bucket!).appendingPathComponent(uploadRequest.key!)
        if let absoluteString = publicURL?.absoluteString {
          completion(absoluteString)
        }
      }
      
      return nil
    }
    
  }
  
  
  func getAuthAmazon(completion: @escaping (_ succes: Bool) -> Void){
    
    self.view.startLoading()
    service.getAuthAmazon(completion: {authInfo in
      self.view.stopAnimating()
      AmazonAuth.sharedInstance.json = authInfo
      self.makeConfig()
      completion(true)
    }, failure: { (failure) in
      completion(false)
      self.view.stopAnimating()
      showAlert(title: nil, message: failure)
    })
  }
  

}




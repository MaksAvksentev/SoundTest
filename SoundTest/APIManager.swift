//
//  APIManager.swift
//  Vid.mePlay
//
//  Created by Maksim Avksentev on 4/6/17.
//  Copyright © 2017 Avksentev. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public enum ServerResponseCode: Int {
    case Success
    case Failure
}

public struct Response {
    
    public let request: URLRequest?
    public let response: HTTPURLResponse?
    public let data: Data?
    public var responseCode: ServerResponseCode
    public let afResult: Alamofire.Result<Any>
    public var errorMessage: String?
    
    public var value:Any? {
        return afResult.value
    }
    
    public var requestError:Error? {
        return afResult.error
    }
    
    public init(request: URLRequest?, response: HTTPURLResponse?, data: Data?, afResult: Result<Any>, responseCode: ServerResponseCode) {
        self.request = request
        self.response = response
        self.data = data
        self.afResult = afResult
        self.responseCode = responseCode
    }
}

typealias APIManagerDownloadRequestHandler = (Data?, Error?) -> Void

class APIManager {
    
    static let manager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        
        return SessionManager(configuration: configuration)
    }()
    
    static func performDownloadRequest(urlString: String, completionHandler: @escaping APIManagerDownloadRequestHandler) {
        
        Alamofire.request(urlString).responseData(completionHandler: {response in
            if let error = response.error {
                log.error(error, LogModule: .HTTP)
                completionHandler(nil, error)
                return
            }
            
            let data = response.value
            completionHandler(data, nil)
        })
    }
}

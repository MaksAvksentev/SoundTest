//
//  OperationQueueManager.swift
//  Vid.mePlay
//
//  Created by Maksim Avksentev on 4/6/17.
//  Copyright © 2017 Avksentev. All rights reserved.
//

import UIKit

private let kOperationQueueManagerMaxOperationCount = 10

class OperationQueueManager: NSObject {

    private static let sharedManager = OperationQueueManager()
    
    private var operationQueue = OperationQueue()
    
    static var shared: OperationQueueManager {
        return sharedManager
    }
    
    private override init() {
        
        super.init()
        
        self.initialize()
    }
    
    private func initialize() {
        
        self.operationQueue.maxConcurrentOperationCount = kOperationQueueManagerMaxOperationCount
    }
    
    func addToQueue(_ block: @escaping (Void) -> Void) {
        
        let operation = BlockOperation(block: block)
        self.operationQueue.addOperation(operation)
    }
    
    func cancelAllOperations() {
        
        self.operationQueue.cancelAllOperations()
    }
}

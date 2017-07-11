//
//  BaseViewController.swift
//  SoundTest
//
//  Created by Maksim Avksentev on 09.07.17.
//  Copyright © 2017 Avksentev. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    func presentErrorAlert(message: String?, animated: Bool, completionHandler: ((Void) -> Void)? = nil) {
        
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: animated, completion: completionHandler)
    }
}

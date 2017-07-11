//
//  UIViewController+Alerts.swift
//  SoundTest
//
//  Created by Maksim Avksentev on 10.07.17.
//  Copyright © 2017 Avksentev. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func presentNetworkAlert(animated: Bool, completionHandler: ((Void) -> Void)? = nil) {
        
        let alertController = UIAlertController(title: nil, message: "no_connection", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: {alertAction in
            let urlToSettings = UIApplicationOpenSettingsURLString
            UIApplication.shared.open(URL(string: urlToSettings)!, options: [:], completionHandler: nil)
        })
        
        alertController.addAction(okAction)
        alertController.addAction(settingsAction)
        
        self.present(alertController, animated: animated, completion: completionHandler)
    }
}

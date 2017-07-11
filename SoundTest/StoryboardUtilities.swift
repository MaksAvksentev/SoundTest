//
//  StoryboardUtilities.swift
//  SoundTest
//
//  Created by Maksim Avksentev on 10.07.17.
//  Copyright © 2017 Avksentev. All rights reserved.
//

import Foundation
import UIKit

fileprivate enum Storyboard : String {
    
    case main = "Main"
}

fileprivate extension UIStoryboard {
    
    static func loadFromMain(_ identifier: String) -> UIViewController {
        return load(from: .main, identifier: identifier)
    }
    
    static func load(from storyboard: Storyboard, identifier: String) -> UIViewController {
        let uiStoryboard = UIStoryboard(name: storyboard.rawValue, bundle: nil)
        return uiStoryboard.instantiateViewController(withIdentifier: identifier)
    }
}

extension UIStoryboard {
    
    class func loadTimerFromMain(_ identifier: String) -> TimerViewController {
        
        return loadFromMain(TimerViewController.className) as! TimerViewController
    }
}

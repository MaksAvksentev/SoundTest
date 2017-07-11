//
//  AllTracksViewController.swift
//  SoundTest
//
//  Created by Maksim Avksentev on 09.07.17.
//  Copyright © 2017 Avksentev. All rights reserved.
//

import UIKit

class AllTracksViewController: TracksViewController {
    
    override func typeForTrackDataSource() -> ControllerState {
        
        return .all
    }
}

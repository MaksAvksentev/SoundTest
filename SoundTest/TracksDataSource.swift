
//
//  TracksDataSource.swift
//  SoundTest
//
//  Created by Maksim Avksentev on 05.07.17.
//  Copyright © 2017 Avksentev. All rights reserved.
//

import UIKit
import Soundcloud

enum JPEGQuality: CGFloat {
    case lowest  = 0
    case low     = 0.25
    case medium  = 0.5
    case high    = 0.75
    case highest = 1
}

protocol TrackDataSourceProtocol: class {
    
    func addToFavorites(itemAtIndexPath indexPath: IndexPath)
    func typeForTrackDataSource() -> ControllerState
}

class TracksDataSource: NSObject, UITableViewDataSource, SoundCellDelegate {

    var state: ControllerState = .none
    
    var tracks: [String] {
    
        return TracksStore.shared.trackIdsArray(forType: self.state)
    }
   
    private var thumbnailDictionary = [String: Data]()
    
    weak var delegate: TrackDataSourceProtocol?
    
    var isEmpty: Bool {
        
        return self.tracks.count == 0
    }

    //MARK: - Init
    init(withState state: ControllerState) {
        
        super.init()
        self.state = state
    }
    
    //MARK: - Main
    func initialize() {
        
        guard let type = self.delegate?.typeForTrackDataSource() else {
            return
        }
        
        self.state = type
    }
    
    func update(completionHandler: @escaping SoundStoreCompletionHandler) {
        
        switch self.state {
        case .all:
            TracksStore.shared.updateAll(completionHandler: completionHandler)
        case .favorites:
            TracksStore.shared.updateFavorites(completionHandler: completionHandler)
        default:
            break
        }
    }
    
    func soundItem(forIndexPath indexPath: IndexPath) -> Sound?{
    
        guard let sound = Sound.findInContext(CoreDataManager.shared.viewContext, uniqueId: self.tracks[indexPath.row]) else {
        
            return nil
        }
        
        return sound
    }
    
    //MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SoundTableViewCell.reuseIdentifier, for: indexPath) as?SoundTableViewCell else {
        
            return UITableViewCell()
        }
        
        guard let sound = Sound.findInContext(CoreDataManager.shared.viewContext, uniqueId: self.tracks[indexPath.row]) else {
        
            return cell
        }
        
        cell.delegate = self
        
        cell.soundTitle.text = sound.title
        
        cell.accessoryView?.tag = indexPath.row
        
        if state == .all {
            
            cell.accessoryView?.isHidden = false
            switch sound.favorite {
            case true:
                DispatchQueue.main.async {
                    cell.accessoryView?.tintColor = UIColor.orange
                }
            case false:
                DispatchQueue.main.async {
                    cell.accessoryView?.tintColor = UIColor.gray
                }
            }
        } else {
        
            cell.accessoryView?.isHidden = true
        }
        
        if let imageData = self.thumbnailDictionary[sound.id!] {
            cell.soundImage.image = UIImage(data: imageData)
        } else {
            OperationQueueManager.shared.addToQueue {
                APIManager.performDownloadRequest(urlString: sound.artwork_url!, completionHandler: {[weak cell] data, error in
                    guard error == nil, let data = data else {
                        
                        return
                    }
                    
                    if let image = UIImage(data: data) {
                        let compressedData = UIImageJPEGRepresentation(image, JPEGQuality.low.rawValue)!
                        let compressedImage = UIImage(data: compressedData)
                        
                        self.thumbnailDictionary[sound.id!] = compressedData
                        sound.image = compressedData as NSData?
                        DispatchQueue.main.async {
                            cell?.soundImage.image = compressedImage
                        }
                    }
                })
            }
        }
        
        return cell
    }
    
    //MARK: - SoundCellDelegate
    func addToFavorites(itemAtIndexPath indexPath: IndexPath) {
        
        self.delegate?.addToFavorites(itemAtIndexPath: indexPath)
    }
}

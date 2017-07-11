//
//  TracksStore.swift
//  SoundTest
//
//  Created by Maksim Avksentev on 09.07.17.
//  Copyright © 2017 Avksentev. All rights reserved.
//

import UIKit
import Soundcloud

private struct TracksStoreKeys {
    
    static let allTracks = "tracks"
    static let favoriteTracks = "favoriteTracks"
}

typealias SoundStoreCompletionHandler = (Bool, Error?) -> Void

class TracksStore: NSObject {

    private static let sharedStore = TracksStore()
    
    static var shared: TracksStore {
    
        return sharedStore
    }
    
    private var allTracks = [String]()
    private var favoriteTracks = [String]()
    
    private override init() {
        
        super.init()
        
        self.initialize()
    }
    
    //MARK: - PUBLIC
    func trackIdsArray(forType type: ControllerState) -> [String] {
        
        switch type {
        case .all:
            return self.allTracks
        case .favorites:
            return self.favoriteTracks
        default:
            return [String]()
        }
    }

    func updateAll(completionHandler: @escaping SoundStoreCompletionHandler) {
        
        self.updateTracks(forType: .all, completionHandler: completionHandler)
    }
    
    func updateFavorites(completionHandler: @escaping SoundStoreCompletionHandler) {
        
        self.updateTracks(forType: .favorites, completionHandler: completionHandler)
    }
    
    private func updateTracks(forType type: ControllerState, completionHandler: @escaping SoundStoreCompletionHandler) {
        
        switch type {
        case .all:
            Playlist.playlist(identifier: 335679322) {[weak self] (response) in
                
                if response.response.isSuccessful {
                    guard let tracks = response.response.result?.tracks else{
                        
                        return
                    }
                    
                    for track in tracks {
                    
                        let id = String(track.identifier)
                        self?.addTrackInArray(forType: type, id: id)
                    }
                    
                    self?.save()
                    self?.mapTracks(fromTracks: tracks, completionHandler: completionHandler)
                    
                } else {
                    
                    let _ = response.response.error
                    //FIXME: - handle error here
                }
            }
        case .favorites:
            let array = Sound.findFavorites(inContext: CoreDataManager.shared.viewContext)
            self.favoriteTracks = [String]()
            for track in array {
                self.addTrackInArray(forType: .favorites, id: track.id!)
            }
            completionHandler(true, nil)
        default:
            return
        }
    }
    
    private func addTrackInArray(forType type: ControllerState, id: String) {
        
        switch type {
        case .all:
            if !self.allTracks.contains(id) {
                self.allTracks.append(id)
            }
        case .favorites:
            if !self.favoriteTracks.contains(id) {
                self.favoriteTracks.append(id)
            }
        default:
            break
        }
    }
    
    private func mapTracks(fromTracks tracks:[Track], completionHandler: (SoundStoreCompletionHandler)? = nil) {
        
        CoreDataManager.shared.performBackgroundTask {(context) in
            
            var tempArray = [String]()
            
            for track in tracks {
                
                let trackId = track.identifier
                tempArray.append(String(trackId))
                
                if let sound = Sound.findInContext(context, uniqueId: String(trackId)) {
                    
                    sound.updateEntity(withTrack: track)
                } else {
                    
                    let _ = Sound.createInContext(context, track: track)
                }
            }
            
            let array = Array(Set(self.allTracks).subtracting(Set(tempArray)))
            
            for track in array {
                self.allTracks.remove(at: self.allTracks.index(of: track)!)
                if let sound = Sound.findInContext(context, uniqueId: track) {
                    context.delete(sound)
                }
            }
            
            
            context.saveContext({result in
                switch result {
                case .success:
                    completionHandler?(true, nil)
                case .failure(let error):
                    completionHandler?(false, error)
                }
            })
        }
    }

    //MARK: - Storing
    private func initialize() {
        
        let all = UserDefaults.standard.data(forKey: TracksStoreKeys.allTracks)
        let favorites = UserDefaults.standard.data(forKey: TracksStoreKeys.favoriteTracks)
        
        if let data = all, let arrayMusic = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String] {
        
            self.allTracks = arrayMusic
        }
        
        if let data = favorites, let arrayMusic = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String] {
            
            self.favoriteTracks = arrayMusic
        }
    }
    
    func save() {
        
        let all = NSKeyedArchiver.archivedData(withRootObject: self.allTracks)
        UserDefaults.standard.set(all, forKey: TracksStoreKeys.allTracks)
      
        let favorites = NSKeyedArchiver.archivedData(withRootObject: self.favoriteTracks)
        UserDefaults.standard.set(favorites, forKey: TracksStoreKeys.favoriteTracks)
        
        UserDefaults.standard.synchronize()
    }
}

//
//  Sound.swift
//  SoundTest
//
//  Created by Maksim Avksentev on 05.07.17.
//  Copyright © 2017 Avksentev. All rights reserved.
//

import Foundation
import CoreData
import BNRCoreDataStack
import Soundcloud

extension Sound {
    
    class func findInContext(_ context: NSManagedObjectContext, uniqueId: String) -> Sound? {
        
        let identifierPredicate = NSPredicate(format: "id == %@", uniqueId)
        
        guard let sound = try? self.findFirstInContext(context, predicate: identifierPredicate) else {
            return nil
        }
        
        return sound
    }
    
    class func createInContext(_ context: NSManagedObjectContext, track: Track) -> Sound {
        
        let sound = Sound(entity: Sound.entity(), insertInto: context)
        
        sound.id = String(track.identifier)
        sound.title = track.title
        sound.artwork_url = track.artworkImageURL.highURL?.absoluteString
        sound.stream_url = track.streamURL?.absoluteString
        sound.favorite = false
        sound.uri = track.uri ?? ""
        
        return sound
    }
    
    class func findAll(inContext context: NSManagedObjectContext) -> [Sound] {
        
        guard let sounds = try? allInContext(context, predicate: nil) else {
        
            return [Sound]()
        }
        
        return sounds
    }
    
    class func findFavorites(inContext context: NSManagedObjectContext) -> [Sound] {
    
        let predicate = NSPredicate(format: "favorite == %@", NSNumber(value: true))
        
        guard let sounds = try? allInContext(context, predicate: predicate) else {
            
            return [Sound]()
        }
        
        return sounds
    }
    
    class func find(inContext context: NSManagedObjectContext, withStream stream: String) -> Sound? {
    
        let identifierPredicate = NSPredicate(format: "stream_url == %@", stream)
        
        guard let sound = try? self.findFirstInContext(context, predicate: identifierPredicate) else {
            return nil
        }
        
        return sound
    }
    
    func updateEntity(withTrack track: Track) {
        
        self.title = track.title
        self.artwork_url = track.artworkImageURL.highURL?.absoluteString
    }
}

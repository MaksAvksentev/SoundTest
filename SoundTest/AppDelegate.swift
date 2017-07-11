//
//  AppDelegate.swift
//  SoundTest
//
//  Created by Maksim Avksentev on 05.07.17.
//  Copyright © 2017 Avksentev. All rights reserved.
//

import UIKit
import CoreData
import Soundcloud
import UserNotifications
import ReachabilitySwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var isGrantedNotificationAccess: Bool = false
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    var timer: Timer?
    
    let reachability = Reachability()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        CoreDataManager.shared.initialize()
        self.configureSoundCloud()
        self.configureNotifications()
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        guard let timer = self.timer else {
        
            return
        }
        
        timer.invalidate()
        
        self.setupNetworkObserving()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) {
            timer in
            
            self.sendNotifications()
        }
        
        self.backgroundTask = application.beginBackgroundTask { [weak self] in
            
                self?.endBackgroundTask()
        }
        
        assert(backgroundTask != UIBackgroundTaskInvalid)
        
        TracksStore.shared.save()
        reachability?.stopNotifier()
    }
    
    //MARK: - Private
    private func configureSoundCloud() {
        
        Soundcloud.clientIdentifier = "5f61421beef03933a192f6ea1266e293"
        Soundcloud.clientSecret = ""
        Soundcloud.redirectURI = ""
    }
    
    private func setupNetworkObserving() {
        
        reachability?.whenUnreachable = {reachability in
            DispatchQueue.main.async {
                self.window?.rootViewController?.presentNetworkAlert(animated: true)
            }
        }
        
        do {
            try reachability?.startNotifier()
        } catch {
            //FIXME: - log error
        }
    }

    //MARK: - LocalNotifications
    private func configureNotifications() {
    
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge], completionHandler: {[weak self](granted, error) in
                self?.isGrantedNotificationAccess = granted
        })
    }
    
    private func endBackgroundTask() {
        
        print("Background task ended.")
        UIApplication.shared.endBackgroundTask(self.backgroundTask)
        self.backgroundTask = UIBackgroundTaskInvalid
    }
    
    func sendNotifications() {
    
        if self.isGrantedNotificationAccess {
            
            let countOld = TracksStore.shared.trackIdsArray(forType: .all).count
            
            TracksStore.shared.updateAll(completionHandler: { (success, error) in
                
                
                let countNew = TracksStore.shared.trackIdsArray(forType: .all).count
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3.0, repeats: false)
                
                if countOld != countNew {
                    
                    let content = UNMutableNotificationContent()
                    content.title = "Updates"
                    content.body = "Playlist has updatse"
                    content.categoryIdentifier = "alert"
                    content.sound = UNNotificationSound.default()
                    let request = UNNotificationRequest(identifier: "10.second.message", content: content, trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                } else {
                    
                    let content = UNMutableNotificationContent()
                    content.title = "Without updates"
                    content.body = "Playlist hasn't updates"
                    content.categoryIdentifier = "alert"
                    content.sound = UNNotificationSound.default()
                    
                    let request = UNNotificationRequest(identifier: "10.second.message", content: content, trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                }
            })
        }
    }
}

//5f61421beef03933a192f6ea1266e293
//986b39d4513a5b501d57d973318715f0
//342b8a7af638944906dcdb46f9d56d98

//
//  ViewController.swift
//  LocalNotifications
//
//  Created by Julian Moorhouse on 15/08/2019.
//  Copyright © 2019 Mindwarp Consultancy Ltd. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleLocalAsk))
    }

    @objc func registerLocal() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) {
            granted, error in
            if granted {
                print("Yay!")
            } else {
                // Remember you'll need to reset the simulator content
                print("D'oh!")
            }
        }
    }
    
    @objc func scheduleLocalAsk() {
        let ac = UIAlertController(title: "Action type", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "alarm", style: .default, handler: {
            
            [weak self] (alert) in
            self?.scheduleLocal(category: "alarm", title: "Late wake up call", message: "The early bird catches the worm, but the second mouse gets the cheese.")
        }))
        ac.addAction(UIAlertAction(title: "test", style: .default, handler: {
            [weak self] (alert) in
            self?.scheduleLocal(category: "test", title: "Test Notificiation", message: "Testing")
        }))
        present(ac, animated: true)
    }

    func scheduleLocal(category: String, title: String, message: String) {
        registerCategories()
        
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests() // don't have to use this
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.categoryIdentifier = category // identify for use on receipt
        content.userInfo = ["customData": "fizzbuzz"] // identify for use on receipt
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 29
        
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let interval = 5
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(interval), repeats: false)
        
        // remember you can use the same identifier which will update a notification rather than send new ones, e.g. goals in a football match
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        center.add(request)
        
        // remember to immediate lock the device or command + L on the simulator, so the notification is shown after those 4 seconds
    }
    
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        let show = UNNotificationAction(identifier: "show", title: "Tell me more", options: .foreground)
        let showTest = UNNotificationAction(identifier: "test", title: "Test", options: .foreground)
        
        let remindMe = UNNotificationAction(identifier: "remindme", title: "Remind me later", options: .foreground)
        
        let category = UNNotificationCategory(identifier: "alarm", actions: [show, remindMe], intentIdentifiers: [], options: [])
        let testCategory = UNNotificationCategory(identifier: "test", actions: [showTest], intentIdentifiers: [], options: [])

        center.setNotificationCategories([category, testCategory])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let customData = userInfo["customData"] as? String {
            print("Custom data received: \(customData)")
            
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                // the user swiped to unlock
                print("Default identifier")
                
            case "show":
                // The user swiped the notification, tapped "View", then "Tell me more" appeared
                let ac = UIAlertController(title: "Message", message: "Show more information...", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .cancel))
                present(ac, animated: true)
            case "test":
                let ac = UIAlertController(title: "Message", message: "Test custom", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .cancel))
                present(ac, animated: true)
            case "remindme":
                let ac = UIAlertController(title: "Message", message: "Remind me later, will now remind in 24 hours", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .cancel))
                present(ac, animated: true)
                
                scheduleLocal(category: "remind24", title: "Reminder", message: "This is your 24 hour reminder")
            default:
                break
                
            }
        }
        
        completionHandler()
    }
}



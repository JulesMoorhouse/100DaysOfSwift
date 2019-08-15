//
//  ViewController.swift
//  GuessTheFlag
//
//  Created by Julian Moorhouse on 07/07/2019.
//  Copyright © 2019 Mindwarp Consultancy Ltd. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    
    var countries = [String]()
    var score = 0
    var correctAnswer = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
        
        button1.layer.borderWidth = 1
        button2.layer.borderWidth = 1
        button3.layer.borderWidth = 1
        
        button1.layer.borderColor = UIColor.lightGray.cgColor
        button2.layer.borderColor = UIColor.lightGray.cgColor
        button3.layer.borderColor = UIColor.lightGray.cgColor

        askQuestion()
    }

    func askQuestion(action: UIAlertAction! = nil) {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        
        let country = countries[correctAnswer].uppercased()
        title = "Guess \(country) ? : Score (\(score) of 10)"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        registerLocal()
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        var title: String
        var message: String = ""
        if sender.tag == correctAnswer {
            title = "Correct"
            score += 1
        } else {
            title = "Wrong"
            message += "Wrong! Thats the flag of \(countries[sender.tag])\n\n";
            score -= 1
        }
        
        if (score >= 10) {
            message += "Your final score was \(score)"
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 5, options: [], animations: {
            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)

        }) {finished in
            sender.transform = .identity
        }
    
        if (message != "") {
            let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
            
            present(ac, animated: true)
        } else {
            askQuestion()
        }
    }
    
    func registerLocal() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) {
            [weak self] granted, error in
            if granted {
                print("Yay!")
                self?.scheduleLocal()
            } else {
                // Remember you'll need to reset the simulator content
                print("D'oh!")
            }
        }
    }
    
    func scheduleLocal() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        center.removeAllPendingNotificationRequests() // don't have to use this
        
        let content = UNMutableNotificationContent()
        content.title = "Game"
        content.body = "It's time to play the game!"
        content.categoryIdentifier = "category" // identify for use on receipt
        content.userInfo = ["customData": "fizzbuzz"] // identify for use on receipt
        content.sound = .default
        
        let interval = 5 // 1440 * 60 - aka 2 hours
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(interval), repeats: false)
        
        // remember you can use the same identifier which will update a notification rather than send new ones, e.g. goals in a football match
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        center.add(request)
        
        // remember to immediate lock the device or command + L on the simulator, so the notification is shown after those 4 seconds
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let customData = userInfo["customData"] as? String {
            print("Custom data received: \(customData)")
            
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                // the user swiped to unlock
                print("Default identifier")
                
    
                let ac = UIAlertController(title: "Message", message: "Welcome back", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .cancel))
                present(ac, animated: true)
                
            default:
                break
                
            }
        }
        
        completionHandler()
    }
}


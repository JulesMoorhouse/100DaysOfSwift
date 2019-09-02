//
//  ViewController.swift
//  SecretSwift
//
//  Created by Julian Moorhouse on 29/08/2019.
//  Copyright © 2019 Mindwarp Consultancy Ltd. All rights reserved.
//

import LocalAuthentication
import UIKit

class ViewController: UIViewController {
    let KEY_SECRET_MESSAGE = "SecretMessage"
    let KEY_PASSWORD = "Password"
    
    @IBOutlet var secret: UITextView!
    var doneButton: UIBarButtonItem!
    var setPasswordButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Nothing to see here"
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        // when leave app
        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)
        
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveSecretMessage))
        
        setPasswordButton = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(setPassword))
        
        shouldShowSettings()
    }
    
    @IBAction func authenticateTapped(_ sender: Any) {
        checkBiometry({
            // found
            let context = LAContext()
            let reason = "Identifiy yourself!" // for touch id
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, _ in
                DispatchQueue.main.async {
                    if success {
                        self?.unlockSecretMessage()
                    } else {
                        let ac = UIAlertController(title: "Authentication failed", message: "You could not be verified. Please try again.", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(ac, animated: true)
                    }
                }
            }
        }) {
            // not found
            let ac = UIAlertController(title: "App Pasword", message: "Please provide your password!", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default) {
                [weak self, weak ac] _ in
                
                guard let previousPassword = ac?.textFields?[0].text else { return }
                
                if let text = KeychainWrapper.standard.string(forKey: self!.KEY_PASSWORD) {
                    if previousPassword == text {
                        self?.unlockSecretMessage()
                    } else {
                        let ac2 = UIAlertController(title: "App Pasword", message: "Password incorrect!", preferredStyle: .alert)
                        ac2.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(ac2, animated: true)
                    }
                }
            }
            ac.addAction(okAction)
            ac.addTextField(configurationHandler: { textField in
                textField.placeholder = "Password"
                textField.isSecureTextEntry = true
            })
            
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(ac, animated: true)
        }
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEnd = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEnd, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            secret.contentInset = .zero
        } else {
            secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        secret.scrollIndicatorInsets = secret.contentInset
        
        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
    }
    
    func unlockSecretMessage() {
        secret.isHidden = false
        navigationItem.rightBarButtonItem = doneButton
        navigationItem.leftBarButtonItem = setPasswordButton
        title = "Secret stuff!"
        
        if let text = KeychainWrapper.standard.string(forKey: KEY_SECRET_MESSAGE) {
            secret.text = text
        }
    }
    
    @objc func saveSecretMessage() {
        guard secret.isHidden == false else { return }
        
        KeychainWrapper.standard.set(secret.text, forKey: KEY_SECRET_MESSAGE)
        secret.resignFirstResponder()
        secret.isHidden = true
        navigationItem.rightBarButtonItem = nil
        shouldShowSettings()
        
        title = "Nothing to see here"
    }
    
    func checkBiometry(_ foundCompletion: () -> (), _ notFoundCompletion: () -> ()) {
        // https://stackoverflow.com/questions/29824488/when-to-use-closures-in-swift
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            foundCompletion()
        } else {
            notFoundCompletion()
        }
    }
    
    @objc func setPassword() {
        let ac = UIAlertController(title: "App Pasword", message: "Please provide a password!", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [weak ac] _ in
            
            guard let text = ac?.textFields?[0].text else { return }
            
            let saveSuccessful: Bool = KeychainWrapper.standard.set(text, forKey: self.KEY_PASSWORD)
            
            print("SaveSuccessful=\(saveSuccessful)")
            
        }
        saveAction.isEnabled = false
        
        ac.addAction(saveAction)
        
        ac.addTextField(configurationHandler: { textField in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
            
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main, using: { _ in
                let textCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
                let textIsNotEmpty = textCount > 0
                guard let repeatPassword = ac.textFields?[1].text else { return }
                let same = textField.text == repeatPassword
                saveAction.isEnabled = textIsNotEmpty && same
            })
        })
        
        ac.addTextField(configurationHandler: { textField in
            textField.placeholder = "Repeat password"
            textField.isSecureTextEntry = true
            
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main, using: { _ in
                let textCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
                let textIsNotEmpty = textCount > 0
                guard let password = ac.textFields?[0].text else { return }
                let same = password == textField.text
                
                saveAction.isEnabled = textIsNotEmpty && same
            })
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func shouldShowSettings() {
        checkBiometry({
            // print("found")
        }) {
            let text = KeychainWrapper.standard.string(forKey: KEY_PASSWORD) ?? ""
            if text == "" {
                navigationItem.leftBarButtonItem = setPasswordButton
            } else {
                navigationItem.leftBarButtonItem = nil
            }
        }
    }
}

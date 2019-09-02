//
//  ViewController.swift
//  NamesToFaces
//
//  Created by Julian Moorhouse on 06/08/2019.
//  Copyright © 2019 Mindwarp Consultancy Ltd. All rights reserved.
//

import LocalAuthentication
import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let KEY_PASSWORD = "Password"
    
    var people = [Person]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let setPasswordButton = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(setPassword))
        
        let addPerson = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
        
        var arr = [addPerson]
        
        checkBiometry({
            // print("found")
        }) {
            let text = KeychainWrapper.standard.string(forKey: KEY_PASSWORD) ?? ""
            if text == "" {
                arr.append(setPasswordButton)
            }
        }
        
        navigationItem.leftBarButtonItems = arr
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(authenticate))
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Unable to dequeue PersonCell")
        }
        
        let person = people[indexPath.item]
        
        cell.Name.text = person.name
        
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.ImageView.image = UIImage(contentsOfFile: path.path)
        
        cell.ImageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.ImageView.layer.borderWidth = 2
        cell.ImageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = people[indexPath.item]
        
        let ac = UIAlertController(title: "Person", message: "Would you like to rename or delete this person?", preferredStyle: .alert)
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "Rename", style: .default) {
            [weak self, weak ac] _ in
            guard let newName = ac?.textFields?[0].text else { return }
            person.name = newName
            self?.save()
            self?.collectionView.reloadData()
        })
        
        ac.addAction(UIAlertAction(title: "Delete", style: .default) {
            [weak self] _ in
            self?.people.remove(at: indexPath.item)
            self?.save()
            self?.collectionView.reloadData()
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @objc func addNewPerson() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            picker.sourceType = UIImagePickerController.SourceType.camera
        }
        
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        save()
        collectionView.reloadData()
        
        dismiss(animated: true)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        
        if let savedDate = try? jsonEncoder.encode(people) {
            let defaults = UserDefaults.standard
            defaults.set(savedDate, forKey: "people")
        } else {
            print("Failed to save people")
        }
    }
    
    func loadPeople() {
        let defaults = UserDefaults.standard
        
        if let savedpeople = defaults.object(forKey: "people") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                people = try jsonDecoder.decode([Person].self, from: savedpeople)
                
                collectionView.reloadData()
            } catch {
                print("Failed to load people.")
            }
        }
    }
    
    @objc func authenticate() {
        checkBiometry({
            // found
            let context = LAContext()
            let reason = "Identifiy yourself!" // for touch id
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, _ in
                DispatchQueue.main.async {
                    if success {
                        self?.loadPeople()
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
                        self?.loadPeople()
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
}

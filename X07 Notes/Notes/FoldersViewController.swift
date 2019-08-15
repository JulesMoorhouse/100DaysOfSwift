//
//  ViewController.swift
//  Notes
//
//  Created by Julian Moorhouse on 15/08/2019.
//  Copyright © 2019 Mindwarp Consultancy Ltd. All rights reserved.
//

import UIKit

class FoldersViewController: UITableViewController {
    var folders = [Folder]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Folders"
        navigationController?.navigationBar.prefersLargeTitles = true

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

//        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editItems))
//        
        let newFolder = UIBarButtonItem(title: "New Folder", style: .plain, target: self, action: #selector(addNewFolder))
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        setToolbarItems([flex, newFolder], animated: true)
        
        loadFolders()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folders.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Folder", for: indexPath)
        
        let item = folders[indexPath.row]
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = "" // TODO: Count
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "sb_NoteList") as? NoteListViewController {
            let item = folders[indexPath.row]

            vc.folder = item
            //vc.websites = websites
            //vc.selectedWebsiteIndex = indexPath.row
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
//    @objc func editItems() {
//        
//    }
    
    @objc func addNewFolder() {
        let ac = UIAlertController(title: "New Folder", message: "Enter a name for this folder.", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [weak self, weak ac] action in
            
            guard let text = ac?.textFields?[0].text else { return }
            
            self?.folders.append(Folder(name: text))
            self?.tableView.reloadData()
            self?.saveFolders()
        }
        saveAction.isEnabled = false
        
        ac.addAction(saveAction)
        ac.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Name"
            
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main, using: {_ in
                let textCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
                let textIsNotEmpty = textCount > 0
                saveAction.isEnabled = textIsNotEmpty
            })
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func saveFolders() {
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(folders) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "folders")
        } else {
            print("Failed to save folders")
        }
    }
    
    func loadFolders() {
        let defaults = UserDefaults.standard
        
        if let savedFolders = defaults.object(forKey: "folders") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                folders = try jsonDecoder.decode([Folder].self, from: savedFolders)
            } catch {
                print("Failed to load folders.")
            }
        }
    }
}


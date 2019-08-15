//
//  NoteListViewController.swift
//  Notes
//
//  Created by Julian Moorhouse on 15/08/2019.
//  Copyright © 2019 Mindwarp Consultancy Ltd. All rights reserved.
//

import UIKit

class NoteListViewController: UITableViewController {
    var folder: Folder?
    var notes = [Note]()
    var notesInFolder = [Note]()
    
    var toolbarLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Notes", style: .plain, target: nil, action: nil)

        
        title = folder?.name
        
        let newFolder = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(composeNewNote))
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let fixed = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        
        toolbarLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        toolbarLabel.text = "0 Notes"
        toolbarLabel.center = CGPoint(x: view.frame.midX, y: view.frame.height)
        toolbarLabel.textAlignment = NSTextAlignment.center

        let toolbarTitle = UIBarButtonItem(customView: toolbarLabel)
        
        setToolbarItems([fixed, flex, toolbarTitle, flex, newFolder], animated: true)
        
        loadNotes()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesInFolder.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Note", for: indexPath)
        
        let item = notesInFolder[indexPath.row]
        
        let array = item.content?.components(separatedBy: .newlines)
        let firstLine = array?[0]
        let secondLine = array?[1]

        cell.textLabel?.text = firstLine
        cell.detailTextLabel?.text = secondLine
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "sb_Note") as? NoteViewController {
            
            let item = notesInFolder[indexPath.row]

            vc.note = item
            
            vc.didUpdateItem = {
                [weak self] (item) in
                // update
                self?.notes.filter {$0.uuid == item.uuid }.first?.content = item.content
                self?.saveNotes()
                self?.tableView.reloadData()
            }
            
            vc.didDeleteItem = {
                [weak self] (item) in
                // update
                self?.notes.removeAll() {$0.uuid == item.uuid }
                self?.saveNotes()
                self?.tableView.reloadData()
            }
            
            navigationController?.pushViewController(vc, animated: true)
        }

    }

    @objc func composeNewNote() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "sb_Note") as? NoteViewController {
            
            guard let folderUuid = folder?.uuid else { return }
            
            let item = Note(content: "", folderUuid: folderUuid)

            vc.note = item
            
            vc.didUpdateItem = {
                [weak self] (item) in
                // update
                self?.notes.append(item)
                self?.saveNotes()
                self?.tableView.reloadData()
            }
            
            vc.didDeleteItem = {
                [weak self] (item) in
                // update
                self?.notes.removeAll() {$0.uuid == item.uuid }
                self?.saveNotes()
                self?.tableView.reloadData()
            }
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func saveNotes() {
        let jsonEncoder = JSONEncoder()
       
        if let savedData = try? jsonEncoder.encode(notes) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "notes")
        } else {
            print("Failed to save notes")
        }
        
        let uuid = folder?.uuid!
        notesInFolder = notes.filter{ $0.folderUuid == uuid }

    }
   
    func loadNotes() {
        let defaults = UserDefaults.standard
       
        if let savedNotes = defaults.object(forKey: "notes") as? Data {
            let jsonDecoder = JSONDecoder()
           
            do {
                notes = try jsonDecoder.decode([Note].self, from: savedNotes)
            } catch {
                print("Failed to load notes.")
            }
        
            let uuid = folder?.uuid!
            notesInFolder = notes.filter{ $0.folderUuid == uuid }
        
            toolbarLabel.text = "\(notesInFolder.count) Notes"
       }
   }
}

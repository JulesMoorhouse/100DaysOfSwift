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

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editItems))
        
        let newFolder = UIBarButtonItem(title: "New Folder", style: .plain, target: self, action: #selector(addNewFolder))
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        setToolbarItems([flex, newFolder], animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Folder", for: indexPath)
        cell.textLabel?.text = "One"
        cell.detailTextLabel?.text = "99"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "sb_NoteList") as? NoteListViewController {
            //vc.websites = websites
            //vc.selectedWebsiteIndex = indexPath.row
            navigationController?.pushViewController(vc, animated: true)
        }

    }
    
    @objc func editItems() {
        
    }
    
    @objc func addNewFolder() {
        
    }
}


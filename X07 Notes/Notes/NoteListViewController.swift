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
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Note", for: indexPath)
        cell.textLabel?.text = "One"
        cell.detailTextLabel?.text = "99"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "sb_Note") as? NoteViewController {
            //vc.websites = websites
            //vc.selectedWebsiteIndex = indexPath.row
            navigationController?.pushViewController(vc, animated: true)
        }

    }
}

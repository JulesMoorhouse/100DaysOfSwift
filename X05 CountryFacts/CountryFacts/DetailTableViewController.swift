//
//  DetailTableViewController.swift
//  CountryFacts
//
//  Created by Julian Moorhouse on 11/08/2019.
//  Copyright © 2019 Mindwarp Consultancy Ltd. All rights reserved.
//

import UIKit

class DetailTableViewController: UITableViewController {
    var country: Country!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = country.name
        
        let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
        navigationItem.rightBarButtonItems = [share]

    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)

        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Capital city"
            cell.detailTextLabel?.text = country.capitalCity
            break
        case 1:
            cell.textLabel?.text = "Currency"
            cell.detailTextLabel?.text = country.currency
            break
        default:
            break
        }

        return cell
    }
    
    @objc func shareTapped() {
        
        let list = "Country: \(country.name)\nCapital City: \(country.capitalCity)\nCurrency: \(country.currency)"

        let vc = UIActivityViewController(activityItems: [list], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
}

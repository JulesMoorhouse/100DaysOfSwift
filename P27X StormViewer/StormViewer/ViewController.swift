//
//  ViewController.swift
//  StormViewer
//
//  Created by Julian Moorhouse on 04/07/2019.
//  Copyright © 2019 Mindwarp Consultancy Ltd. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    var storms = [Storm]()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Storm Viewer"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        performSelector(inBackground: #selector(loadImages), with: nil)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storms.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        let views = storms[indexPath.row].viewCount
        
        cell.textLabel?.text = storms[indexPath.row].pictureName
        cell.detailTextLabel?.text = views > 0 ? "Views: \(views)" : ""
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.selectedImage = storms[indexPath.row].pictureName
            vc.selectedPictureNumber = indexPath.row + 1
            vc.totalPictures = storms.count
            
            storms[indexPath.row].viewCount += 1
            
            save()
            
            tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func loadImages() {
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        for item in items {
            if item.hasPrefix("nssl") {
                // this is a picture to load!
                storms.append(Storm(pictureName: item, viewCount: 0))
            }
        }
        
        load()
        
        //storms.sort()
        print(storms)
        
        tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        
        if let savedDate = try? jsonEncoder.encode(storms) {
            let defaults = UserDefaults.standard
            defaults.set(savedDate, forKey: "storms")
        } else {
            print("Failed to save storms")
        }
    }

    func load() {
        let defaults = UserDefaults.standard
        
        if let savedStorms = defaults.object(forKey: "storms") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                storms = try jsonDecoder.decode([Storm].self, from: savedStorms)
            } catch {
                print("Failed to load storms.")
            }
        }
    }
}


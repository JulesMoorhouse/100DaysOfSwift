//
//  SelectionViewController.swift
//  Project30
//
//  Created by TwoStraws on 20/08/2016.
//  Copyright (c) 2016 TwoStraws. All rights reserved.
//

import UIKit

class SelectionViewController: UITableViewController {
    var images = [UIImage]() // this is the array that will store the filenames to load
    //	var viewControllers = [UIViewController]() // create a cache of the detail view controllers for faster loading
    var imageNames = [String]()
    var dirty = false

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Reactionist"

        tableView.rowHeight = 90
        tableView.separatorStyle = .none

        // Always get back a dequeued cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        // load all the JPEGs into our array
        let fm = FileManager.default

        if let tempItems = try? fm.contentsOfDirectory(atPath: Bundle.main.resourcePath!) {
            for item in tempItems {
                if item.range(of: "Large") != nil {
                    let imageRootName = item.replacingOccurrences(of: "Large", with: "Thumb")

                    if let path = Bundle.main.path(forResource: imageRootName, ofType: nil) {
                        if let original = UIImage(contentsOfFile: path) {
                            // Rendering will now use a much smaller size than the original image size
                            let renderRect = CGRect(origin: .zero, size: CGSize(width: 90, height: 90))

                            let renderer = UIGraphicsImageRenderer(size: renderRect.size)

                            let rounded = renderer.image { ctx in
                                ctx.cgContext.addEllipse(in: renderRect)
                                ctx.cgContext.clip()

                                original.draw(in: renderRect)
                            }
                            images.append(rounded)
                            imageNames.append(imageRootName)
                        }
                    }
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if dirty {
            // we've been marked as needing a counter reload, so reload the whole table
            tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return images.count * 10
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // This does mean you can't use different types of cell when you're using the newer register approach
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // find the image for this cell, and load its thumbnail
        let currentImage = images[indexPath.row % images.count]
        let renderRect = CGRect(origin: .zero, size: CGSize(width: 90, height: 90))

        cell.imageView?.image = currentImage

        // give the images a nice shadow to make them look a bit more dramatic
        cell.imageView?.layer.shadowColor = UIColor.black.cgColor
        cell.imageView?.layer.shadowOpacity = 1
        cell.imageView?.layer.shadowRadius = 10
        cell.imageView?.layer.shadowOffset = CGSize.zero

        cell.imageView?.layer.shadowPath = UIBezierPath(ovalIn: renderRect).cgPath

        let imageName = imageNames[indexPath.row % images.count]
        // each image stores how often it's been tapped
        let defaults = UserDefaults.standard
        cell.textLabel?.text = "\(defaults.integer(forKey: imageName))"
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ImageViewController()
        vc.image = imageNames[indexPath.row % images.count]
        vc.owner = self

        // mark us as not needing a counter reload when we return
        dirty = false

        // add to our view controller cache and show
        //		viewControllers.append(vc)
        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        }
    }
}

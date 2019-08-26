//
//  ViewController.swift
//  MemeGenerator
//
//  Created by Julian Moorhouse on 26/08/2019.
//  Copyright © 2019 Mindwarp Consultancy Ltd. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var imageView: UIImageView!
    
    var topText: String?
    var bottomText: String?
    var photo: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewMeme))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(shareMeme))
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        photo = image
        drawMeme()
        
        dismiss(animated: true)
    }
    
    @objc func addNewMeme() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            picker.sourceType = UIImagePickerController.SourceType.camera
        }
        
        present(picker, animated: true)
    }
    
    @objc func shareMeme() {
        guard let image = imageView.image else {
            print("No image found")
            return
        }
        
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    func drawMeme() {
        guard let source = photo else {
            print("No image found")
            return
        }
        
        let imageSize = source.size
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: imageSize.width, height: imageSize.height))
        
        let image = renderer.image { _ in
            
            photo?.draw(at: CGPoint(x: 0, y: 0))
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.lineBreakMode = .byWordWrapping
            
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 70),
                .foregroundColor: UIColor.red,
                .paragraphStyle: paragraphStyle,
                .strokeWidth: -4,
                .strokeColor: UIColor.yellow,
            ]
            
            let stringHeight: CGFloat = 200.0
            let margin: CGFloat = 50.0
            
            let topAttributedString = NSAttributedString(string: topText ?? "", attributes: attrs)
            
            topAttributedString.draw(with: CGRect(x: 0, y: margin, width: imageSize.width, height: stringHeight), options: .usesLineFragmentOrigin, context: nil)
            
            let bottomAttributedString = NSAttributedString(string: bottomText ?? "", attributes: attrs)
            
            let boundingBox = bottomAttributedString.boundingRect(
                with: CGSize(width: imageSize.width, height: imageSize.height),
                options: [.usesLineFragmentOrigin],
                context: nil
            )
            
            let bottomY = (imageSize.height - boundingBox.size.height) - margin
            
            bottomAttributedString.draw(with: CGRect(x: 0, y: bottomY, width: imageSize.width, height: boundingBox.size.height), options: .usesLineFragmentOrigin, context: nil)
        }
        
        imageView.image = image
    }
    
    @IBAction func setTopTextTapped(_ sender: Any) {
        let ac = UIAlertController(title: "Meme Generator", message: nil, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "OK", style: .default) {
            [weak self, weak ac] _ in
            
            guard let text = ac?.textFields?[0].text else { return }
            self?.topText = text
            self?.drawMeme()
        }
        ac.addAction(saveAction)
        ac.addTextField(configurationHandler: { textField in
            textField.placeholder = "Top text"
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @IBAction func setBottomTextTapped(_ sender: Any) {
        let ac = UIAlertController(title: "Meme Generator", message: nil, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "OK", style: .default) {
            [weak self, weak ac] _ in
            
            guard let text = ac?.textFields?[0].text else { return }
            self?.bottomText = text
            self?.drawMeme()
        }
        
        ac.addAction(saveAction)
        ac.addTextField(configurationHandler: { textField in
            textField.placeholder = "Bottom text"
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
}

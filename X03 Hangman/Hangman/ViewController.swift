//
//  ViewController.swift
//  Hangman
//
//  Created by Julian Moorhouse on 06/08/2019.
//  Copyright © 2019 Mindwarp Consultancy Ltd. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var scoreLabel: UILabel!
    var remainingLivesLabel: UILabel!
    var guessedLabel: UILabel!
    var guessCharField: UITextField!
    var submitButton: UIButton!
    
    var usedLetters = [Character]()
    var word: String = ""
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var remainingLives = 0 {
        didSet {
            remainingLivesLabel.text = "Remaining Lives: \(remainingLives)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    func setupUI() {
        view = UIView()
        view.backgroundColor = .white
        
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.textAlignment = .right
        scoreLabel.text = "Score: 0"
        view.addSubview(scoreLabel)
        
        remainingLivesLabel = UILabel()
        remainingLivesLabel.translatesAutoresizingMaskIntoConstraints = false
        remainingLivesLabel.textAlignment = .right
        remainingLivesLabel.text = "Remaining Lives: 0"
        view.addSubview(remainingLivesLabel)
        
        guessedLabel = UILabel()
        guessedLabel.translatesAutoresizingMaskIntoConstraints = false
        guessedLabel.textAlignment = .center
        guessedLabel.font = UIFont.systemFont(ofSize: 44)
        guessedLabel.text = "?"
        view.addSubview(guessedLabel)
        
        guessCharField = UITextField()
        guessCharField.translatesAutoresizingMaskIntoConstraints = false
        guessCharField.placeholder = "Guess a letter"
        guessCharField.textAlignment = .center
        guessCharField.font = UIFont.systemFont(ofSize: 34)
        guessCharField.isUserInteractionEnabled = false
        view.addSubview(guessCharField)
        
        submitButton = UIButton(type: .system)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.setTitle("SUBMIT", for: .normal)
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        view.addSubview(submitButton)
        
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            remainingLivesLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 20),
            remainingLivesLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            guessedLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            guessedLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            guessedLabel.topAnchor.constraint(equalTo: remainingLivesLabel.bottomAnchor, constant: 100),

            guessCharField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            guessCharField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            guessCharField.topAnchor.constraint(equalTo: guessedLabel.bottomAnchor, constant: 100),
            
            submitButton.topAnchor.constraint(equalTo: guessCharField.bottomAnchor, constant: 100),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            submitButton.heightAnchor.constraint(equalToConstant: 44),
        ])
        
        scoreLabel.backgroundColor = .cyan
        remainingLivesLabel.backgroundColor = .yellow
        guessedLabel.backgroundColor = .purple

    }

    @objc func submitTapped(_ sender: UIButton) {
        guard let guessText = guessCharField.text else { return }
        
    }
}


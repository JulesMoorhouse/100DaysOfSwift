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
    
    var usedLetters = [""]
    var word = ""
    
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
        
        DispatchQueue.global(qos: .userInitiated).async {
            [weak self] in
            self?.loadWord()
        }
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
        guessedLabel.font = UIFont.systemFont(ofSize: 34)
        guessedLabel.text = "?"
        view.addSubview(guessedLabel)
        
        guessCharField = UITextField()
        guessCharField.translatesAutoresizingMaskIntoConstraints = false
        guessCharField.placeholder = "Guess a letter"
        guessCharField.textAlignment = .center
        guessCharField.font = UIFont.systemFont(ofSize: 34)
        guessCharField.backgroundColor = .lightGray
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
    }

    @objc func submitTapped(_ sender: UIButton) {
        guard let guessText = guessCharField?.text?.lowercased() else { return }
        
        guessCharField?.text = ""
        
        if guessText.count != 1 {
            let ac = UIAlertController(title: "Warning", message: "Sorry just enter 1 letter, try again!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            return
        }
        
        if usedLetters.contains(guessText) {
            return
        }
        
        usedLetters.append(guessText)
        
        //let guessLetter = guessText[0]
        var promptWord = ""

        for letter in word {
            let strLetter = String(letter) // string of single character

            // Used letters must be letters the user has previously entered
            // so this will be blank to start with and add these letters as
            // more are correctly guessed.
            // However here it's doing a check and showing it in the guess label.
            // e.g. if the letter is H it will me ??H???
            if usedLetters.contains(strLetter) {
                promptWord += strLetter
            } else {
                promptWord += "?"
            }
            
//            var wordLetter word.index[i, offsetBy: 0]
//            if guessLetter == wordLetter {
//
//            }
        }
        guessedLabel.text = promptWord
        
        if !word.contains(guessText) {
            remainingLives -= 1
        }
        
        var message = ""
        if !promptWord.contains("?") {
            message = "Congratulations you guessed the word correctly!\n\n Try another word"
        }
        
        if remainingLives == 0 {
            message = "Sorry you lost all your lives!\n\n Try another word!"
        }
        
        if message != "" {
            let ac = UIAlertController(title: "Result", message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            
            DispatchQueue.global(qos: .userInitiated).async {
                [weak self] in
                self?.loadWord()
            }
        }
    }
    
    func loadWord() {
        if let levelFileURL = Bundle.main.url(forResource: "words", withExtension: "txt") {
            if let levelContents = try? String(contentsOf: levelFileURL) {
                var lines = levelContents.components(separatedBy: "\n")
                lines.shuffle()
                word = lines[0]
            }
        }
        
        DispatchQueue.main.async {
            [weak self] in
         
            self?.score = 0
            self?.usedLetters.removeAll(keepingCapacity: true)
            self?.guessCharField.text = ""
            self?.guessedLabel.text = ""
            
            guard let word = self?.word else { return }
            
             self?.remainingLives = word.count
            
            for _ in 0..<word.count {
                self?.guessedLabel.text?.append("?")
            }
        }
    }
}


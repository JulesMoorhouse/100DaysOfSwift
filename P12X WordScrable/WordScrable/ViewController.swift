//
//  ViewController.swift
//  WordScrable
//
//  Created by Julian Moorhouse on 29/07/2019.
//  Copyright © 2019 Mindwarp Consultancy Ltd. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    var usedWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(startGame))
        
        if let startWordsUrl = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf:  startWordsUrl) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        load()
    }

    @objc func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    @objc func promptForAnswer() {
    
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] action in // specifies input into closure, ac is a weak reference
            // using ac? as its a weak reference
            guard let answer = ac?.textFields?[0].text?.lowercased() else { return }
            
            guard let title = self?.title else { return }
            if answer == title {
                return
            }
            // also self is weak, ? safely checks that the alert is still there
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    usedWords.insert(answer, at: 0)
                    save()
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with:  .automatic)
                    
                    return
                }
                else
                {
                    showErrorMessage("Word not recognized", "You can't just make them up, you know!")
                }
            }
            else
            {
                showErrorMessage("Word already used", "Be more original!")
            }
        }
        else
        {
            guard let title = title else { return }
            showErrorMessage("Word not possible", "You can't spell that word from \(title.lowercased())")
        }
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            }
            else
            {
                return false
            }
        }
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        
        if word.count < 3 {
            return false
        }
        
        let checker = UITextChecker()
        // scan length of word
        let range = NSRange(location: 0, length: word.utf16.count)
        // scan text for mistakes
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        // if any misspellings were found
        return misspelledRange.location == NSNotFound
    }
    
    func showErrorMessage(_ title: String, _ message: String) {
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func save() {
        let defaults = UserDefaults.standard
        defaults.set(self.title, forKey: "Word")
        defaults.set(usedWords, forKey: "UsedWords")
    }
    
    func load() {
        let defaults = UserDefaults.standard
        self.title = defaults.object(forKey: "Word") as? String ?? ""
        usedWords = defaults.object(forKey:"UsedWords") as? [String] ?? [String]()
        
        if (self.title == "") {
            startGame()
        }
    }
}


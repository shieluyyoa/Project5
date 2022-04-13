//
//  ViewController.swift
//  Project5
//
//  Created by Oscar Lui on 17/2/2022.
//

import UIKit

class ViewController: UITableViewController {
    var allwords:[String] = []
    var usedwords:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        if let startWordsUrl = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsUrl) {
                allwords = startWords.components(separatedBy: "\n")
            }
        }
        if allwords.isEmpty {
        
            allwords = ["silkworm"]
        }
        startGame()
        // D   o any additional setup after loading the view.
    }
    @objc func startGame() {
        title = allwords.randomElement()
        usedwords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedwords.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedwords[indexPath.row]
        return cell
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        
        ac.addTextField()
        
        let submitAction = UIAlertAction(title:"Submit",style: .default) {
            [weak self,weak ac] _ in
            guard let answer = ac?.textFields?[0].text else {
                return
            }
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)

        present(ac,animated: true)
        
    }
    func submit(_ answer:String) {
        let lowerAnswer = answer.lowercased()
    
        if isPossible(word:lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) && lowerAnswer != title {
                    usedwords.insert(lowerAnswer, at: 0)
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                   return
                } else {
                   
                    
                    showErrorMessage("Word not recognized", "You can't just make them up,You know")
                }
            } else {
                showErrorMessage("Word already used", "Be more original")
               
            }
        } else {
            
            showErrorMessage("Word not possible", "You can't spell that word from \(title!.lowercased())")
           
            
        }
        
     }
    
    func isPossible(word:String) -> Bool {
        guard var tempWord = title?.lowercased() else {
            return false
        }
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        return true
    }
    
    func isOriginal(word:String) -> Bool {
        return !usedwords.contains(word)
    }
    
    func isReal(word:String) -> Bool {
        if word.count < 3 {
            return false
        }
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in:word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func showErrorMessage(_ errorTitle:String,_ errorMessage:String) {
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac,animated: true)
    }
}


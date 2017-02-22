//
//  HangmanViewController.swift
//  Hangman
//
//  Created by Fredrick Ohen on 2/13/17.
//  Copyright © 2017 geeoku. All rights reserved.
//

import UIKit

class HangmanViewController: UIViewController {
  
  var linkedInWords = [String]()
  var numberOfIncorrectGuesses: Int = 0
  var guessesRemaining: Int = 6
  var correctHangmanWord = ""
  let userGuessLength: Int = 1
  
  @IBOutlet weak var letterTextField: UITextField!
  @IBOutlet weak var incorrectGuessesLabel: UILabel!
  @IBOutlet weak var guessesRemainingLabel: UILabel!
  @IBOutlet weak var hangmanWordLabel: UILabel!
  @IBOutlet weak var userWonLabel: UILabel!
  @IBOutlet weak var userLostLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    getWordsFromApi()
    letterTextField.delegate = self
    userWonLabel.isHidden = true
    userLostLabel.isHidden = true
    
  }
  
  func getWordsFromApi() {
    let urlString:String = "http://linkedin-reach.hagbpyjegb.us-west-2.elasticbeanstalk.com/words"
    guard let url = URL(string: urlString) else { return }
    URLSession.shared.dataTask(with: url) { (data, response, error) in
        guard error == nil,
            let data = data,
            let dataString = String(data: data, encoding: .utf8)
            else {
                return print(error.debugDescription)
        }

        self.linkedInWords = dataString.components(separatedBy: CharacterSet.newlines)
        self.correctHangmanWord = self.getRandomWord()
        self.hangmanWordLabel.text = self.displayDashesForWord()
      } .resume()
  }
  
  func displayDashesForWord() -> String {
    var dashes = ""
    for _ in 0..<correctHangmanWord.characters.count {
      dashes += "-"
    }
    return dashes
  }
  
  func updateNumberOfGuesses() {
    if numberOfIncorrectGuesses < 6 || guessesRemaining > 1 {
      numberOfIncorrectGuesses += 1
      guessesRemaining -= 1
    }
    userUsedAllGuesses()
  }
  
  func resetNumberOfGuesses() {
    numberOfIncorrectGuesses = -1
    guessesRemaining = 7
    updateGuessesLabels()
  }
  
  func updateGuessesLabels() {
    updateNumberOfGuesses()
    guessesRemainingLabel.text = "\(guessesRemaining)"
    incorrectGuessesLabel.text = "\(numberOfIncorrectGuesses)"
    print("Match not found")
    
    // Image of Hangman body part appears
  }
  
  func userUsedAllGuesses() {
    if numberOfIncorrectGuesses == 6, guessesRemaining == 0 {
      revealHangmanWord()
    }
  }
  
  func checkUserLetter() {
    guard let userGuess = letterTextField.text else { return }
    var correctLetters = [Int]()
    
    // Put the string from guessedAnswerLabel.text
    guard let exampleDisplayAnswer = hangmanWordLabel.text else { return }
    if correctHangmanWord.contains(userGuess) {
      print("Match Found")
      
    // Turn answer into an array of characters
      let answerArray = Array(correctHangmanWord.characters)
      var extraArray = Array(exampleDisplayAnswer.characters)
      
    // run the for loop that checks their character guess against each character in your answer, and saves the index of their guess into the correct letters array
      for char in 0...answerArray.count-1 {
        let newCharacter = String(answerArray[char])
        if userGuess == newCharacter,
            let firstCharacter = userGuess.characters.first {
          correctLetters.append(char)
          extraArray.remove(at: char)
          extraArray.insert(firstCharacter, at: char)
        }
      }
     
      // Turns extraArray into a string and put into guessedAnswerLabel
      let newString = extraArray.map({"\($0)"}).joined(separator: "")
      hangmanWordLabel.text = newString
    } else {
      updateGuessesLabels()
    }
  }
  
  func userWon() {
    userWonLabel.isHidden = false
  }
  
  func userLost() {
    userLostLabel.isHidden = false
  }
 
  func getRandomWord() -> String {
    let randomNumber = generateRandomNumber()
    return linkedInWords[randomNumber]
  }
  
  func generateRandomNumber() -> Int {
    return Int(arc4random_uniform(UInt32(linkedInWords.count)))
  }
  
  func revealHangmanWord() {
    hangmanWordLabel.text = "\(correctHangmanWord)"
    userLost()
  }
  
  func playGame() {
    correctHangmanWord = getRandomWord()
    hangmanWordLabel.text = displayDashesForWord()
  }
  
  
  @IBAction func playButtonPressed(_ sender: Any) {
   // playGame()
  }
  
  @IBAction func getNewWordButtonPressed(_ sender: Any) {
    correctHangmanWord = getRandomWord()
    hangmanWordLabel.text = displayDashesForWord()
    resetNumberOfGuesses()
    userWonLabel.isHidden = true
    userLostLabel.isHidden = true
  }
  
  @IBAction func guessButtonPressed(_ sender: Any) {
    checkUserLetter()
  }
  
  @IBAction func revealButtonPressed() {
    revealHangmanWord()
  }
}


// MARK: UITextFieldDelegate
extension HangmanViewController: UITextFieldDelegate {
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard let text = letterTextField.text else { return true }
    let newLength = text.characters.count + string.characters.count - range.length
    return newLength <= userGuessLength
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    print("User hit return")
    return true
  }
}

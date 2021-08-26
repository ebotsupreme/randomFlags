//
//  ViewController.swift
//  Project2
//
//  Created by Eddie Jung on 7/30/21.
//

import UIKit

class ViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    
    var countries = [String]()
    var score = 0
    var correctAnswer = 0
    var questionsAsked = 0
    var player = [Player]()
    
    var reminderCount = 7
    var repeatReminder = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showScore))
        let scheduleButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(scheduleLocal))
        let registerButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(registerLocal))
//        let scheduleButton = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleLocal))
//        let registerButton = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
        navigationItem.leftBarButtonItems = [scheduleButton, registerButton]
        
        countries = ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
        
        button1.layer.borderWidth = 1
        button2.layer.borderWidth = 1
        button3.layer.borderWidth = 1
        
        button1.layer.borderColor = UIColor.lightGray.cgColor
        button2.layer.borderColor = UIColor.lightGray.cgColor
        button3.layer.borderColor = UIColor.lightGray.cgColor
        
        initializePlayer()
        
        askQuestion()
    }
    
    func initializePlayer() {
        
        let defaults = UserDefaults.standard
        if let savedPlayer = defaults.object(forKey: "player") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                player = try jsonDecoder.decode([Player].self, from: savedPlayer)
            } catch {
                print("Failed to load player.")
            }
        } else {
            player.append(Player(highScore: 0))
        }
    }

    func askQuestion(action: UIAlertAction! = nil) {
        questionsAsked += 1
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        
        title = "\(countries[correctAnswer].uppercased()) - Score: \(score)"
    }
    
    func startOver(action: UIAlertAction! = nil) {
        score = 0
        questionsAsked = 0
        askQuestion()
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        var title: String
        
        UIView.animate(withDuration: 3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 4, options: []) {
            sender.imageView?.transform = CGAffineTransform(scaleX: 2, y: 2)
        } completion: { finished in
            sender.imageView?.transform = .identity
        }
        
        if sender.tag == correctAnswer {
            title = "Correct"
            score += 1
            
        } else {
            title = "Wrong! That's the flag of \(countries[sender.tag].uppercased())"
            if score > 0 { score -= 1 }
        }
        
        if questionsAsked == 5 {
            
            if score > player[0].highScore {
                player[0].highScore = score
                save()
                let ac = UIAlertController(title: "Congratulations!", message: "New high score! \(score)", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Restart", style: .default, handler: startOver))
                present(ac, animated: true)
            } else {
                let ac = UIAlertController(title: title, message: "Your final score is \(score)", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Restart", style: .default, handler: startOver))
                present(ac, animated: true)
            }
                
        } else {
            let ac = UIAlertController(title: title, message: "Your score is \(score)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
            present(ac, animated: true)
        }
        
    }
    
    @objc func showScore() {
        let vc = UIActivityViewController(activityItems: ["Score: \(score)"], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(player) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "player")
        } else {
            print("Failed to load player.")
        }
    }
    
    @objc func registerLocal() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Granted!")
            } else {
                print("Denied!")
            }
        }
    }
    
    @objc func scheduleLocal() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Play reminder"
        content.body = "You haven't played in awhile. Come back and play!"
        content.categoryIdentifier = "alarm"
        content.userInfo = ["userID": "user123"]
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 86400, repeats: repeatReminder)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        let play = UNNotificationAction(identifier: "play", title: "Let's play!", options: .foreground)
        let category = UNNotificationCategory(identifier: "alarm", actions: [play], intentIdentifiers: [])
        
        center.setNotificationCategories([category])
    }
    
}


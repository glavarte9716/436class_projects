//
//  HighController.swift
//  assign3
//
//  Created by Gabe Lavarte on 4/5/20.
//  Copyright © 2020 Gabe Lavarte. All rights reserved.
//

import UIKit

class HighController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var highScoresTableView: UITableView! {
        didSet {
            highScoresTableView.delegate = self
            highScoresTableView.dataSource = self
        }
    }
    
   
    
    //highScores will need to persist.
    lazy var defaults = UserDefaults.standard
    var highScores = [ScoreDatePair]()
    
    //the following 3 functions build the table view.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scoreTableCell", for: indexPath)
        if let currCell = cell as? scoreTableCell {
            
            if !highScores.isEmpty {
                let highScore = highScores[indexPath.row]
                currCell.rank.text = "\(indexPath.row+1))"
                currCell.score.text = "\(highScore.score)"
                currCell.date.text = "\(highScore.date)"
                
                currCell.score.isHidden = false
                currCell.rank.isHidden = false
                currCell.date.isHidden = false
            }
            else {
                currCell.score.isHidden = true
                currCell.rank.isHidden = true
                currCell.date.isHidden = true
            }
    
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //get the score date pairs and put them in highscores.
        let scores = defaults.array(forKey: "scores")
        if let arr = scores as? [ScoreDatePair] {
            highScores = arr
        }
        else {
           highScores = [ScoreDatePair]()
        }
        highScoresTableView.reloadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

class scoreTableCell : UITableViewCell {
    @IBOutlet weak var rank: UILabel!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var date: UILabel!
}

struct ScoreDatePair : Comparable, Codable {
    static func < (lhs: ScoreDatePair, rhs: ScoreDatePair) -> Bool {
        return lhs.score < rhs.score
    }
    
    var score : String
    var date : String
    
}


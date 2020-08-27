//
//  ViewController.swift
//  assign3
//
//  Created by Gabe Lavarte on 4/1/20.
//  Copyright © 2020 Gabe Lavarte. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let CORNER_RAD: CGFloat = 7.0
    //16 buttons representing the 16 tiles of the gameboard
    var buttonDict: [Int:ButtonTile] = Dictionary()
    var toBeDeleted = [ButtonTile]()
   
    
    public struct Index: Hashable {
        static func == (lhs: Index, rhs: Index) -> Bool {
            return lhs.x == rhs.x && lhs.y == rhs.y
        }
        
        let x:Int
        let y:Int
        
        init(_ xIn:Int,_ yIn:Int) {
            x = xIn
            y = yIn
        }
    }
    
    @IBOutlet weak var boardView: BoardView!
    @IBOutlet weak var gameTypeSlider: UISegmentedControl!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var highScores = [ScoreDatePair]()
    lazy var defaults = UserDefaults.standard
    let highController = HighController()
    
    @IBAction func switchActivated(_ sender: UISegmentedControl) {
        if gameTypeSlider.selectedSegmentIndex == 0 {
            isRandomized = true
        }
        else { isRandomized = false}
    }
    
    
    // var buttonMap:[Index:UIButton] = [:]
    var isRandomized:Bool?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let arr = defaults.array(forKey: "scores") as? [ScoreDatePair] {
            highScores = arr
        }
        else {
           highScores = [ScoreDatePair]()
        }
        startNewGame(newGameButton)
    }
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        upButton.layer.cornerRadius = CORNER_RAD
        downButton.layer.cornerRadius = CORNER_RAD
        leftButton.layer.cornerRadius = CORNER_RAD
        rightButton.layer.cornerRadius = CORNER_RAD
        newGameButton.layer.cornerRadius = CORNER_RAD
        
        //Setting is randomized boolean to the value on slider.
        isRandomized = true

        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(collapseUp(_:)))
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(collapseDown(_:)))
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(collapseLeft(_:)))
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(collapseRight(_:)))
        swipeUp.direction = .up
        swipeLeft.direction = .left
        swipeRight.direction = .right
        swipeDown.direction = .down
        boardView.addGestureRecognizer(swipeUp)
        boardView.addGestureRecognizer(swipeDown)
        boardView.addGestureRecognizer(swipeLeft)
        boardView.addGestureRecognizer(swipeRight)
    
    }
    
  
    
    var triplesGame = Triples()
    
    @IBAction func startNewGame(_ sender: UIButton) {
        //calls new game then spawns 4 pieces.
        for button in buttonDict.values {
            button.removeFromSuperview()
        }
        
        buttonDict = Dictionary()
        triplesGame.newgame(rand: isRandomized!)
        triplesGame.spawn()
        triplesGame.spawn()
        triplesGame.spawn()
        triplesGame.spawn()
        updateViewFromBoard()
    }
    
    func updateViewFromBoard() {
        //let board = triplesGame.board
        let score = String(triplesGame.score)
        scoreLabel.text = "Score:  \(score)"
        
        //for all the id's in the tile map, which represents the current board.
        //we need to check if the button dict has it. If not, create it.
        for id in triplesGame.tileMap.keys {
            if buttonDict[id] == nil {
                let tile = triplesGame.tileMap[id]!
                //create the button out of the tile
                let button = ButtonTile(t: tile)
                buttonDict[id] = button
                button.layer.opacity = 0
                button.isHidden = true
                boardView.addSubview(button)
            }
        }
        
        //Then update all the tile row and column info held by the buttons.
        //including the previous tile position
        for id in triplesGame.tileMap.keys {
            if let tile = triplesGame.tileMap[id] {
                buttonDict[id]?.tile = tile
                buttonDict[id]?.previousCol = triplesGame.previousTileMap[id]?.col
                buttonDict[id]?.previousRow = triplesGame.previousTileMap[id]?.row
            }
        }

        
        //then we need to remove the buttons that are no longer on the tile map.
        for buttonID in buttonDict.keys {
            //if the buttonID doesnt relate to a tile id in game,
            //remove the reference to it from the button Dict, but keep the
            //relationship to superview.
            if triplesGame.tileMap[buttonID] == nil {
                buttonDict[buttonID]?.tile.shouldDelete = true
                buttonDict[buttonID] = nil
            }
        }
        
        //ensure the draw and layout gets called.
        boardView.setNeedsDisplay()
        
    }
    
    
    @IBAction func collapseUp(_ sender: UIButton) {
        let boardChanged = triplesGame.collapse(dir: .up)
        if triplesGame.isDone() {
            presentAlert()
            scoreAndPresent()
        }
            
        else if boardChanged {
            triplesGame.spawn()
            updateViewFromBoard()
            if triplesGame.isDone() {
                presentAlert()
                scoreAndPresent()
            }
        }
    }
    

    
    @IBAction func collapseRight(_ sender: UIButton) {
        let boardChanged = triplesGame.collapse(dir: .right)
        if triplesGame.isDone() {
            presentAlert()
            scoreAndPresent()
        }
        else if boardChanged {
            triplesGame.spawn()
            updateViewFromBoard()
            if triplesGame.isDone() {
                presentAlert()
                scoreAndPresent()
            }
        }
    }
    @IBAction func collapseLeft(_ sender: UIButton) {
        let boardChanged = triplesGame.collapse(dir: .left)
        if triplesGame.isDone() {
            presentAlert()
            scoreAndPresent()
        }
        else if boardChanged {
            triplesGame.spawn()
            updateViewFromBoard()
            if triplesGame.isDone() {
                presentAlert()
                scoreAndPresent()
            }
        }
    }
    @IBAction func collapseDown(_ sender: UIButton) {
        let boardChanged = triplesGame.collapse(dir: .down)
        if triplesGame.isDone() {
            presentAlert()
            scoreAndPresent()
        }
        else if boardChanged {
            triplesGame.spawn()
            updateViewFromBoard()
            if triplesGame.isDone() {
                presentAlert()
                scoreAndPresent()
            }
        }
    }
    
    //Used to add the score to the highScore list and present it if top ten. 
    func scoreAndPresent() {
        let score = triplesGame.score
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let stringDate = dateFormatter.string(from: date)
        let scoreAndDate = ScoreDatePair(score: String(score), date: stringDate)
        highScores.append(scoreAndDate)
        let data = try! PropertyListEncoder().encode(highScores)
        defaults.set(data, forKey: "scores")
        let foundData = defaults.data(forKey: "scores")
        self.tabBarController?.selectedIndex = 0
    }
    
    
    func presentAlert() {
        let score = triplesGame.score
        let alert = UIAlertController(title: "Game Over", message: "\(score) points", preferredStyle: .alert )
        alert.message = "\(score) points"
        alert.title = "Game Over"
        alert.addAction(UIAlertAction(title: "Bummer", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //computes the frame for a button tile based on the row and column.
    func buttonFrame(row: Int, col: Int, view: UIView) -> CGRect {
        let boardFrame:CGRect = view.bounds
        let tileLength = boardFrame.width / 4
        let x = CGFloat(col) * tileLength
        let y = CGFloat(row) * tileLength
        return CGRect(x: x, y: y, width: tileLength, height: tileLength)
    }
    

}

class ButtonTile: UIButton {
    var tile = Tile(val: 0, id: 0, row: 0, col: 0, shouldDelete: false)
    var previousRow: Int?
    var previousCol: Int?
    
    func getTile() -> Tile { return tile }
    
    convenience init(t: Tile) {
        self.init()
        tile = t
    }
}


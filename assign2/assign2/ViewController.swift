//
//  ViewController.swift
//  assign2
//
//  Created by Gabe Lavarte on 3/3/20.
//  Copyright © 2020 Gabe Lavarte. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let CORNER_RAD: CGFloat = 7.0
    //16 buttons representing the 16 tiles of the gameboard
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
   
    @IBOutlet weak var gameTypeSlider: UISegmentedControl!
    @IBOutlet var cellCollection: [UIButton]!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var initialMessage: UILabel!
    
    
    @IBAction func switchActivated(_ sender: UISegmentedControl) {
        if gameTypeSlider.selectedSegmentIndex == 0 {
            isRandomized = true
        }
        else { isRandomized = false}
    }
   
    
    var buttonMap:[Index:UIButton] = [:]
    var isRandomized:Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        upButton.layer.cornerRadius = CORNER_RAD
        downButton.layer.cornerRadius = CORNER_RAD
        leftButton.layer.cornerRadius = CORNER_RAD
        rightButton.layer.cornerRadius = CORNER_RAD
        newGameButton.layer.cornerRadius = CORNER_RAD
        for button in cellCollection {
            button.layer.cornerRadius = CORNER_RAD
        }
        
        initialMessage.isHidden = false
        

        //Setting is randomized boolean to the value on slider.
        isRandomized = true
         //When the view is loaded, we should have the button map to begin hashing.
        buttonMap = [Index(0,0) : cellCollection[0],
               Index(0,1) : cellCollection[1],
               Index(0,2) : cellCollection[2],
               Index(0,3) : cellCollection[3],
               Index(1,0) : cellCollection[4],
               Index(1,1) : cellCollection[5],
               Index(1,2) : cellCollection[6],
               Index(1,3) : cellCollection[7],
               Index(2,0) : cellCollection[8],
               Index(2,1) : cellCollection[9],
               Index(2,2) : cellCollection[10],
               Index(2,3) : cellCollection[11],
               Index(3,0) : cellCollection[12],
               Index(3,1) : cellCollection[13],
               Index(3,2) : cellCollection[14],
               Index(3,3) : cellCollection[15]]
               // Do any additional setup after loading the view.
        updateViewFromBoard()
                
               
    }
    
    var triplesGame = Triples()

    @IBAction func startNewGame(_ sender: UIButton) {
        //calls new game then spawns 4 pieces.
        initialMessage.isHidden = true
        triplesGame.newgame(rand: isRandomized!)
        triplesGame.spawn()
        triplesGame.spawn()
        triplesGame.spawn()
        triplesGame.spawn()
        updateViewFromBoard()
    }
    
    func updateViewFromBoard() {
        let board = triplesGame.board
        let score = String(triplesGame.score)
        scoreLabel.text = "Score:  \(score)"
        for x in 0...3 {
            for y in 0...3 {
                let currentTile = board[x][y]
                let button = buttonMap[Index(x,y)]
                if currentTile != 0 {
                    button?.isHidden = false
                    button?.setTitle(String(currentTile), for: UIControl.State.normal)
                    if currentTile == 2 {
                        button?.backgroundColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
                        button?.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: UIControl.State.normal)
                    }
                    else if currentTile == 1 {
                        button?.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
                        button?.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: UIControl.State.normal)
                    }
                    else { button?.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                        button?.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: UIControl.State.normal)
                    }
                }
                else {
                   button?.isHidden = true
                }
            }
        }
    }
    
    @IBAction func collapseUp(_ sender: UIButton) {
        let boardChanged = triplesGame.collapse(dir: .up)
        if triplesGame.isDone() {
            presentAlert()
        }
            
        else if boardChanged {
            triplesGame.spawn()
            updateViewFromBoard()
            if triplesGame.isDone() {
                presentAlert()
            }
        }
        
    }
    @IBAction func collapseRight(_ sender: UIButton) {
       let boardChanged = triplesGame.collapse(dir: .right)
        if triplesGame.isDone() {
            presentAlert()
        }
        else if boardChanged {
            triplesGame.spawn()
            updateViewFromBoard()
            if triplesGame.isDone() {
                presentAlert()
            }
        }
    }
    @IBAction func collapseLeft(_ sender: UIButton) {
       let boardChanged = triplesGame.collapse(dir: .left)
        if triplesGame.isDone() {
            presentAlert()
        }
        else if boardChanged {
            triplesGame.spawn()
            updateViewFromBoard()
            if triplesGame.isDone() {
                presentAlert()
            }
        }
    }
    @IBAction func collapseDown(_ sender: UIButton) {
      let boardChanged = triplesGame.collapse(dir: .down)
        if triplesGame.isDone() {
            presentAlert()
        }
        else if boardChanged {
            triplesGame.spawn()
            updateViewFromBoard()
            if triplesGame.isDone() {
                presentAlert()
            }
        }
    }
    
    func presentAlert() {
        let score = triplesGame.score
        let alert = UIAlertController(title: "Game Over", message: "\(score) points", preferredStyle: .alert )
        alert.message = "\(score) points"
        alert.title = "Game Over"
        alert.addAction(UIAlertAction(title: "Bummer", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    

}


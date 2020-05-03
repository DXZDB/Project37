//
//  ViewController.swift
//  Project37
//
//  Created by Dan on 5/1/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import AVFoundation //N1
import UIKit
import WatchConnectivity //P1

class ViewController: UIViewController, WCSessionDelegate { //P3
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    } // P4 applied via Precompiler fix...
    
    @IBOutlet var cardContainer: UIView!
    @IBOutlet var gradientView: GradientView!
    var music: AVAudioPlayer! //N2
    var lastMessage: CFAbsoluteTime = 0 //P4
    
    
    //WTF when you delete something from a connection to IB - it connects to 4 lines down!
    var allCards = [CardViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createParticles() //L2
        loadCards()//C2
        playMusic()//N4
        
        view.backgroundColor = UIColor.red
        UIView.animate(withDuration: 20, delay: 0, options: [.allowUserInteraction, .autoreverse, .repeat], animations: {self.view.backgroundColor = UIColor.blue}) //J
        
        if (WCSession.isSupported()) {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }//P2
    }
    
    @objc func loadCards() {
        
        for card in allCards {
            card.view.removeFromSuperview()
            card.removeFromParent()
        }//C3
        
        view.isUserInteractionEnabled = true //G
        
        allCards.removeAll(keepingCapacity: true)
        
        //create an array of card positions
        let positions = [
            CGPoint(x: 75, y: 85),
            CGPoint(x: 185, y: 85),
            CGPoint(x: 295, y: 85),
            CGPoint(x: 405, y: 85),
            CGPoint(x: 75, y: 235),
            CGPoint(x: 185, y: 235),
            CGPoint(x: 295, y: 235),
            CGPoint(x: 405, y: 235),
            ]
        
        //load and unwrap our Zener card images
        let circle = UIImage(named: "cardCircle")!
        let cross = UIImage(named: "cardCross")!
        let lines = UIImage(named: "cardLines")!
        let square = UIImage(named: "cardSquare")!
        let star = UIImage(named: "cardStar")!
        
        //create an array of images, one for each card, then shuffle it
        var images = [circle, circle, cross, cross, lines, lines, square, star]
        images.shuffle()
        
        for (index, position) in positions.enumerated() {
            //loop over each card position and create a new card view controller
            let card = CardViewController()
            card.delegate = self
            
            //use view controller containment and also add the card's view to our cardContainer view
            addChild(card)
            cardContainer.addSubview(card.view)
            card.didMove(toParent: self)
            
            //position the card appropirately, then give it an image from our array
            card.view.center = position
            card.front.image = images[index]
            
            // if we just gave the new card the star image, mark this as the correct answer
            if card.front.image == star {
                card.isCorrect = true
            }
            
            //add the new card view controller to our array for easier tracking
            allCards.append(card)
            
        } //C
        
    }

    func cardTapped(_ tapped: CardViewController) {
        guard view.isUserInteractionEnabled == true else {
            return
        }
        view.isUserInteractionEnabled = false
        
        for card in allCards {
            if card == tapped {
                card.wasTapped()
                card.perform(#selector(card.wasntTapped), with: nil, afterDelay: 1)
            } else {
                card.wasntTapped()
            }
        }
        perform(#selector(loadCards), with: nil, afterDelay: 2)
        //F
    }
    
    func createParticles() {
        let particleEmitter = CAEmitterLayer()
        
        particleEmitter.emitterPosition = CGPoint(x: view.frame.width / 2.0, y: -50)
        particleEmitter.emitterShape = .line
        particleEmitter.emitterSize = CGSize(width: view.frame.width, height: 1)
        particleEmitter.renderMode = .additive
        
        let cell = CAEmitterCell()
        cell.birthRate = 2
        cell.lifetime = 5.0
        cell.velocity = 100
        cell.velocityRange = 50
        cell.emissionLongitude = .pi
        cell.spinRange = 5
        cell.scale = 0.5
        cell.scaleRange = 0.25
        cell.color = UIColor(white: 1, alpha: 0.6).cgColor
        cell.alphaSpeed = -0.025
        cell.contents = UIImage(named: "particle")?.cgImage
        particleEmitter.emitterCells = [cell]
        
        gradientView.layer.addSublayer(particleEmitter)
    } //L
    
    func playMusic() {
        if let musicURL = Bundle.main.url(forResource: "PhantomFromSpace", withExtension: "mp3") {
            if let audioPlayer = try? AVAudioPlayer(contentsOf: musicURL) {
                music = audioPlayer
                music.numberOfLoops = -1
                music.play()
            }
        }
    } //N3
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard let touch = touches.first else { return }
            let location = touch.location(in: cardContainer)
            for card in allCards {
                if card.view.frame.contains(location) {
                    if view.traitCollection.forceTouchCapability == .available {
                        if touch.force == touch.maximumPossibleForce {
                            card.front.image = UIImage(named: "cardStar")
                            card.isCorrect = true
                        }
                    }
                    if card.isCorrect {
                        sendWatchMessage() //Q2
                    }
                }
            }
        } //O

    func sendWatchMessage() {
        let currentTime = CFAbsoluteTimeGetCurrent()
        //if less than half a second has passed, bailout
        if lastMessage + 0.5 > currentTime { return }
        
        //send a message to the watch if it is reachable
        if (WCSession.default.isReachable) {
            //this is a meaningless message, but it's enough for our purposes
            let message = ["Message": "Hello"]
            WCSession.default.sendMessage(message, replyHandler: nil)
        }
        //update our rate limiting property
        lastMessage = CFAbsoluteTimeGetCurrent()
    } //Q1
}


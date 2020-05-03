//
//  CardViewController.swift
//  Project37
//
//  Created by Dan on 5/1/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

class CardViewController: UIViewController {
    
    weak var delegate: ViewController!
    
    var front: UIImageView!
    var back: UIImageView!
    
    var isCorrect = false //A

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.bounds = CGRect(x: 0, y: 0, width: 100, height: 140)
        front = UIImageView(image: UIImage(named: "cardBack"))
        back = UIImageView(image: UIImage(named: "cardBack"))
        
        view.addSubview(front)
        view.addSubview(back)
        
        front.isHidden = true
        back.alpha = 0
        
        UIView.animate(withDuration: 0.2) {
            self.back.alpha = 1 //cards are NOT see through!

        } //B
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        back.isUserInteractionEnabled = true
        back.addGestureRecognizer(tap) //D
        
        perform(#selector(wiggle), with: nil, afterDelay: 1) //M2
        
        }
    
    @objc func cardTapped() {
        delegate.cardTapped(self)
    }//E
    
    @objc func wasntTapped() {
        UIView.animate(withDuration: 0.7) {
            self.view.transform = CGAffineTransform(scaleX: 0.00001, y: 0.00001)
            self.view.alpha = 0 //H
        }
    }
    
    @objc func wasTapped() {
        UIView.transition(with: view, duration: 0.7, options: [.transitionFlipFromRight], animations:
            {[unowned self] in
                self.back.isHidden = true
                self.front.isHidden = false
        }) //I
    }
    
    @objc func wiggle() {
        if Int.random(in: 0...3) == 1 {
            UIView.animate(withDuration: 0.2, delay: 0, options: .allowUserInteraction, animations: { self.back.transform = CGAffineTransform(scaleX: 1.01, y: 1.01)})
            {_ in
                self.back.transform = CGAffineTransform.identity
            }
            
            perform(#selector(wiggle), with: nil, afterDelay: 8 )
        } else {
            perform(#selector(wiggle), with: nil, afterDelay: 2 )
        }
    } //M
    
}

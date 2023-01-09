//
//  CoordinateVC.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/09.
//

import UIKit

class CoordinateVC: UIViewController {

    @IBOutlet var closeButton: UIButton!
    @IBOutlet var moreButton: UIButton!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var timeSublabel: UILabel!

    @IBOutlet var locationImageView: UIImageView!
    @IBOutlet var locationLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        setupLabels()
        startTimer()
    }
    
    func setupButtons() {
        closeButton.addAction(.init(handler: { [self] _ in
            closeButtonDidPressed()
        }), for: .touchUpInside)
        moreButton.addAction(.init(handler: { [self] _ in
            moreButtonDidPressed()
        }), for: .touchUpInside)
    }
    
    func setupLabels() {
        nameLabel.text = "Mei"
        timeSublabel.text = "left to connect"
    }
    
    func startTimer() {
        let minsLeft = 3
        let secsLeft = 34
        timeLabel.text = String(minsLeft) + "m " + String(secsLeft) + "s"
    }
    
    //MARK: - Interaction
    
    func closeButtonDidPressed() {
        dismiss(animated: true)
        //TODO: prompt the user how their experience was
    }
    
    func moreButtonDidPressed() {
        //present VC asking if they'd like to block the user
        
    }

}

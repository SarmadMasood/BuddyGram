//
//  ZoomedViewController.swift
//  BuddyGram
//
//  Created by Mac OSX on 5/10/20.
//  Copyright © 2020 Mac OSX. All rights reserved.
//

import UIKit

class ZoomedViewController: UIViewController {
    
    @IBOutlet weak var detailImageView: UIImageView!
    
    var image: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailImageView.image = image
        navigationItem.title = "Photo"
    }

}

//extension ZoomedViewController: ZoomingViewController{
//    func zoomingImageView(forTransition: ZoomTransitionDelegate) -> UIImageView? {
//        return detailImageView
//    }
//    
//    func zoomingBackgroundView(forTransition: ZoomTransitionDelegate) -> UIView? {
//        return nil
//    }
//    
//}

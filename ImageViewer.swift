//
//  ImageViewer.swift
//  map
//
//  Created by Hosam Elnabawy on 4/30/20.
//  Copyright © 2020 Hosam Elnabawy. All rights reserved.
//

import UIKit

class ImageViewer: UIViewController {

    
    @IBOutlet weak var imageView: UIImageView!
    var seenImage: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let seenImage = seenImage {
            imageView.image = seenImage
        }
        // Do any additional setup after loading the view.
    }
    
    func initData(for image: UIImage) {
        self.seenImage = image
    }

}

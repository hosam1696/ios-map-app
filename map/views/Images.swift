//
//  Images.swift
//  map
//
//  Created by Hosam Elnabawy on 4/29/20.
//  Copyright © 2020 Hosam Elnabawy. All rights reserved.
//

import UIKit

class Images: UIView {

    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    
    private func setup() {
//        layer.cornerRadius = 40
        backgroundColor = .white
//        layer.cornerCurve
//        clipsToBounds = true
        
        let v = UIView(frame: CGRect(x: (frame.size.width / 2) - 30, y: 16, width: 60, height: 6))
        v.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        v.layer.cornerRadius = 3
        addSubview(v)
    }


}

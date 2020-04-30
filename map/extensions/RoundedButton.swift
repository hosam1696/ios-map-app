//
//  RoundedButton.swift
//  map
//
//  Created by Hosam Elnabawy on 4/28/20.
//  Copyright © 2020 Hosam Elnabawy. All rights reserved.
//

import UIKit

enum ButtonSizes: String {
    case small
    case medium
    case large
}

@IBDesignable
class RoundedButton: UIButton {
     
    var type = ButtonSizes.medium
    
    @IBInspectable
    var buttonSize: String {
        set {
            let type: ButtonSizes = ButtonSizes(rawValue: newValue) ?? .medium
            switch type {
                case .medium:
                    size = 44
                case .small:
                    size = 32
                case .large:
                    size = 50
            }
        }
        
        get {
            return type.rawValue
        }
    }
    
    var size: Int = 40 {
        
        didSet {
            setup()
        }
    }
    
    
    // MARK: - Initialization
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - Drawing
    private func setup() {
        frame.size = CGSize(width: CGFloat(size), height: CGFloat(size))
        layer.cornerRadius = CGFloat(size / 2)
        
        
        clipsToBounds = true
        layer.borderWidth = 3
        layer.borderColor = #colorLiteral(red: 0.7884378433, green: 0.2641938031, blue: 0.3239899874, alpha: 1)
    }
    
    
}


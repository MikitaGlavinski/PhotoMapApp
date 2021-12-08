//
//  CustomSearchBar.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/8/21.
//

import UIKit

@IBDesignable
class CustomSearchBar: UIView {
    
    
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet var widthConstraint: NSLayoutConstraint!
    @IBOutlet var rightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textField: UITextField!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setupView() {
        guard let view = loadFromNib(nibName: "CustomSearchBar") else { return }
        view.frame = bounds
        addSubview(view)
        
        view.layer.cornerRadius = 7
        rightConstraint.isActive = false
        widthConstraint.isActive = true
        leftConstraint.constant = bounds.midX - 65
        
        textField.delegate = self
    }
    
    func animateActive() {
        UIView.animate(withDuration: 0.3) {
            self.rightConstraint.isActive = true
            self.widthConstraint.isActive = false
            self.leftConstraint.constant = 10
            self.layoutIfNeeded()
        }
    }
    
    func animateUnactive() {
        UIView.animate(withDuration: 0.3) {
            self.rightConstraint.isActive = false
            self.widthConstraint.isActive = true
            self.leftConstraint.constant = self.bounds.midX - 95 / 2
            self.layoutIfNeeded()
        }
    }
}

extension CustomSearchBar: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateActive()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateUnactive()
    }
}

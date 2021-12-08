//
//  TimeLineCell.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/8/21.
//

import UIKit

protocol TimeLineCellDelegate: AnyObject {
    func loadImage(url: String, completion: @escaping (UIImage) -> ())
}

class TimeLineCell: UITableViewCell {
    
    weak var delegate: TimeLineCellDelegate!
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    func configureCell(with model: TimeLineCellModel) {
        infoLabel.text = model.infoLabelText
        dateLabel.text = model.secondaryLabelText
        activityIndicator.startAnimating()
        delegate.loadImage(url: model.imageUrl) { image in
            self.photoImageView.image = image
            self.activityIndicator.stopAnimating()
        }
    }
}

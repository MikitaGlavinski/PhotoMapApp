//
//  PhotoScreenViewController.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/7/21.
//

import UIKit

protocol PhotoScreenViewInput: AnyObject {
    func setupUI(with model: PhotoCardModel)
}

class PhotoScreenViewController: UIViewController {
    
    var viewModel: PhotoScreenViewModelProtocol!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad()
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
    }
}

extension PhotoScreenViewController: PhotoScreenViewInput {
    
    func setupUI(with model: PhotoCardModel) {
        imageView.image = model.image
        textLabel.text = model.text
        dateLabel.text = model.stringDate
    }
}

extension PhotoScreenViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    private var scrollViewVisibleSize: CGSize {
        let contentInset = scrollView.contentInset
        let scrollViewSize = scrollView.bounds.standardized.size
        let width = scrollViewSize.width - contentInset.left - contentInset.right
        let height = scrollViewSize.height - contentInset.top - contentInset.bottom
        return CGSize(width:width, height:height)
    }
    
    private var scrollViewCenter: CGPoint {
        let scrollViewSize = self.scrollViewVisibleSize
        return CGPoint(x: scrollViewSize.width / 2.0,
                       y: scrollViewSize.height / 2.0)
    }
    
    private func centerScrollViewContents() {
        
        let scrollViewSize = scrollViewVisibleSize
        
        var imageCenter = CGPoint(x: scrollView.contentSize.width / 2.0,
                                  y: scrollView.contentSize.height / 2.0)
        
        let center = scrollViewCenter
        
        if scrollView.contentSize.width < scrollViewSize.width {
            imageCenter.x = center.x
        }
        
        if scrollView.contentSize.height < scrollViewSize.height {
            imageCenter.y = center.y
        }
        
        imageView.center = imageCenter
    }
}

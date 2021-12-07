//
//  ImageScrollView.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/7/21.
//

import UIKit

class ImageScrollView: UIScrollView, UIScrollViewDelegate {
    
    private var imageView: UIImageView! = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        delegate = self
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        decelerationRate = .fast
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        centerImage()
    }
    
    func setImage(image: UIImage) {
        imageView.removeFromSuperview()
        imageView = nil
        
        imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        configurate(imageSize: image.size)
    }
    
    private func configurate(imageSize: CGSize) {
        contentSize = imageSize
        setMaxMinZoomScale()
        
        self.zoomScale = self.minimumZoomScale
    }
    
    private func setMaxMinZoomScale() {
        let boundSize = self.bounds.size
        let imageSize = imageView.bounds.size
        
        let xScale = boundSize.width / imageSize.width
        let yScale = boundSize.height / imageSize.height
        let minScale = min(xScale, yScale)
        
        var maxScale: CGFloat = 1.0
        if minScale < 0.1 {
            maxScale = 0.3
        }
        if minScale >= 0.1 && minScale <= 0.5 {
            maxScale = 0.7
        }
        if minScale >= 0.5 {
            maxScale = max(1.0, minScale)
        }
        self.minimumZoomScale = minScale
        self.maximumZoomScale = maxScale
    }
    
    private func centerImage() {
        let boundsSize = self.bounds.size
        var frameToCenter = imageView.frame
        
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
        } else {
            frameToCenter.origin.x = 0
        }
        frameToCenter.origin.y = 0
        imageView.frame = frameToCenter
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.centerImage()
    }
    
}

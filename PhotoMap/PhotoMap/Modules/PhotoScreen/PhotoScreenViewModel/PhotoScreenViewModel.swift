//
//  PhotoScreenViewModel.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/7/21.
//

import Foundation

protocol PhotoScreenViewModelProtocol: AnyObject {
    func viewDidLoad()
}

class PhotoScreenViewModel {
    weak var view: PhotoScreenViewInput!
    var coordinator: PhotoScreenCoordinatorDelegate!
    
    var photoModel: PhotoCardModel
    
    init(photoModel: PhotoCardModel) {
        self.photoModel = photoModel
    }
}

extension PhotoScreenViewModel: PhotoScreenViewModelProtocol {
    
    func viewDidLoad() {
        view.setupUI(with: photoModel)
    }
}

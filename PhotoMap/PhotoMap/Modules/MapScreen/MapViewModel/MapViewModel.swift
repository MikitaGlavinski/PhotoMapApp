//
//  MapViewModel.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/2/21.
//

import Foundation

protocol MapViewModelProtocol: AnyObject {
    
}

class MapViewModel {
    weak var view: MapViewInput!
    var coordinator: MapCoordinatorDelegate!
}

extension MapViewModel: MapViewModelProtocol {
    
}

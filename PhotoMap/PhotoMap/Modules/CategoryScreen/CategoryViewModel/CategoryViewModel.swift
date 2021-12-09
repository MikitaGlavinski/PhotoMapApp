//
//  CategoryViewModel.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/9/21.
//

import Foundation

protocol CategoryViewModelProtocol: AnyObject {
    func viewDidLoad()
    func saveCategories(categories: [CategoryModel])
}

class CategoryViewModel {
    weak var view: CategoryViewInput!
    var coordinator: CategoryCoordinatorDelegate!
}

extension CategoryViewModel: CategoryViewModelProtocol {
    
    func viewDidLoad() {
        let categories = SecureStorageService.shared.obtainCategories()
        view.setCategories(categories: categories)
    }
    
    func saveCategories(categories: [CategoryModel]) {
        SecureStorageService.shared.saveCategories(categories: categories)
        coordinator.goBack()
    }
}

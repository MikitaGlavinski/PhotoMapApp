//
//  SecureStorageService.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/2/21.
//

import Foundation

protocol SecureStorageServiceProtocol {
    func obtainToken() -> String?
    func saveToken(token: String)
    func saveCategories(categories: [CategoryModel])
    func obtainCategories() -> [CategoryModel]
}

class SecureStorageService: SecureStorageServiceProtocol {
    
    static let shared: SecureStorageServiceProtocol = SecureStorageService()
    private init() {}
    
    private let storage = UserDefaults.standard
    
    func obtainToken() -> String? {
        storage.string(forKey: "token")
    }
    
    func saveToken(token: String) {
        storage.setValue(token, forKey: "token")
    }
    
    func saveCategories(categories: [CategoryModel]) {
        guard let data = try? JSONEncoder().encode(categories) else { return }
        storage.setValue(data, forKey: "categories")
    }
    
    func obtainCategories() -> [CategoryModel] {
        guard
            let data = storage.data(forKey: "categories"),
            let categories = try? JSONDecoder().decode([CategoryModel].self, from: data)
        else {
            return [
                CategoryModel(title: "NATURE", isSelected: false),
                CategoryModel(title: "FRIENDS", isSelected: false),
                CategoryModel(title: "DEFAULT", isSelected: false)
            ]
        }
        return categories
    }
}

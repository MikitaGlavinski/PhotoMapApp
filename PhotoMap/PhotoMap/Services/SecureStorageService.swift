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
}

//
//  FirebaseService.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/6/21.
//

import Foundation
import Firebase

protocol FirebaseServiceProtocol {
    func setDataAt(path: String, data: [String: Any], completion: @escaping (Result<String, Error>) -> ())
    func getUserPhotos(completion: @escaping (Result<[PhotoRestModel], Error>) -> ())
    func uploadImage(data: Data, completion: @escaping (Result<String, Error>) -> ())
}

class FirebaseService: FirebaseServiceProtocol {
    
    static let shared: FirebaseServiceProtocol = FirebaseService()
    
    private init() {}
    
    private let queue = DispatchQueue(label: "FirebaseServiceQueue", qos: .background)
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage().reference()
    
    private func getListData<T: Decodable>(path: String, type: T.Type, completion: @escaping (Result<[T], Error>) -> ()) {
        db.collection(path).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            var items = [T]()
            for document in snapshot?.documents ?? [] {
                guard let item = try? DictionaryDecoder().decode(data: document.data(), type: type) else {
                    completion(.failure(NetworkError.unrecognized))
                    return
                }
                items.append(item)
            }
            completion(.success(items))
        }
    }
    
    func setDataAt(path: String, data: [String: Any], completion: @escaping (Result<String, Error>) -> ()) {
        db.document(path).setData(data) { error in
            self.queue.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success("success"))
            }
        }
    }
    
    func getUserPhotos(completion: @escaping (Result<[PhotoRestModel], Error>) -> ()) {
        guard let token = SecureStorageService.shared.obtainToken() else { return }
        getListData(path: token, type: PhotoRestModel.self, completion: completion)
    }
    
    func uploadImage(data: Data, completion: @escaping (Result<String, Error>) -> ()) {
        let uploadRef = storage.child(UUID().uuidString)
        uploadRef.putData(data, metadata: nil) { metadata, error in
            self.queue.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                uploadRef.downloadURL { url, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    guard let url = url else {
                        completion(.failure(NetworkError.noData))
                        return
                    }
                    completion(.success(url.absoluteString))
                }
            }
        }
    }
}

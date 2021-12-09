//
//  TimeLineViewModel.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/8/21.
//

import UIKit

protocol TimeLineViewModelProtocol: AnyObject {
    func viewDidLoad()
    func loadImage(url: String, completion: @escaping (UIImage) -> ())
    func showImage(cellModel: TimeLineCellModel)
    func showCategories()
    func setSelectedCategories()
}

class TimeLineViewModel {
    weak var view: TimeLineViewInput!
    var coordinator: TimeLineCoordinatorDelegate!
    
    private var photoRestModels = [PhotoRestModel]()
}

extension TimeLineViewModel: TimeLineViewModelProtocol {
    
    func setSelectedCategories() {
        let categories = SecureStorageService.shared.obtainCategories()
        var selectedCategories = [Category]()
        for category in categories {
            if category.isSelected {
                guard let selectedCategory = Category.init(rawValue: category.title) else { return }
                selectedCategories.append(selectedCategory)
            }
        }
        view.setSelectedCategories(categories: selectedCategories)
    }
    
    func viewDidLoad() {
        FirebaseService.shared.getUserPhotos { result in
            switch result {
            case .success(let restModels):
                self.photoRestModels = restModels
                let cellModels = restModels.compactMap({TimeLineCellModel(photoRestModel: $0)}).sorted(by: {$0.date > $1.date})
                var sections = [TimeLineSection]()
                for cell in cellModels {
                    guard let index = sections.firstIndex(where: {$0.title == cell.sectionTitle}) else {
                        sections.append(TimeLineSection(title: cell.sectionTitle, rows: [cell]))
                        continue
                    }
                    sections[index].rows.append(cell)
                }
                self.view.setupSectioList(sections: sections)
            case .failure(let error):
                self.view.showError(error: error)
            }
        }
    }
    
    func loadImage(url: String, completion: @escaping (UIImage) -> ()) {
        NetworkService.shared.loadImageFrom(url: url, completion: completion) { error in
            self.view.showError(error: error)
        }
    }
    
    func showImage(cellModel: TimeLineCellModel) {
        guard let index = photoRestModels.firstIndex(where: {$0.id == cellModel.id}) else { return }
        let photoCardModel = PhotoCardModel(restModel: photoRestModels[index])
        coordinator.showImage(model: photoCardModel)
    }
    
    func showCategories() {
        coordinator.showCategories()
    }
}

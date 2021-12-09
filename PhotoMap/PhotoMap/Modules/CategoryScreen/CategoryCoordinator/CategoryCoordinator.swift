//
//  CategoryCoordinator.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/9/21.
//

import UIKit

protocol CategoryCoordinatorDelegate: AnyObject {
    func goBack()
}

class CategoryCoordinator: Coordinator {
    
    private weak var rootNavigationController: UINavigationController?
    private var childCoordinators = [Coordinator]()
    
    var onEnd: (() -> ())!
    
    init(rootNavigationController: UINavigationController) {
        self.rootNavigationController = rootNavigationController
    }
    
    func start() {
        guard let rootNavigationController = rootNavigationController else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let view = storyboard.instantiateViewController(withIdentifier: "Category") as? CategoryViewController else { return }
        let viewModel = CategoryViewModel()
        view.viewModel = viewModel
        viewModel.view = view
        viewModel.coordinator = self
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .fade
        rootNavigationController.view.layer.add(transition, forKey: nil)
        rootNavigationController.pushViewController(view, animated: false)
    }
    
    func add(childCoordinator: Coordinator) {
        childCoordinators.append(childCoordinator)
    }
    
    func remove(childCoordinator: Coordinator) {
        guard let index = childCoordinators.firstIndex(where: {$0 === childCoordinator}) else { return }
        childCoordinators.remove(at: index)
    }
    
    
}

extension CategoryCoordinator: CategoryCoordinatorDelegate {
    
    func goBack() {
        onEnd()
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .fade
        rootNavigationController?.view.layer.add(transition, forKey: nil)
        rootNavigationController?.popViewController(animated: false)
    }
}

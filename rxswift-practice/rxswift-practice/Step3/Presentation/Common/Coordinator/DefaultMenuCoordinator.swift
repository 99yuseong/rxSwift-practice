//
//  DefaultMenuCoordinator.swift
//  rxswift-practice
//
//  Created by 남유성 on 2023/04/07.
//

import UIKit

protocol MenuCoordinator: Coordinator {
    func showOrderViewController(with orderedMenu: [Menu])
}

final class DefaultMenuCoordinator: MenuCoordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType { .menu }
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let service = URLSessionNetworkService()
        let repository = MenuRepository(urlSessionSerivce: service)
        let useCase = MenuUseCase(menuRepository: repository)
        let viewModel = MenuViewModel(coordinator: self, MenuUseCase: useCase)
        
        let menuViewController = MenuViewController()
        menuViewController.viewModel = viewModel
        self.navigationController.pushViewController(menuViewController, animated: true)
    }
    
    func showOrderViewController(with orderedMenu: [Menu]) {
        let viewModel = OrderViewModel(coordinator: self)
        
        let orderViewController = OrderViewController()
        orderViewController.orderedMenus = orderedMenu
        orderViewController.viewModel = viewModel
        self.navigationController.pushViewController(orderViewController, animated: true)
    }
}

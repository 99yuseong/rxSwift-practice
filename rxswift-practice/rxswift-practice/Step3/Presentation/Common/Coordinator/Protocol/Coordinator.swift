//
//  Coordinator.swift
//  rxswift-practice
//
//  Created by 남유성 on 2023/04/06.
//

import UIKit

protocol CoordinatorFinishDelegate: AnyObject {
    func coordinatorDidFinish(childCoordinator: Coordinator)
}

enum CoordinatorType {
    case app, login, join, tab, menu
    case home, search, story, profile
    case setting, detail
}

protocol Coordinator: AnyObject {
    var finishDelegate: CoordinatorFinishDelegate? { get set } // 부모 설정 대신 delegate로 전달
    
    var navigationController: UINavigationController { get set }
    var childCoordinators: [Coordinator]  { get set }
    var type: CoordinatorType { get }
    
    init(navigationController: UINavigationController)
    
    func start()
    func finish()
    func findCoordinator(type: CoordinatorType) -> Coordinator?
}

extension Coordinator {
    func finish() {
        childCoordinators.removeAll()
        finishDelegate?.coordinatorDidFinish(childCoordinator: self) // 부모 Coordinator에게 finish 상태 Delegate로 전달
    }
    
    func findCoordinator(type: CoordinatorType) -> Coordinator? {
        var stack: [Coordinator] = [self]
        
        while !stack.isEmpty {
            let currentCoordinator = stack.removeLast()
            if currentCoordinator.type == type {
                return currentCoordinator
            }
            currentCoordinator.childCoordinators.forEach { child in
                stack.append(child)
            }
        }
        return nil
    }
}



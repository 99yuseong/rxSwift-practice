//
//  DefaultAppCoordinator.swift
//  rxswift-practice
//
//  Created by 남유성 on 2023/04/07.
//

import UIKit

final class DefaultAppCoordinator: Coordinator {

    weak var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType { .app }
    
    func start() {
        // 유저 방문 여부 / 로그인 여부 / UserDefaults.standard.bool? isLoggedIn에 따라 Flow 결정
        // Default app에서는 Coordinator로 연결시켜주는 root 작업만
        showMenuFlow()
    }
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.setNavigationBarHidden(true, animated: true)
    }
    
    func showMenuFlow() {
        // 이동할 Coordinator 생성
        // delegate = self 부모 설정
        // Coordinator.start로 시작
        let menuCoordinator = DefaultMenuCoordinator(navigationController: self.navigationController)
        menuCoordinator.finishDelegate = self
        menuCoordinator.start()
        childCoordinators.append(menuCoordinator)
        
    }
    
}

extension DefaultAppCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        
        // type이 같은 childeCoordinator 모두 childCoordinators에서 제거
        self.childCoordinators = self.childCoordinators.filter({ $0.type != childCoordinator.type })
        self.navigationController.view.backgroundColor = .systemBackground
        // navigationController stack에 있는 VC 모두 제거
        self.navigationController.viewControllers.removeAll()
        
        // 종료한 Coordinator type에 따라 화면 이동
        // login Coordinator 종료 -> (로그인됨) -> main Coordinator Flow로 연결
        // main Coordinator 종료 -> (로그아웃됨) -> login Coordinator Flow로 연결
        switch childCoordinator.type {
        default:
            break
        }
        
    }
}

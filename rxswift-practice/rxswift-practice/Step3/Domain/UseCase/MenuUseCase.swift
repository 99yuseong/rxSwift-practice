//
//  MenuUseCase.swift
//  rxswift-practice
//
//  Created by 남유성 on 2023/04/03.
//

import Foundation
import RxSwift

final class MenuUseCase: MenuUseCaseProtocol {
    
    private var menus: PublishSubject<[Menu]> = PublishSubject<[Menu]>()
    private var menuRepository: MenuRepositoryProtocol
    private let disposeBag = DisposeBag()
    
    init(menuRepository: MenuRepositoryProtocol) {
        self.menuRepository = menuRepository
    }
}

// menu에 대한 로직 처리
// UI update를 해줘야함

// Input
// 1. fetch를 통해 데이터 가져오기 >> 1. tableView에 노출시키기 (UI)
// 2. +, - 버튼 누르기          >> 2. tableView의 선택한 메뉴 수, 총 선택한 메뉴 수, 총합 금액 노출시키기 (연산) -> (UI)
// 3. order 버튼 누르기         >> 3. 선택한 메뉴 데이터를 가지고 OrderViewController로 이동 (UI)
// 4. clear 버튼 누르기         >> 4. 선택한 메뉴 정보가 리셋 (연산)

extension MenuUseCase {
    func fetchMenus() -> Observable<[Menu]> {
        return self.menuRepository.fetchMenus()
    }
}

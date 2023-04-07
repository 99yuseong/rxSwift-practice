//
//  MenuViewModel.swift
//  rxswift-practice
//
//  Created by 남유성 on 2023/03/29.
//

import UIKit
import RxSwift
import RxRelay

protocol ViewModelProtocol {
    associatedtype Input
    associatedtype Output
    
    func transform(from input: Input, disposeBag: RxSwift.DisposeBag) -> Output
}

final class MenuViewModel: ViewModelProtocol {

    // MARK - Property
    weak var coordinator: MenuCoordinator?
    
    private let disposeBag = DisposeBag()
    private let MenuUseCase: MenuUseCaseProtocol
    
    let increaseMenuCount: PublishSubject<(menu: Menu, inc: Int)>
    
    init(coordinator: MenuCoordinator?, MenuUseCase: MenuUseCaseProtocol) {
        self.coordinator = coordinator
        self.MenuUseCase = MenuUseCase
        increaseMenuCount = PublishSubject<(menu: Menu, inc: Int)>()
    }
    
    struct Input {
        let viewWillAppearEvent: Observable<Void>
        let refreshTableViewEvent: Observable<Void>
        let clearBtnTapEvent: Observable<Void>
        let orderBtnTapEvent: Observable<Void>
    }
    
    struct Output {
        var menus = PublishSubject<[Menu]>()
        var orderedMenus = PublishSubject<[Menu]>()
        let totalCountText = BehaviorSubject<String>(value: "")
        let totalPriceText = BehaviorSubject<String>(value: "")
        let activeIndicator = BehaviorSubject<Bool>(value: false)
    }
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        Observable.merge([
            input.viewWillAppearEvent,
            input.refreshTableViewEvent
        ])
            .do(onNext: { _ in output.activeIndicator.onNext(true) })
            .flatMap(self.MenuUseCase.fetchMenus)
            .do(onNext: { _ in output.activeIndicator.onNext(false) })
            .subscribe(onNext: {
                output.menus.onNext($0) // 서버에서 받아온 menus를 전달
            })
            .disposed(by: disposeBag)
        
                
        Observable.merge([
            input.clearBtnTapEvent,
            input.viewWillAppearEvent
        ])
            .withLatestFrom(output.menus)
            .map { $0.map { $0.countUpdated(0) }}
            .subscribe(onNext: output.menus.onNext)
            .disposed(by: disposeBag)
        
        input.orderBtnTapEvent
            .withLatestFrom(output.menus)
            .map { $0.filter { $0.count > 0 } }
            .subscribe(onNext: { output.orderedMenus.onNext($0) })
            .disposed(by: disposeBag)
        
        increaseMenuCount
            .map { (menu, inc) in
                menu.countUpdated(max(0, menu.count + inc))
            }
            .withLatestFrom(output.menus) { (updated, originals) -> [Menu] in
                return originals.map { original in
                    guard original.name == updated.name else { return original }
                    return updated
                }
            }
            .subscribe(onNext: { output.menus.onNext($0) })
            .disposed(by: disposeBag)
        
        output.menus
            .map { $0.map { $0.count * $0.price }.reduce(0, +) }
            .map { $0.currencyKR() }
            .subscribe(onNext: {output.totalPriceText.onNext($0)})
            .disposed(by: disposeBag)
        
        output.menus
            .map { $0.map { $0.count }.reduce(0, +) }
            .map { "\($0)" }
            .subscribe(onNext: { output.totalCountText.onNext($0) })
            .disposed(by: disposeBag)
        
        return output
    }
}

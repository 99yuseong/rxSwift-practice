//
//  OrderViewModel.swift
//  rxswift-practice
//
//  Created by 남유성 on 2023/04/06.
//

import Foundation
import RxSwift
import RxRelay

final class OrderViewModel: ViewModelProtocol {
    
    weak var coordinator: Coordinator?
    
    private var disposeBag = DisposeBag()
    
    init(coordinator: Coordinator?) {
        self.coordinator = coordinator
    }
    
    struct Input {
        let menus: [Menu]
    }
    
    struct Output {
        let orderedList: BehaviorRelay<String>
        let itemPriceText: BehaviorRelay<String>
        let itemVatText: BehaviorRelay<String>
        let totalPriceText: BehaviorRelay<String>
        
    }
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        let orderedList = BehaviorRelay<String>(value: "")
        let itemPriceText = BehaviorRelay<String>(value: "")
        let itemVatText = BehaviorRelay<String>(value: "")
        let totalPriceText = BehaviorRelay<String>(value: "")
        
        let output = Output(
            orderedList: orderedList,
            itemPriceText: itemPriceText,
            itemVatText: itemVatText,
            totalPriceText: totalPriceText
        )
        
        let menus = Observable.just(input.menus)
        let price = menus.map { $0.map { $0.count * $0.price }.reduce(0, +) }
        let vat = price.map { Int(Float($0) * 0.1 / 10 + 0.5) * 10 }
        
        menus.map { $0.map { "\($0.name) \($0.count)개\n" }.joined() }
            .subscribe(onNext: output.orderedList.accept)
            .disposed(by: disposeBag)
                
        price.map { $0.currencyKR() }
            .subscribe(onNext: output.itemPriceText.accept)
            .disposed(by: disposeBag)

        vat.map { $0.currencyKR() }
            .subscribe(onNext: output.itemVatText.accept)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(price, vat) { $0 + $1 }
            .map { $0.currencyKR() }
            .subscribe(onNext: output.totalPriceText.accept)
            .disposed(by: disposeBag)
        
        return output
    }
}

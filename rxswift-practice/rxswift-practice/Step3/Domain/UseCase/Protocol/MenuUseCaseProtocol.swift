//
//  MenuUseCaseProtocol.swift
//  rxswift-practice
//
//  Created by 남유성 on 2023/04/03.
//

import Foundation
import RxSwift

protocol MenuUseCaseProtocol {
    func fetchMenus() -> Observable<[Menu]>
}

//
//  MenuRepositoryProtocol.swift
//  rxswift-practice
//
//  Created by 남유성 on 2023/04/03.
//

import Foundation
import RxSwift

protocol MenuRepositoryProtocol {
    func fetchMenus() -> Observable<[Menu]>
}

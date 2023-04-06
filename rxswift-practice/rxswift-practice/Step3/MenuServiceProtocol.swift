//
//  MenuServiceProtocol.swift
//  rxswift-practice
//
//  Created by 남유성 on 2023/04/03.
//

import Foundation
import RxSwift

protocol MenuServiceProtocol {
    func fetchMenus() -> Observable<(HTTPURLResponse, Data?)>
}

//
//  MenuRepository.swift
//  rxswift-practice
//
//  Created by 남유성 on 2023/04/03.
//

import Foundation
import RxSwift

enum CodableError: Error {
    case DecodingError
    case EncodingError
}

// MARK - Init
final class MenuRepository: MenuRepositoryProtocol {
    
    private var urlSessionSerivce: URLSessionNetworkServiceProtocol
    typealias Error = CodableError
    
    init(urlSessionSerivce: URLSessionNetworkServiceProtocol) {
        self.urlSessionSerivce = urlSessionSerivce
    }
}

// MARK - Method
extension MenuRepository {
    
    /// @GET menu 데이터를 fetch합니다.
    /// - Returns: Observable<[Menu]>
    func fetchMenus() -> Observable<[Menu]> {
        
        // URL 설정
        let endPoint = "https://firebasestorage.googleapis.com/v0/b/rxswiftin4hours.appspot.com/o/fried_menus.json?alt=media&token=42d5cb7e-8ec4-48f9-bf39-3049e796c936"
        
        // Header 설정
//        let header = [
//            "Host": "{REGO 호스트}"
//            "Content-Type": "application/json"
//        ]
        
        // decodeTarget 설정
        // 서버 측에서 받는 데이터와 동일한 Struct 설정
        let decodeTarget = MenusDTO.self
        
        return self.urlSessionSerivce.get(url: endPoint, headers: nil)
            .map { result -> [Menu] in
                
                switch result {
                case .success(let data):

                    guard let response = try? JSONDecoder().decode(decodeTarget, from: data) else {
                        throw Error.DecodingError
                    }
                    
                    return response.menus.map { $0.toDomain() }
                case .failure(let err):
                    throw err
                }
        }
    }
}

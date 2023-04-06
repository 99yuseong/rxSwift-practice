//
//  MenuService.swift
//  rxswift-practice
//
//  Created by 남유성 on 2023/04/01.
//

import Foundation
import RxSwift

//final class StubMenuService: MenuServiceProtocol {
//    func fetchMenus() -> Observable<(HTTPURLResponse, Data?)> {
//        return Observable.create { observer in
//            observer.onNext(())
//        }
//    }
//}

// MARK - Rx Method
final class MenuService: MenuServiceProtocol {
    func fetchMenus() -> Observable<(HTTPURLResponse, Data?)> {
        return Observable.create { observer in
            self.fetchMenus { data, res, err in
                if let err = err {
                    observer.onError(err)
                } else {
                    observer.onNext((res!, data))
                    observer.onCompleted()
                }
                
            }
            return Disposables.create()
        }
    }
}

// MARK - Private Method
extension MenuService {
    
    private func fetchMenus(onCompletion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        let url = "https://firebasestorage.googleapis.com/v0/b/rxswiftin4hours.appspot.com/o/fried_menus.json?alt=media&token=42d5cb7e-8ec4-48f9-bf39-3049e796c936"
        
        URLSession.shared.dataTask(with: URL(string: url)!) { data, res, err in
            
            guard err == nil else {
                onCompletion(nil, nil, err)
                return
            }
            
            guard let httpResponse = res as? HTTPURLResponse else {
                let err = NSError(domain: "Invalid response type", code: -1)
                onCompletion(nil, nil, err)
                return
            }
            
            guard let data = data else {
                let err = NSError(domain: "No Data Returned", code: -1)
                onCompletion(nil, nil, err)
                return
            }
            
            onCompletion(data, httpResponse, nil)
        }
        .resume()
    }
}

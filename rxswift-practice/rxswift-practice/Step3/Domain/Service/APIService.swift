//
//  APIService.swift
//  rxswift-practice
//
//  Created by 남유성 on 2023/03/29.
//

import Foundation

let menuUrl = "https://firebasestorage.googleapis.com/v0/b/rxswiftin4hours.appspot.com/o/fried_menus.json?alt=media&token=42d5cb7e-8ec4-48f9-bf39-3049e796c936"


class APIService {
    static func fetchAllMenus(onComplete: @escaping (Result<Data, Error>) -> Void) {
        URLSession.shared.dataTask(with: URL(string: menuUrl)!) { data, res, err in
            guard err == nil else {
                onComplete(.failure(err!))
                return
            }
            
            guard let data = data else {
                let httpResponse = res as! HTTPURLResponse
                onComplete(.failure(NSError(domain: "no Data", code: httpResponse.statusCode, userInfo: nil)))
                return
            }
            onComplete(.success(data))
        }
        .resume()
    }
}

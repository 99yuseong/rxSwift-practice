//
//  URLSessionNetworkService.swift
//  rxswift-practice
//
//  Created by 남유성 on 2023/04/04.
//

import Foundation
import RxSwift

final class URLSessionNetworkService: URLSessionNetworkServiceProtocol {
    
    /// Repository에서 GET Request를 요청할 때 호출합니다.
    /// - Parameters:
    ///   - url: url String
    ///   - headers: [String:String]?
    func get(url: String, headers: [String : String]?)
    -> RxSwift.Observable<Result<Data, URLSessionNetworkServiceError>> {
        return self.request(url: url, headers: headers, method: HTTPMethod.get)
    }
    
    /// Repository에서 POST Request를 요청할 때 호출합니다.
    /// - Parameters:
    ///   - data: Codable
    ///   - url: url String
    ///   - headers: [String:String]?
    func post<T: Codable>(_ data: T, url: String, headers: [String : String]?)
    -> Observable<Result<Data, URLSessionNetworkServiceError>> {
        return self.request(with: data, url: url, headers: headers, method: HTTPMethod.post)
    }
    
    /// Repository에서 PUT Request를 요청할 때 호출합니다.
    /// - Parameters:
    ///   - data: Codable
    ///   - url: url String
    ///   - headers: [String:String]?
    func put<T: Codable>(_ data: T, url: String, headers: [String : String]?)
    -> RxSwift.Observable<Result<Data, URLSessionNetworkServiceError>> {
        return self.request(with: data, url: url, headers: headers, method: HTTPMethod.put)
    }
    
    /// Repository에서 DELETE Request를 요청할 때 호출합니다.
    /// - Parameters:
    ///   - url: url String
    ///   - headers: [String:String]?
    func delete(url: String, headers: [String : String]?)
    -> RxSwift.Observable<Result<Data, URLSessionNetworkServiceError>> {
        return self.request(url: url, headers: headers, method: HTTPMethod.delete)
    }
    
    /// GET, DELETE request에 대한 URLSession method입니다.
    /// 서버로 전송할 BodyData가 존재하지 않습니다.
    /// - Parameters:
    ///   - urlString: url String
    ///   - headers: [String: String]?
    ///   - method: HTTPMethod의 rawvalue
    private func request(url urlString: String, headers: [String: String]? = nil, method: String)
    -> Observable<Result<Data, URLSessionNetworkServiceError>> {
        
        // URL Valid 확인
        guard let url = URL(string: urlString) else {
            return Observable.error(URLSessionNetworkServiceError.invalidURLError)
        }
        
        return Observable<Result<Data, URLSessionNetworkServiceError>>.create { [self] emitter in
            
            // request 생성
            let request = createHTTPRequest(of: url, with: headers, httpMethod: method)
            
            let task = URLSession.shared.dataTask(with: request) { data, res, err in
                
                // Error 처리
                guard err == nil else {
                    emitter.onError(URLSessionNetworkServiceError.unknownError)
                    return
                }
                
                // HTTP Response Error 처리
                guard let httpResponse = res as? HTTPURLResponse else {
                    emitter.onError(URLSessionNetworkServiceError.unknownError)
                    return
                }
                
                // Status code Error 처리
                guard 200...299 ~= httpResponse.statusCode else {
                    emitter.onError(self.createHTTPError(errorCode: httpResponse.statusCode))
                    return
                }
                
                // Empty data 처리
                guard let data = data else {
                    emitter.onNext(.failure(.emptyDataError)) // statusCode가 200~299 사이인 경우, onNext로 전달합니다.
                    emitter.onCompleted()
                    return
                }
                
                // Success
                emitter.onNext(.success(data))
                emitter.onCompleted()
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
        
        
    }
    
    /// POST, PUT request에 대한 URLSession method입니다.
    /// 서버로 전송할 BodyData가 존재합니다.
    /// - Parameters:
    ///   - bodyData: T
    ///   - urlString: url String
    ///   - headers: [String: String]?
    ///   - method: HTTPMethod의 rawvalue
    private func request<T: Codable>(with bodyData: T, url urlString: String, headers: [String: String]? = nil, method: String)
    -> Observable<Result<Data, URLSessionNetworkServiceError>> {
        
        // URL Valid 확인
        guard let url = URL(string: urlString) else {
            return Observable.error(URLSessionNetworkServiceError.invalidURLError)
        }
        
        // Body 확인
        guard let httpBody = createHTTPBody(from: bodyData) else {
            return Observable.error(URLSessionNetworkServiceError.emptyDataError)
        }
        
        return Observable.create { emitter in
            let request = self.createHTTPRequest(of: url, with: headers, httpMethod: method, with: httpBody)
            let task = URLSession.shared.dataTask(with: request) { data, res, err in
                
                // Error 처리
                guard err == nil else {
                    emitter.onError(URLSessionNetworkServiceError.unknownError)
                    return
                }
                
                // HTTP Response Error 처리
                guard let httpResponse = res as? HTTPURLResponse else {
                    emitter.onError(URLSessionNetworkServiceError.unknownError)
                    return
                }
                
                // Status Code Error 처리
                guard 200...299 ~= httpResponse.statusCode else {
                    emitter.onError(self.createHTTPError(errorCode: httpResponse.statusCode))
                    return
                }
                
                // Empty Data 처리
                guard let data = data else {
                    emitter.onNext(.failure(.emptyDataError)) // statusCode가 200~299 사이인 경우, onNext로 전달합니다.
                    emitter.onCompleted()
                    return
                }
                
                // Success
                emitter.onNext(.success(data))
                emitter.onCompleted()
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    
    /// URL request를 생성하는 함수입니다. 요청마다 동일하거나 다른 request가 필요하기에, 따로 구분한 함수입니다.
    /// - Parameters:
    ///   - url: URL String입니다.
    ///   - headers: [String: String]?
    ///   - httpMethod: HTTPMethod ENUM을 사용합니다.
    ///   - body: Data?
    /// - Returns: URLRequest
    private func createHTTPRequest(
        of url: URL,
        with headers: [String:String]?,
        httpMethod: String,
        with body: Data? = nil)
    -> URLRequest {
        
        var request = URLRequest(url: url)                  // URLRequest 생성
        request.httpMethod = httpMethod                     // Method 설정 (GET/POST/PUT/DELETE)
        headers?.forEach({ header in                        // header 등록
            request.addValue(header.value, forHTTPHeaderField: header.key)
        })
        if let body = body { request.httpBody = body }      // body 등록
        
        return request
    }
    
    /// HTTP Body를 생성하는 함수입니다.
    /// - Parameter requestBody: Codable
    /// - Returns: Encode된 Data를 리턴합니다.
    private func createHTTPBody<T: Codable>(from requestBody: T) -> Data? {
        if let data = requestBody as? Data {
            return data
        }
        return try? JSONEncoder().encode(requestBody)
    }
    
    
    /// HTTP response statusCode에 따라 Error를 생성하는 함수 입니다.
    /// - Parameter errorCode: URLSession Response에서 받은 Int statusCode입니다.
    /// - Returns: HTTPMethod ENUM case를 리턴합니다.
    private func createHTTPError(errorCode: Int) -> Error {
        return URLSessionNetworkServiceError(rawValue: errorCode) ?? URLSessionNetworkServiceError.unknownError
    }
}


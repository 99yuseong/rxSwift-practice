//
//  URLSessionNetworkServiceProtocol.swift
//  rxswift-practice
//
//  Created by 남유성 on 2023/04/04.
//

import Foundation
import RxSwift

protocol URLSessionNetworkServiceProtocol {
    
    // MARK - GET(조회)
    func get(url: String, headers: [String: String]?)
    -> Observable<Result<Data, URLSessionNetworkServiceError>>
    
    // MARK - POST(생성)
    func post<T: Codable>(_ data: T, url: String, headers: [String:String]?)
    -> Observable<Result<Data, URLSessionNetworkServiceError>>
    
    // MARK - PUT(수정)
    func put<T: Codable>(_ data: T, url:String, headers: [String:String]?)
    -> Observable<Result<Data, URLSessionNetworkServiceError>>
    
    // MARK - DELETE(삭제)
    func delete(url: String, headers: [String:String]?)
    -> Observable<Result<Data, URLSessionNetworkServiceError>>
    
}

enum HTTPMethod {
    static let get = "GET"
    static let post = "POST"
    static let put = "PUT"
    static let delete = "DELETE"
}

enum URLSessionNetworkServiceError: Int, Error, CustomStringConvertible {
    var description: String { self.errorDescription }
    
    case unknownError = -1              // 예상치 못한 모든 에러 발생 시
    case requestError = -2              // 요청 파라미터에 문제가 있을 시
    case invalidUserError = 1000        // 존재하지 않는 회원정보에 접근 시
    case invalidPasswordError = 1001    // 잘못된 패스워드 입력 시
    case notRefreshedError = 1002       // 불필요한 토큰 refresh 요청 시(토큰이 not expired 이며, valid 함)
    case invalidTokenError = 1003       // 토큰의 정보에 문제가 있을 시(토큰이 not expired 이며, invalid 함)
    case expiredTokenError = 1004       // 만료된 토큰이 전달될 시(토큰이 expired 됨)
    case pendingWithdrawalError = 1005  // 탈퇴 요청한 회원 정보에 접근 시
    case invalidCodeError = 1006        // 잘못된 인증코드 입력 시
    case oAuthError = 1007              // Kakao 인증 관련 에러 발생 시
    case alreadyRegisteredError = 1101  // 이미 등록된 회원의 가입 요청 시
    case duplicatedError = 1102         // 이미 등록된 data의 등록 요청 시
    case dataError = 1103               // 수정/삭제를 원하는 data가 없을 시
    case permissionError = 1104         // 해당 data의 수정/삭제 권한이 없을 시
    
    case emptyDataError
    case responseDecodingError
    case payloadEncodingError
    case invalidURLError
    case invalidRequestError = 400
    case authenticationError = 401
    case forbiddenError = 403
    case notFoundError = 404
    case notAllowedHTTPMethodError = 405
    case timeoutError = 408
    case internalServerError = 500
    case notSupportedError = 501
    case badGatewayError = 502
    case invalidServiceError = 503
    
    var errorDescription: String {
        switch self {
        case .unknownError: return "-1: UNKNOWN_ERROR"
        case .requestError: return "-2: REQUEST_ERROR"
        case .invalidUserError: return "1000: INVALID_USER_ERROR"
        case .invalidPasswordError: return "1001: INVALID_PASSWORD_ERROR"
        case .notRefreshedError: return "1002: NOT_REFRESHED_ERROR"
        case .invalidTokenError: return "1003: INVALID_TOKEN_ERROR"
        case .expiredTokenError: return "1004: EXPIRED_TOKEN_ERROR"
        case .pendingWithdrawalError: return "1005: PENDING_WITHDRAWAL_ERROR"
        case .invalidCodeError: return "1006: INVALID_CODE_ERROR"
        case .oAuthError: return "1007: OAUTH_ERROR"
        case .alreadyRegisteredError: return "1101: ALREADY_REGISTERED_ERROR"
        case .duplicatedError: return "1102: DUPLICATED_ERROR"
        case .dataError: return "1103: DATA_ERROR"
        case .permissionError: return "1104: PERMISSION_ERROR"
        case .emptyDataError: return "EMPTY_DATA_ERROR"
        case .responseDecodingError: return "RESPONSE_DECODING_ERROR"
        case .payloadEncodingError: return "PAYLOAD_ENCODING_ERROR"
        case .invalidURLError: return "INVALID_URL_ERROR"
        case .invalidRequestError: return "400:INVALID_REQUEST_ERROR"
        case .authenticationError: return "401:AUTHENTICATION_FAILURE_ERROR"
        case .forbiddenError: return "403:FORBIDDEN_ERROR"
        case .notFoundError: return "404:NOT_FOUND_ERROR"
        case .notAllowedHTTPMethodError: return "405:NOT_ALLOWED_HTTP_METHOD_ERROR"
        case .timeoutError: return "408:TIMEOUT_ERROR"
        case .internalServerError: return "500:INTERNAL_SERVER_ERROR"
        case .notSupportedError: return "501:NOT_SUPPORTED_ERROR"
        case .badGatewayError: return "502:BAD_GATEWAY_ERROR"
        case .invalidServiceError: return "503:INVALID_SERVICE_ERROR"
        }
    }
}



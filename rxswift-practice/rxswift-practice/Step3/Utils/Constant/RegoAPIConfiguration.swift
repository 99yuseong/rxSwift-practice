//
//  RegoAPIConfiguration.swift
//  rxswift-practice
//
//  Created by 남유성 on 2023/04/04.
//

import Foundation

enum FirestoreConfiguration {
    static let firestoreBaseURL = "https://firestore.googleapis.com/v1/"
    static let baseURL = "https://firestore.googleapis.com/v1/projects/mate-runner-e232c"
    static let documentsPath = "/databases/(default)/documents"
    static let queryKey = ":runQuery"
    static let commitKey = ":commit"
    static let defaultHeaders = ["Content-Type": "application/json", "Accept": "application/json"]
}

enum FirestoreFieldParameter {
    static let updateMask = "updateMask.fieldPaths="
    static let readMask = "mask.fieldPaths="
}

enum FirestoreCollectionPath {
    static let runningResultPath = "/RunningResult"
    static let userPath = "/User"
    static let recordsPath = "/records"
    static let emojiPath = "/emojis"
    static let notificationPath = "/Notification"
    static let uidPath = "/UID"
}

enum FirestoreField {
    static let fields = "fields"
    static let emoji = "emoji"
    static let userNickname = "userNickname"
    static let nickname = "nickname"
    static let distance = "distance"
    static let time = "time"
    static let height = "height"
    static let weight = "weight"
    static let image = "image"
    static let calorie = "calorie"
    static let mate = "mate"
}

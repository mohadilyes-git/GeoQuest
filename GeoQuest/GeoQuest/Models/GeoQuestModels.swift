//
//  GeoQuestModels.swift
//  GeoQuest
//
//  Created by Ilyes Mo on 03/04/2026.
//

import Foundation

// User


struct User: Codable, Identifiable {
    let userID: Int
    let userFirstname: String
    let userLastname: String
    let userPhone: String
    let userUsername: String
    let userPassword: String
    let userLatitude: Double
    let userLongitude: Double
    let userTimestamp: Double
    let userImageURL: String

    var id: Int { userID }
    var fullName: String { "\(userFirstname) \(userLastname)" }

    enum CodingKeys: String, CodingKey {
        case userID = "UserID"
        case userFirstname = "UserFirstname"
        case userLastname = "UserLastname"
        case userPhone = "UserPhone"
        case userUsername = "UserUsername"
        case userPassword = "UserPassword"
        case userLatitude = "UserLatitude"
        case userLongitude = "UserLongitude"
        case userTimestamp = "UserTimestamp"
        case userImageURL = "UserImageURL"
    }
}

struct UserPayload: Codable {
    let userFirstname: String
    let userLastname: String
    let userPhone: String
    let userUsername: String
    let userPassword: String
    let userLatitude: Double
    let userLongitude: Double
    let userTimestamp: Double
    let userImageURL: String

    enum CodingKeys: String, CodingKey {
        case userFirstname = "UserFirstname"
        case userLastname = "UserLastname"
        case userPhone = "UserPhone"
        case userUsername = "UserUsername"
        case userPassword = "UserPassword"
        case userLatitude = "UserLatitude"
        case userLongitude = "UserLongitude"
        case userTimestamp = "UserTimestamp"
        case userImageURL = "UserImageURL"
    }
}

//  Event

struct Event: Codable, Identifiable {
    let eventID: Int
    let eventName: String
    let eventDescription: String
    let eventOwnerID: Int
    let eventIspublic: Bool
    let eventStart: String
    let eventFinish: String
    let eventStatusID: Int
    let eventOwner: User?
    let eventStatus: EventStatus?

    var id: Int { eventID }

    enum CodingKeys: String, CodingKey {
        case eventID = "EventID"
        case eventName = "EventName"
        case eventDescription = "EventDescription"
        case eventOwnerID = "EventOwnerID"
        case eventIspublic = "EventIspublic"
        case eventStart = "EventStart"
        case eventFinish = "EventFinish"
        case eventStatusID = "EventStatusID"
        case eventOwner = "EventOwner"
        case eventStatus = "EventStatus"
    }
}

struct EventPayload: Codable {
    let eventName: String
    let eventDescription: String
    let eventOwnerID: Int
    let eventIspublic: Bool
    let eventStart: String
    let eventFinish: String
    let eventStatusID: Int

    enum CodingKeys: String, CodingKey {
        case eventName = "EventName"
        case eventDescription = "EventDescription"
        case eventOwnerID = "EventOwnerID"
        case eventIspublic = "EventIspublic"
        case eventStart = "EventStart"
        case eventFinish = "EventFinish"
        case eventStatusID = "EventStatusID"
    }
}

// EventStatus


struct EventStatus: Codable {
    let statusID: Int
    let statusName: String
    let statusOrder: Int

    enum CodingKeys: String, CodingKey {
        case statusID = "StatusID"
        case statusName = "StatusName"
        case statusOrder = "StatusOrder"
    }
}


//  Cache



struct Cache: Codable, Identifiable {
    let cacheID: Int
    let cacheName: String
    let cacheDescription: String
    let cacheEventID: Int
    let cacheImageURL: String
    let cacheClue: String
    let cachePoints: Int
    let cacheLatitude: Double
    let cacheLongitude: Double
    let cacheEvent: CacheEvent?

    var id: Int { cacheID }

    enum CodingKeys: String, CodingKey {
        case cacheID = "CacheID"
        case cacheName = "CacheName"
        case cacheDescription = "CacheDescription"
        case cacheEventID = "CacheEventID"
        case cacheImageURL = "CacheImageURL"
        case cacheClue = "CacheClue"
        case cachePoints = "CachePoints"
        case cacheLatitude = "CacheLatitude"
        case cacheLongitude = "CacheLongitude"
        case cacheEvent = "CacheEvent"
    }
}

struct CacheEvent: Codable {
    let eventID: Int
    let eventName: String
    let eventDescription: String
    let eventOwnerID: Int
    let eventIspublic: Bool
    let eventStart: String
    let eventFinish: String
    let eventStatusID: Int

    enum CodingKeys: String, CodingKey {
        case eventID = "EventID"
        case eventName = "EventName"
        case eventDescription = "EventDescription"
        case eventOwnerID = "EventOwnerID"
        case eventIspublic = "EventIspublic"
        case eventStart = "EventStart"
        case eventFinish = "EventFinish"
        case eventStatusID = "EventStatusID"
    }
}

struct CachePayload: Codable {
    let cacheName: String
    let cacheDescription: String
    let cacheEventID: Int
    let cacheImageURL: String
    let cacheClue: String
    let cachePoints: Int
    let cacheLatitude: Double
    let cacheLongitude: Double

    enum CodingKeys: String, CodingKey {
        case cacheName = "CacheName"
        case cacheDescription = "CacheDescription"
        case cacheEventID = "CacheEventID"
        case cacheImageURL = "CacheImageURL"
        case cacheClue = "CacheClue"
        case cachePoints = "CachePoints"
        case cacheLatitude = "CacheLatitude"
        case cacheLongitude = "CacheLongitude"
    }
}


//  Player


struct Player: Codable, Identifiable {
    let playerID: Int
    let playerUserID: Int
    let playerEventID: Int
    let playerUser: User?
    let playerEvent: PlayerEvent?

    var id: Int { playerID }

    enum CodingKeys: String, CodingKey {
        case playerID = "PlayerID"
        case playerUserID = "PlayerUserID"
        case playerEventID = "PlayerEventID"
        case playerUser = "PlayerUser"
        case playerEvent = "PlayerEvent"
    }
}

struct PlayerEvent: Codable {
    let eventID: Int
    let eventName: String
    let eventDescription: String
    let eventOwnerID: Int
    let eventIspublic: Bool
    let eventStart: String
    let eventFinish: String
    let eventStatusID: Int

    enum CodingKeys: String, CodingKey {
        case eventID = "EventID"
        case eventName = "EventName"
        case eventDescription = "EventDescription"
        case eventOwnerID = "EventOwnerID"
        case eventIspublic = "EventIspublic"
        case eventStart = "EventStart"
        case eventFinish = "EventFinish"
        case eventStatusID = "EventStatusID"
    }
}

struct PlayerPayload: Codable {
    let playerUserID: Int
    let playerEventID: Int

    enum CodingKeys: String, CodingKey {
        case playerUserID = "PlayerUserID"
        case playerEventID = "PlayerEventID"
    }
}


//  Find

struct Find: Codable, Identifiable {
    let findID: Int
    let findPlayerID: Int
    let findCacheID: Int
    let findDatetime: String
    let findImageURL: String?
    let findPlayer: FindPlayer?
    let findCache: FindCache?

    var id: Int { findID }

    enum CodingKeys: String, CodingKey {
        case findID = "FindID"
        case findPlayerID = "FindPlayerID"
        case findCacheID = "FindCacheID"
        case findDatetime = "FindDatetime"
        case findImageURL = "FindImageURL"
        case findPlayer = "FindPlayer"
        case findCache = "FindCache"
    }
}

struct FindPlayer: Codable {
    let playerID: Int
    let playerUserID: Int
    let playerEventID: Int
    let playerUser: User?

    enum CodingKeys: String, CodingKey {
        case playerID = "PlayerID"
        case playerUserID = "PlayerUserID"
        case playerEventID = "PlayerEventID"
        case playerUser = "PlayerUser"
    }
}

struct FindCache: Codable {
    let cacheID: Int
    let cacheName: String
    let cacheDescription: String
    let cacheEventID: Int
    let cacheImageURL: String
    let cacheClue: String
    let cachePoints: Int
    let cacheLatitude: Double
    let cacheLongitude: Double

    enum CodingKeys: String, CodingKey {
        case cacheID = "CacheID"
        case cacheName = "CacheName"
        case cacheDescription = "CacheDescription"
        case cacheEventID = "CacheEventID"
        case cacheImageURL = "CacheImageURL"
        case cacheClue = "CacheClue"
        case cachePoints = "CachePoints"
        case cacheLatitude = "CacheLatitude"
        case cacheLongitude = "CacheLongitude"
    }
}

struct FindPayload: Codable {
    let findPlayerID: Int
    let findCacheID: Int
    let findDatetime: String
    let findImageURL: String?

    enum CodingKeys: String, CodingKey {
        case findPlayerID = "FindPlayerID"
        case findCacheID = "FindCacheID"
        case findDatetime = "FindDatetime"
        case findImageURL = "FindImageURL"
    }
}

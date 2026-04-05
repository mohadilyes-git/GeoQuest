//
//  GeoQuestAPIManager.swift
//  GeoQuest
//
//  Created by Ilyes Mo on 03/04/2026.
//
import Foundation

enum APIError: LocalizedError {
    case badURL
    case badResponse
    case emptyResponse
    case serverError(String)
}

final class GeoQuestAPIManager {
    static let shared = GeoQuestAPIManager()
    private let baseURL = "https://mark0s.com/geoquest/v1/api"
    private let apiKey = "bpf4i9"
    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    //  Users
    func getUsers() async throws -> [User] {
        let request = try makeRequest(path: "users", method: "GET")
        let (data, response) = try await session.data(for: request)
        try checkStatus(response: response, data: data)
        return try decoder.decode([User].self, from: data)
    }

    func getUser(id: Int) async throws -> User {
        let request = try makeRequest(path: "users/\(id)", method: "GET")
        let (data, response) = try await session.data(for: request)
        try checkStatus(response: response, data: data)
        let users = try decoder.decode([User].self, from: data)
        guard let user = users.first else { throw APIError.emptyResponse }
        return user
    }

    func createUser(payload: UserPayload) async throws -> User {
        var request = try makeRequest(path: "users", method: "POST")
        request.httpBody = try encoder.encode(payload)
        let (data, response) = try await session.data(for: request)
        try checkStatus(response: response, data: data)
        let users = try decoder.decode([User].self, from: data)
        guard let user = users.first else { throw APIError.emptyResponse }
        return user
    }

    func updateUser(id: Int, payload: UserPayload) async throws -> User {
        var request = try makeRequest(path: "users/\(id)", method: "PUT")
        request.httpBody = try encoder.encode(payload)
        let (data, response) = try await session.data(for: request)
        try checkStatus(response: response, data: data)
        let users = try decoder.decode([User].self, from: data)
        guard let user = users.first else { throw APIError.emptyResponse }
        return user
    }

    func deleteUser(id: Int) async throws {
        let request = try makeRequest(path: "users/\(id)", method: "DELETE")
        let (data, response) = try await session.data(for: request)
        try checkStatus(response: response, data: data)
    }

    // Events
    func getEvents() async throws -> [Event] {
        let request = try makeRequest(path: "events", method: "GET")
        let (data, response) = try await session.data(for: request)
        try checkStatus(response: response, data: data)
        return try decoder.decode([Event].self, from: data)
    }

    func getEvent(id: Int) async throws -> Event {
        let request = try makeRequest(path: "events/\(id)", method: "GET")
        let (data, response) = try await session.data(for: request)
        try checkStatus(response: response, data: data)
        let events = try decoder.decode([Event].self, from: data)
        guard let event = events.first else { throw APIError.emptyResponse }
        return event
    }

    func createEvent(payload: EventPayload) async throws -> Event {
        var request = try makeRequest(path: "events", method: "POST")
        request.httpBody = try encoder.encode(payload)
        let (data, response) = try await session.data(for: request)
        try checkStatus(response: response, data: data)
        let events = try decoder.decode([Event].self, from: data)
        guard let event = events.first else { throw APIError.emptyResponse }
        return event
    }

    //  Caches
    func getCaches() async throws -> [Cache] {
        let request = try makeRequest(path: "caches", method: "GET")
        let (data, response) = try await session.data(for: request)
        try checkStatus(response: response, data: data)
        return try decoder.decode([Cache].self, from: data)
    }

    func getCachesForEvent(eventID: Int) async throws -> [Cache] {
        let request = try makeRequest(path: "caches/events/\(eventID)", method: "GET")
        let (data, response) = try await session.data(for: request)
        try checkStatus(response: response, data: data)
        return try decoder.decode([Cache].self, from: data)
    }

    func createCache(payload: CachePayload) async throws -> Cache {
        var request = try makeRequest(path: "caches", method: "POST")
        request.httpBody = try encoder.encode(payload)
        let (data, response) = try await session.data(for: request)
        try checkStatus(response: response, data: data)
        let caches = try decoder.decode([Cache].self, from: data)
        guard let cache = caches.first else { throw APIError.emptyResponse }
        return cache
    }

    //  Players
    func getPlayers() async throws -> [Player] {
        let request = try makeRequest(path: "players", method: "GET")
        let (data, response) = try await session.data(for: request)
        try checkStatus(response: response, data: data)
        return try decoder.decode([Player].self, from: data)
    }

    func getPlayersForEvent(eventID: Int) async throws -> [Player] {
        let request = try makeRequest(path: "players/events/\(eventID)", method: "GET")
        let (data, response) = try await session.data(for: request)
        try checkStatus(response: response, data: data)
        return try decoder.decode([Player].self, from: data)
    }

    func joinEvent(payload: PlayerPayload) async throws -> Player {
        var request = try makeRequest(path: "players", method: "POST")
        request.httpBody = try encoder.encode(payload)
        let (data, response) = try await session.data(for: request)
        try checkStatus(response: response, data: data)
        let players = try decoder.decode([Player].self, from: data)
        guard let player = players.first else { throw APIError.emptyResponse }
        return player
    }

    //  Finds
    func getFinds() async throws -> [Find] {
        let request = try makeRequest(path: "finds", method: "GET")
        let (data, response) = try await session.data(for: request)
        try checkStatus(response: response, data: data)
        return try decoder.decode([Find].self, from: data)
    }

    func getFindsForPlayer(playerID: Int) async throws -> [Find] {
        let request = try makeRequest(path: "finds/players/\(playerID)", method: "GET")
        let (data, response) = try await session.data(for: request)
        try checkStatus(response: response, data: data)
        return try decoder.decode([Find].self, from: data)
    }

    func getFindsForEvent(eventID: Int) async throws -> [Find] {
        let request = try makeRequest(path: "finds/events/\(eventID)", method: "GET")
        let (data, response) = try await session.data(for: request)
        try checkStatus(response: response, data: data)
        return try decoder.decode([Find].self, from: data)
    }

    func logFind(payload: FindPayload) async throws -> Find {
        var request = try makeRequest(path: "finds", method: "POST")
        request.httpBody = try encoder.encode(payload)
        let (data, response) = try await session.data(for: request)
        try checkStatus(response: response, data: data)
        let finds = try decoder.decode([Find].self, from: data)
        guard let find = finds.first else { throw APIError.emptyResponse }
        return find
    }

    //  Status
    func getStatus() async throws -> [EventStatus] {
        let request = try makeRequest(path: "status", method: "GET")
        let (data, response) = try await session.data(for: request)
        try checkStatus(response: response, data: data)
        return try decoder.decode([EventStatus].self, from: data)
    }

    //  Helpers
    private func makeRequest(path: String, method: String) throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)/\(path)?key=\(apiKey)") else {
            throw APIError.badURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

    @discardableResult
    private func checkStatus(response: URLResponse, data: Data) throws -> Int {
        guard let response = response as? HTTPURLResponse else {
            throw APIError.badResponse
        }
        guard (200...299).contains(response.statusCode) else {
            let text = String(decoding: data, as: UTF8.self)
            throw APIError.serverError(text)
        }
        return response.statusCode
    }
}

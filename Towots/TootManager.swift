//
//  TootManager.swift
//  Towots
//
//  Created by りん on 27/1/2024.
//

import AuthenticationServices
import Combine
import Foundation
import SwiftKeychainWrapper
import TootSDK

/// Holder class for managing your currently selected client
public class TootManager: ObservableObject, @unchecked Sendable {
    private var instanceKey = "tootSDK.instanceURL"
    private var accessTokenKey = "tootSDK.accessToken"
    private let callbackURI = "swiftuitoot://test"

    // MARK: - Published properties
    @Published public var currentClient: TootClient!
    @Published public var authenticated: Bool = false

    init() {
        if let instanceURLstring = KeychainWrapper.standard.string(forKey: self.instanceKey),
            let instanceURL = URL(string: instanceURLstring),
            let accessToken = KeychainWrapper.standard.string(forKey: self.accessTokenKey)
        {
            self.currentClient = TootClient(instanceURL: instanceURL, accessToken: accessToken)
            self.currentClient?.debugOn()
            self.authenticated = true
            Task {
                try await self.currentClient.connect()
            }
        }
    }

    @MainActor public func createClientAndPresentSignIn(_ url: URL) async throws {
        self.currentClient = try await TootClient(connect: url)

        if let accessToken = try await currentClient?.presentSignIn(callbackURI: callbackURI) {
            if let instanceURL = currentClient?.instanceURL {
                KeychainWrapper.standard.set(instanceURL.absoluteString, forKey: self.instanceKey)
                KeychainWrapper.standard.set(accessToken, forKey: self.accessTokenKey)
                authenticated = true
            }
        }
    }

    @MainActor public func createClientAndAuthorizeURL(_ url: URL) async throws -> URL? {
        self.currentClient = try await TootClient(connect: url)

        return try await self.currentClient?.createAuthorizeURL(server: url, callbackURI: callbackURI)
    }

    @MainActor public func collectAccessToken(_ url: URL) async throws {
        if let accessToken = try await currentClient?.collectToken(returnUrl: url, callbackURI: callbackURI) {

            // Persist token and instance details for signing in
            if let instanceURL = currentClient?.instanceURL {
                KeychainWrapper.standard.set(instanceURL.absoluteString, forKey: self.instanceKey)
                KeychainWrapper.standard.set(accessToken, forKey: self.accessTokenKey)
                authenticated = true
            }
        }
    }

    @MainActor public func signOut() {
        KeychainWrapper.standard.removeAllKeys()
        authenticated = false
        self.currentClient = nil
    }

}

//import AuthenticationServices
//import Combine
//import Foundation
//import Security
//import TootSDK
//
///// Holder class for managing your currently selected client
//public class TootManager: ObservableObject, @unchecked Sendable {
//    private var clientKey = "tootSDK.client"
//    private let callbackURI = "towots://test"
//
//    // MARK: - Published properties
//    @Published public var currentClient: TootClient!
//    @Published public var authenticated: Bool = false
//
//    init() {
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassInternetPassword,
//            kSecAttrAccessGroup as String: clientKey,
//            kSecMatchLimit as String: kSecMatchLimitOne,
//            kSecReturnAttributes as String: true,
//            kSecReturnData as String: true,
//        ]
//        
//        var item: CFTypeRef?
//        
//        if SecItemCopyMatching(query as CFDictionary, &item) == noErr {
//            if let existingItem = item as? [String: Any],
//               let instanceURLString = existingItem[kSecAttrServer as String] as? String,
//               let instanceURL = URL(string: instanceURLString),
//               let accessTokenData = existingItem[kSecValueData as String] as? Data,
//               let accessToken = String(data: accessTokenData, encoding: .utf8) {
//                self.currentClient = TootClient(instanceURL: instanceURL, accessToken: accessToken)
//                self.currentClient?.debugOn()
//                self.authenticated = true
//                Task {
//                    try await self.currentClient.connect()
//                }
//            }
//        }
//    }
//
//    @MainActor public func createClientAndPresentSignIn(_ url: URL) async throws {
//        self.currentClient = try await TootClient(connect: url)
//
//        if let accessToken = try await currentClient?.presentSignIn(callbackURI: callbackURI) {
//            if let instanceURL = currentClient?.instanceURL {
//                let attributes: [String: Any] = [
//                    kSecClass as String: kSecClassInternetPassword,
//                    kSecAttrAccessGroup as String: clientKey,
//                    kSecAttrServer as String: instanceURL,
//                    kSecValueData as String: accessToken.data(using: .utf8)!,
//                ]
//                
//                SecItemAdd(attributes as CFDictionary, nil)
//                authenticated = true
//            }
//        }
//    }
//
//    @MainActor public func createClientAndAuthorizeURL(_ url: URL) async throws -> URL? {
//        self.currentClient = try await TootClient(connect: url)
//
//        return try await self.currentClient?.createAuthorizeURL(server: url, callbackURI: callbackURI)
//    }
//
//    @MainActor public func collectAccessToken(_ url: URL) async throws {
//        if let accessToken = try await currentClient?.collectToken(returnUrl: url, callbackURI: callbackURI) {
//
//            // Persist token and instance details for signing in
//            if let instanceURL = currentClient?.instanceURL {
//                let attributes: [String: Any] = [
//                    kSecClass as String: kSecClassInternetPassword,
//                    kSecAttrAccessGroup as String: clientKey,
//                    kSecAttrServer as String: instanceURL,
//                    kSecValueData as String: accessToken.data(using: .utf8)!,
//                ]
//                
//                SecItemAdd(attributes as CFDictionary, nil)
//                authenticated = true
//            }
//        }
//    }
//
//    @MainActor public func signOut() {
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassInternetPassword,
//            kSecAttrAccessGroup as String: clientKey
//        ]
//        
//        SecItemDelete(query as CFDictionary)
//        authenticated = false
//        self.currentClient = nil
//    }
//
//}

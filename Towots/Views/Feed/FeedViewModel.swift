//
//  FeedViewModel.swift
//  Towots
//
//  Created by りん on 27/1/2024.
//

import Combine
import Foundation
import SwiftUI
import TootSDK

struct FeedPost: Hashable {
    var html: String
    var markdown: String
    var tootPost: Post
}

actor FeedViewModel: ObservableObject {
    @MainActor @Published var feedPosts: [FeedPost] = []
    @MainActor @Published var loading: Bool = false
    @MainActor @Published var name: String = ""

    @MainActor private var tootManager: TootManager?
    private var lastClient: TootClient?

    private var streamType: Timeline
    
    var nextPage: PagedInfo? = nil

    public init(streamType: Timeline) {
        self.streamType = streamType
    }

    // MARK: - Published var updates
    @MainActor private func updatePostsLeading(_ newPosts: [FeedPost]) {
        feedPosts = newPosts + feedPosts
    }
    
    @MainActor private func updatePostsTrailing(_ newPosts: [FeedPost]) {
        feedPosts = feedPosts + newPosts
    }

    @MainActor private func resetPosts() {
        feedPosts = []
    }

    @MainActor private func setLoading(_ value: Bool) {
        loading = value
    }

    @MainActor private func setName(_ value: String) {
        name = value
    }
}

// MARK: - Public methods
extension FeedViewModel {

    public func refreshIfNoPosts() async throws {
        guard await self.feedPosts.isEmpty else { return }
        try await refresh()
    }

    public func refresh() async throws {
        await setLoading(true)
        try await tootManager?.currentClient?.data.refresh(streamType)
        try await tootManager?.currentClient?.data.refresh(.verifyCredentials)
        await setLoading(false)
    }
    
    public func loadMore() async throws {
        await setLoading(true)
        
        print("\(nextPage!)")
        
        let posts = try await tootManager?.currentClient?.getTimeline(streamType, pageInfo: nextPage)
        
        let renderer = UIKitAttribStringRenderer()
        
        let newPosts = posts!.result.map { post in
            let html = renderer.render(post.displayPost).wrappedValue
            let markdown = TootHTML.extractAsPlainText(html: post.displayPost.content) ?? ""

            return FeedPost(html: html, markdown: markdown, tootPost: post)
        }
        
        nextPage = PagedInfo(maxId: newPosts.last?.tootPost.id) 

        await updatePostsTrailing(newPosts)
        
        await setLoading(false)
    }

    @MainActor public func setManager(_ tootManager: TootManager) async {
        self.tootManager = tootManager
        await self.setBindings()
    }

}

// MARK: - Bindings
extension FeedViewModel {
    private func setBindings() async {
        guard let tootManager = await self.tootManager else { return }

        Task {
            for await posts in try await tootManager.currentClient.data.stream(streamType) {
                let renderer = UIKitAttribStringRenderer()

                let newPosts = posts.map { post in

                    let html = renderer.render(post.displayPost).wrappedValue
                    let markdown = TootHTML.extractAsPlainText(html: post.displayPost.content) ?? ""

                    return FeedPost(html: html, markdown: markdown, tootPost: post)
                }
                
                nextPage = PagedInfo(maxId: newPosts.last?.tootPost.id)

                await updatePostsLeading(newPosts)
            }
        }

        // Reset data if the client changes (user has signed in/out etc)
        Task {
            for await client in tootManager.$currentClient.values {
                guard client != self.lastClient else { return }  // Only change if the client has changed

                await resetPosts()
                await setName("")
                self.lastClient = client
            }
        }

        // opt into account updates
        Task {
            for await account in try await tootManager.currentClient.data.stream(.verifyCredentials) {
                await self.setName(account.displayName ?? "-")
            }
        }

    }
}

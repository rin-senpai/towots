//
//  PostView.swift
//  Towots
//
//  Created by りん on 27/1/2024.
//

import SwiftUI

import EmojiText
import SwiftUI
import TootSDK
import NukeUI
import UIKit
import SwiftUIIntrospect

struct FeedPostView: View {
    @EnvironmentObject var tootManager: TootManager

    var feedPost: FeedPost
    var post: Post
    var mediaPost: Post

    @Binding var path: NavigationPath
    
    let formatter = DateComponentsFormatter()
    
    init(feedPost: FeedPost, path: Binding<NavigationPath>) {
        if feedPost.tootPost.displayingRepost {
            self.mediaPost = feedPost.tootPost.repost!
        } else {
            self.mediaPost = feedPost.tootPost
        }
        
        self.post = feedPost.tootPost
        self.feedPost = feedPost
        self._path = path
        
        self.formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        self.formatter.unitsStyle = .abbreviated
        self.formatter.maximumUnitCount = 1
    }

    var body: some View {
        VStack {
            VStack {
                if feedPost.tootPost.displayingRepost {
                    HStack(spacing: 0) {
                        Spacer().frame(width: 64)
                        HStack {
                            LazyImage(url: URL(string: post.account.avatar)) { state in
                                if let image = state.image {
                                    image.resizable()
                                } else {
                                    ZStack {
                                        Color.gray.opacity(0.1)
                                        ProgressView()
                                    }
                                }
                            }
                            .frame(width: 22, height: 22)
                            .clipShape(Circle())

                            EmojiText(
                                markdown: (post.account.displayName ?? post.account.username ?? "???"),
                                emojis: post.account.emojis.remoteEmojis()
                            )
                            .font(.caption.italic())
                            .lineLimit(1)
                            .truncationMode(.tail)

                            Image(systemName: "arrow.2.squarepath")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 12)
                                .padding(.trailing, 8)
                        }
                        .background {
                            Color.gray.opacity(0.2)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: .infinity))
                        
                        Spacer()
                    }
                    .padding(.top, -2)
                    .padding(.bottom, 4)
                }

                HStack(alignment: .top, spacing: 16) {
                    LazyImage(url: URL(string: post.displayPost.account.avatar)) { state in
                        if let image = state.image {
                            image.resizable()
                        } else {
                            ZStack {
                                Color.gray.opacity(0.1)
                                ProgressView()
                            }
                        }
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                    .onLongPressGesture {
                        self.path.append(post.displayPost.account)
                    }
                    
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top) {
                            EmojiText(
                                markdown: (post.displayPost.account.displayName ?? ""),
                                emojis: post.displayPost.account.emojis.remoteEmojis()
                            )
                            .font(.subheadline.bold())
                            .lineLimit(1)
                            .truncationMode(.tail)
                            
                            Spacer()
                            Text(formatter.string(from: post.createdAt, to: Date())!.replacingOccurrences(of: "in", with: "").replacingOccurrences(of: ".", with: ""))
                                .font(.subheadline).foregroundStyle(.gray)
                        }
                        
                        if !feedPost.markdown.isEmpty {
                            EmojiText(
                                markdown: feedPost.markdown.trimmingCharacters(in: .whitespacesAndNewlines),
                                emojis: post.emojis.remoteEmojis()
                            )
                        }
                        
                        if mediaPost.mediaAttachments.count == 1 { // need to support for video, gifv, audio, unknown
                            LazyImage(url: URL(string: mediaPost.mediaAttachments[0].url)) { state in
                                if let image = state.image {
                                    image.resizable()
                                } else {
                                    ZStack {
                                        if let blurHash = mediaPost.mediaAttachments[0].blurhash {
                                            Image(uiImage: UIImage.init(blurHash: blurHash, size: CGSize(width: 32, height: 32 / (mediaPost.mediaAttachments[0].meta?.original?.aspect ?? 1)))!)
                                                .resizable()
                                        }
                                        ProgressView()
                                    }
                                }
                            }
                            .aspectRatio(CGSize(width: mediaPost.mediaAttachments[0].meta?.original?.width ?? 256, height: mediaPost.mediaAttachments[0].meta?.original?.height ?? 256), contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 12, height: 12)))
                            .contextMenu {
                                imageMenuItems
                            }
                        } else if mediaPost.mediaAttachments.count != 0 {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(mediaPost.mediaAttachments) { attachment in
                                        LazyImage(url: URL(string: attachment.url)) { state in
                                            if let image = state.image {
                                                image
                                                    .resizable()
                                            } else {
                                                ZStack {
                                                    if let blurHash = attachment.blurhash {
                                                        Image(uiImage: UIImage.init(blurHash: blurHash, size: CGSize(width: 32, height: 32 / (attachment.meta?.original?.aspect ?? 1)))!)
                                                            .resizable()
                                                    }
                                                    ProgressView()
                                                }
                                            }
                                        }
                                        .aspectRatio(CGSize(width: attachment.meta?.original?.width ?? 256, height: attachment.meta?.original?.height ?? 256), contentMode: .fit)
                                        .frame(height: 256)
                                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 12, height: 12)))
                                        .contextMenu {
                                            imageMenuItems
                                        }
                                    }
                                }
                            }
                            .padding(.bottom, 2)
                            .scrollClipDisabled()
                        }
                        
                        HStack(alignment: .bottom) {
                            Button {
                                print("comment")
                            } label: {
                                HStack {
                                    Image(systemName: "bubble")
                                    Text(String(post.displayPost.repliesCount))
                                        .font(.system(size: 14, weight: .medium))
                                }
                            }
                            .buttonStyle(PostButtonStyle())
                            
                            Spacer()
                            
                            Button {
                                print("boost repost whatever")
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.2.squarepath")
                                    Text(String(post.displayPost.repostsCount))
                                        .font(.system(size: 14, weight: .medium))
                                }
                            }
                            .buttonStyle(PostButtonStyle())
                            
                            Spacer()
                            
                            Button {
                                print("like")
                            } label: {
                                HStack {
                                    if post.displayPost.favourited ?? false {
                                        Image(systemName: "heart.fill")
                                            .foregroundStyle(.pink)
                                    } else {
                                        Image(systemName: "heart")
                                    }
                                    Text(String(post.displayPost.favouritesCount))
                                        .font(.system(size: 14, weight: .medium))
                                }
                            }
                            .buttonStyle(PostButtonStyle())
                            
                            Spacer()
                            
                            ShareLink(item: URL(string: post.displayPost.url!)!) {
                                Image(systemName: "square.and.arrow.up")
                            }
                            .buttonStyle(PostButtonStyle())
                        }
                        .padding(.top, 6)
                    }
                }
            }
            .padding()
        }
        .background(.background.opacity(0.001))  // Enables the whole row to be pressed
        .contextMenu {
            postMenuItems
        }
    }
    
    var postMenuItems: some View {
        Group {
            Button("Action 4", action: {})
            Button("Action 5", action: {})
            Button("Action 6", action: {})
        }
    }
    
    var imageMenuItems: some View {
        Group {
            Button {
                print("xd")
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text("Save Image")
                }
            }
            
            Button {
                print("xd")
            } label: {
                HStack {
                    Image(systemName: "doc.on.doc")
                    Text("Copy Image")
                }
            }
            
            Button {
                print("xd")
            } label: {
                HStack {
                    Image(systemName: "link")
                    Text("Copy Link")
                }
            }
            
            Button {
                print("xd")
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Image")
                }
            }
        }
    }
}

struct PostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.gray)
    }
}

#Preview {
    FeedPostView(feedPost: FeedPost(html: "<p>awawawawawa</p>", markdown: "awawawawawa", tootPost: Post(id: "1", uri: "https://google.com", createdAt: Date(timeIntervalSinceNow: -69420), account: Account(id: "1", acct: "whatisthis", url: "https://google.com", note: "who am I", avatar: "https://nowherenotfound.com!", header: "awawawawawa", headerStatic: "1", locked: false, emojis: [], createdAt: Date(timeIntervalSinceNow: -473891), postsCount: 8, followersCount: 2, followingCount: 2, fields: []), visibility: Post.Visibility.public, sensitive: false, spoilerText: "", mediaAttachments: [], application: TootApplication(name: "whyy"), mentions: [], tags: [], emojis: [], repostsCount: 22, favouritesCount: 2, repliesCount: 222)), path: .constant(NavigationPath()))
}

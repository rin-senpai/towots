//
//  FeedListView.swift
//  Towots
//
//  Created by りん on 27/1/2024.
//

import SwiftUI

struct FeedListView: View {
    @EnvironmentObject var tootManager: TootManager
    @ObservedObject var viewModel: FeedViewModel
    
    @State var path: NavigationPath

    var body: some View {
        LazyVStack(spacing: 0) { // omg lazy is so laggy
            ForEach(Array(viewModel.feedPosts.enumerated()), id: \.offset) { offset, feedPost in
                Divider()
                Button {
                    self.path.append(feedPost.tootPost.displayPost.id)
                } label: {
                    FeedPostView(feedPost: feedPost, path: $path)
                }
                .buttonStyle(PostStyle())
                .onAppear {
                    if offset == viewModel.feedPosts.count - 10 {
                        Task {
                            try? await viewModel.loadMore()
                        }
                    }
                }
            }
            
            ProgressView()
                .padding()
        }
//        .navigationDestination(for: String.self) { value in
//                PostOperationsView(postID: .constant(value), path: $path)
//        }
//        .navigationDestination(for: Account.self) { account in
//             AccountView(account: account)
//        }
        .task {
            await viewModel.setManager(tootManager)
            try? await viewModel.refreshIfNoPosts()
        }
    }
}

struct PostStyle: PrimitiveButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            // Make the whole button surface tappable. Without this only content in the label is tappable and not whitespace. Order is important so add it before the tap gesture
            .contentShape(Rectangle())
            .onTapGesture(perform: configuration.trigger)
    }
}

#Preview {
    FeedListView(viewModel: FeedViewModel(streamType: .home), path: NavigationPath())
}

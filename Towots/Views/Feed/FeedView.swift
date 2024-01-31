//
//  FeedView.swift
//  Towots
//
//  Created by りん on 27/1/2024.
//

import SwiftUI

import SwiftUI
import TootSDK

enum SelectionOptions: String, CaseIterable {
    case home
    case local
    case federated
}

struct FeedView: View {
    @EnvironmentObject var tootManager: TootManager
    
    @StateObject var timeLineHomeViewModel = FeedViewModel(streamType: .home)
    @StateObject var timeLineLocalViewModel = FeedViewModel(streamType: .local)
    @StateObject var timeLineFederatedViewModel = FeedViewModel(streamType: .federated)
    
    @State var selection: SelectionOptions = .home
    @State var name: String = ""
    @State var path: NavigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                switch selection {
                    case .home:
                        FeedListView(viewModel: timeLineHomeViewModel, path: path)
                    case .local:
                        FeedListView(viewModel: timeLineLocalViewModel, path: path)
                    case .federated:
                        FeedListView(viewModel: timeLineFederatedViewModel, path: path)
                }
            }
            .refreshable {
                try? await timeLineHomeViewModel.refresh()
                try? await timeLineLocalViewModel.refresh()
                try? await timeLineFederatedViewModel.refresh()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker("Select your feed", selection: $selection) {
                        ForEach(SelectionOptions.allCases, id: \.self) {
                            Text($0.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(.segmented)
                    .fixedSize()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("lmao", action: {})
                        Button("edit the lists??", action: {})
                        Button("idk what this", action: {})
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
            .navigationTitle("Feed")
        }
    }
}

#Preview {
    FeedView()
}

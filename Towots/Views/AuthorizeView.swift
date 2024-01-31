//
//  AuthorizeView.swift
//  Towots
//
//  Created by りん on 27/1/2024.
//

import AuthenticationServices
import SwiftUI
import TootSDK

struct AuthorizeView: View {
    @EnvironmentObject var tootManager: TootManager

    @State var urlString: String = ""
    @State var signInDisabled: Bool = false

    var body: some View {
        VStack {
            Spacer()
            
            
            Image("KidNamedTowots")
                .resizable()
                .frame(maxWidth: .infinity)
            Text("Towots")
                .font(.largeTitle.bold())
            Text("(Pronounced tuwuts)")
                .font(.subheadline).foregroundStyle(.secondary)
            
            Spacer()
            
            Text("Login to delete life!")
            
            Form {
                TextField("https://instance.tld", text: $urlString) // probably have a list of popular instances and the ability to type in your own (also make sure to remind user what platforms are compatible on this page!)
                    .autocorrectionDisabled(true)
                    .autocapitalization(.none)
            }
            
            Button {
                Task {
                    do {
                        try await attemptSignIn()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            } label: {
                Text("Sign in")
            }
            .disabled(signInDisabled)
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
            
            Spacer()
        }
        .onChange(of: urlString) {
            signInDisabled = urlString.isEmpty
        }
    }
}

extension AuthorizeView {
    @MainActor func attemptSignIn() async throws {
        guard let url = URL(string: urlString) else { return }
        try await tootManager.createClientAndPresentSignIn(url)
    }
}

#Preview {
    AuthorizeView()
}

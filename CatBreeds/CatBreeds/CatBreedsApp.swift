//
//  CatBreedsApp.swift
//  CatBreeds
//
//  Created by Filipe Santos on 01/07/2024.
//

import Network
import SwiftUI

@main
struct CatBreedsApp: App {
    @State var client = Client(
        apiHost: "api.thecatapi.com",
        apiKey: Config.apiKey,
        urlSession: .shared
    )

    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationView {
                    BreedsView(client: client)
                }
                .tabItem {
                    Label("Breeds", systemImage: "cat")
                }

                FavouritesView(client: client)
                    .tabItem {
                        Label("Favourites", systemImage: "heart")
                    }
            }
        }
    }
}

enum Config {
    static var apiKey: String {
        guard
            let object = Bundle.main.object(forInfoDictionaryKey: "API_KEY")
        else { fatalError("No Config.xcconfig configured") }

        guard
            let apiKey = object as? String
        else { fatalError("Invalid API_KEY format") }

        return apiKey
    }
}

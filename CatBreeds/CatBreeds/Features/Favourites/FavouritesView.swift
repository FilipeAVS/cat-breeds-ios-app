//
//  FavouritesView.swift
//  CatBreeds
//
//  Created by Filipe Santos on 01/07/2024.
//

import Network
import SwiftUI

final class FavouritesViewModel: ObservableObject {
    private let client: Client

    init(client: Client) {
        self.client = client
    }
}

struct FavouritesView: View {
    @StateObject private var viewModel: FavouritesViewModel

    init(client: Client) {
        self._viewModel = StateObject(wrappedValue: FavouritesViewModel(client: client))
    }

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

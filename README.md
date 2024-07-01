# Cat Breeds iOS App

## Overview

The Cat Breeds iOS App is a SwiftUI-based application that fetches cat breeds from the Cats API and displays them in a grid. Users can mark breeds as favorites or remove them from their favorites list. The app follows the MVVM (Model-View-ViewModel) architecture and is modularized into two frameworks for handling network and storage functionalities.

## Features

- Fetch and display cat breeds in a grid.
- Mark breeds as favorites.
- Remove breeds from favorites.
- Modular project structure with separate packages for network and storage.
- MVVM architecture for clear separation of concerns.

## Project Structure

- `CatBreeds`: The main application target.
- `Network`: Package responsible for network requests.
- `Storage`: Package responsible for data storage using SwiftData.

## Setup Instructions

1. **Clone the repository:**
    ```
    git clone https://github.com/FilipeAVS/cat-breeds-ios-app.git
    cd cat-breeds-ios-app
    ```

2. **API Key Configuration:**
    Create a `Config.xcconfig` file in the `cat-breeds-ios-app/CatBreeds/CatBreeds` directory with the following content:
    ```
    API_KEY=your_api_key
    ```
    Replace `your_api_key` with your actual API key from the Cats API.

3. **Open the project:**
    Open the `.xcodeproj` file in Xcode:
    ```
    open CatBreeds.xcodeproj
    ```

4. **Build and Run:**
    Select your target device or simulator and click on the `Run` button in Xcode.

## Usage

- **Viewing Cat Breeds:**
  On launching the app, you will see a grid of cat breeds fetched from the Cats API.

- **Marking as Favorite:**
  Tap on a breed to mark it as a favorite. A favorite icon will indicate the breed is added to your favorites list.

- **Removing from Favorites:**
  Tap on a favorite breed to remove it from your favorites list.

## Packages

### Newtork

This package is responsible for handling all network-related operations, including fetching data from the Cats API.

### Storage

This package is responsible for data storage, including saving and retrieving favorite cat breeds.

## MVVM Architecture

The app uses the MVVM architecture to ensure a clear separation of concerns:

- **Model:** Defines the data structures and business logic.
- **View:** Represents the UI components and layouts.
- **ViewModel:** Handles the presentation logic and communicates between the Model and View.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

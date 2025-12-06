# Swasthya+

Swasthya+ is a comprehensive mobile health application built with Flutter, designed to provide private, secure, and empowering health resources for teenagers. The app offers a range of features from informational articles and AI-powered assistance to direct teleconsultation with medical and legal experts.

## Core Features

*   **Information Hub:** Browse and search a library of verified articles on crucial health topics, including menstrual health, contraception, sexual health, and mental wellness. Users can bookmark articles for easy access later.
*   **AI-Powered Chatbots:**
    *   **Juno AI:** A friendly medical assistant powered by Google's Gemini Pro. It answers health-related questions using a Retrieval-Augmented Generation (RAG) model based on the app's verified article database.
    *   **Serena AI:** An empathetic mental health companion designed to listen, validate feelings, and provide supportive guidance in a non-judgmental space.
*   **Teleconsultation:** Securely connect with doctors and legal advisors through one-on-one video calls, powered by the ZegoCloud SDK. The system generates unique room IDs for each session to ensure privacy.
*   **Clinic Locator:** Find nearby clinics and health centers using the device's GPS. The feature displays a list of clinics sorted by distance and provides an option to open directions in Google Maps.
*   **Period Tracker:** An integrated tool for users to log and predict their menstrual cycles. All data is stored locally on the device for privacy using `shared_preferences`.
*   **Legal Support:** A dedicated section to connect with a legal advisor specializing in healthcare law, the MTP Act, and patient privacy rights.

## Tech Stack

*   **Framework:** Flutter
*   **Backend & Database:** Firebase (Cloud Firestore for articles, doctors, and clinic data)
*   **AI & Chatbots:** Google Generative AI (Gemini)
*   **Video Calling:** ZegoCloud (`zego_uikit_prebuilt_call`)
*   **Location Services:** `geolocator`
*   **Local Storage:** `shared_preferences` for bookmarking and period tracker data
*   **Content Rendering:** `flutter_markdown_plus` for displaying article content

## Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

*   Flutter SDK installed on your machine.
*   An editor like VS Code or Android Studio.
*   A configured Firebase project.

### Installation

1.  **Clone the Repository**
    ```sh
    git clone https://github.com/hariiiiiiiii/docathon-app.git
    cd docathon-app
    ```

2.  **Configure Environment Variables**
    Create a `.env` file in the root of the project and add your API keys. This project uses keys for Google Generative AI and ZegoCloud.
    ```
    # .env
    API_KEY="YOUR_GOOGLE_GENERATIVE_AI_API_KEY"
    APP_ID="YOUR_ZEGO_CLOUD_APP_ID"
    APP_SIGN="YOUR_ZEGO_CLOUD_APP_SIGN"
    ```

3.  **Set up Firebase**
    *   Follow the FlutterFire CLI instructions to configure the app with your own Firebase project.
    *   Replace `ios/Runner/GoogleService-Info.plist` and `android/app/google-services.json` with the files from your Firebase project.

4.  **Install Dependencies**
    ```sh
    flutter pub get
    ```

5.  **Run the Application**
    ```sh
    flutter run
    ```

## Project Structure

The core logic of the application is located in the `lib/` directory:

*   `lib/main.dart`: The main entry point for the application, handles theme configuration and Firebase initialization.
*   `lib/screens/`: Contains all the UI screens for the application's features.
    *   `main_layout.dart`: The primary scaffold containing the bottom navigation bar and logic for switching between main screens.
    *   `home_screen.dart`: The main dashboard of the application.
    *   `rag_chatbot.dart`: Implementation of the "Juno AI" medical assistant.
    *   `mental_health.dart`: Implementation of the "Serena AI" companion.
    *   `articles_screen.dart`, `article_detail.dart`: UI for the Information Hub.
    *   `consultation_screen.dart`, `video_call_screen.dart`: UI and logic for video consultations.
    *   `referral_screen.dart`: The "Nearby Clinics" feature.
    *   `period_tracker.dart`: The UI and logic for the menstrual cycle tracker.
*   `lib/services/`: Contains helper services for interacting with backend and local storage.
    *   `firestore_service.dart`: A generic service for fetching data from Cloud Firestore.
    *   `bookmark_service.dart`: Manages adding, removing, and retrieving bookmarked articles using `shared_preferences`.
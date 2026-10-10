# flutter_application_1

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## ProofPath AI SOS functionality

The SOS flow now starts device-side evidence capture when SOS is activated:
- video recording from the rear camera (without camera audio)
- separate microphone audio recording
- high-accuracy GPS tracking with continuous updates
- real OpenStreetMap display in Safety Map and Live Location

The app stores captured evidence under the platform application-support directory. The supplied project did not contain an API/backend endpoint, so server-side evidence upload is intentionally not hard-coded to an unknown URL. Configure your backend endpoint when it is available.


# KhazimBox Documentation

## Description

**KhazimBox** is a Flutter-based educational game application designed to help users learn about fractions and division in an interactive and enjoyable manner. Users can mark boxes based on the questions provided, and the app gives immediate feedback on their answers.

## Features

- **User-Friendly Interface:** Intuitive design for easy navigation.
- **Randomized Questions:** Users encounter random questions involving fractions or decimals.
- **Interactive Feedback:** Instant feedback based on user responses.
- **Visual Effects:** Ripple effects when users mark boxes for engaging interaction.
- **Dynamic Slider:** Users can adjust the number of boxes displayed using a slider.

## Technical Overview

### Prerequisites

Before running the application, ensure you have:

- **Flutter SDK:** The framework used for building the app.
- **Dart SDK:** The programming language used within Flutter.

### Installation Instructions

1. **Clone the Repository:**
   Open your terminal and run:

   ```bash
   git clone https://github.com/username/khazimbox.git
   ```
2. **Navigate to Project Directory:**
   Change into the project directory:

   ```bash
   cd khazimbox
   ```

3. **Install Dependencies:**
   Use the following command to install all required dependencies:

   ```bash
   flutter pub get
   ```

### Running the Application

Once all dependencies are installed, launch the application with:

```bash
flutter run
```

This will start the app on your connected device or emulator.

### Code Structure

- **`main.dart`:** This is the entry point of the application, responsible for initializing the app and running the main widget.
- **`CanvasPainter`:** A custom class for rendering the boxes and handling the ripple effects on the canvas.
- **`SquareThumb`:** A widget that customizes the appearance and behavior of the slider used to adjust the number of boxes.


### User Experience

The app is designed to be engaging and educational, providing a fun way to learn mathematical concepts. The dynamic nature of the questions and the immediate feedback encourages users to practice more frequently.

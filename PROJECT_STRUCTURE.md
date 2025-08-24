# Project Structure

This document outlines the folder structure and organization of the Workshop Booking System Flutter app.

## Overview

The project follows Clean Architecture principles with clear separation of concerns across three main layers:

- **Presentation Layer**: UI components, screens, and state management
- **Domain Layer**: Business logic, entities, and repository interfaces
- **Data Layer**: Data sources, repository implementations, and external service integrations

## Folder Structure

```
lib/
├── core/                           # Core utilities and shared components
│   ├── constants/                  # App-wide constants
│   │   └── app_constants.dart
│   ├── config/                     # Configuration files
│   │   └── firebase_config.dart
│   ├── error/                      # Error handling
│   │   ├── exceptions.dart
│   │   ├── result.dart
│   │   └── error_handler.dart
│   └── utils/                      # Utility functions
│       └── logger.dart
│
├── domain/                         # Business logic layer
│   ├── entities/                   # Domain models
│   │   ├── user.dart
│   │   ├── workshop.dart
│   │   ├── time_slot.dart
│   │   ├── booking.dart
│   │   └── payment_info.dart
│   ├── repositories/               # Repository interfaces
│   │   ├── auth_repository.dart
│   │   ├── workshop_repository.dart
│   │   └── booking_repository.dart
│   └── usecases/                   # Business use cases (to be implemented)
│
├── data/                           # Data access layer
│   ├── models/                     # Data transfer objects
│   │   └── user_dto.dart
│   ├── services/                   # External service implementations
│   │   └── firebase_auth_service.dart
│   └── repositories/               # Repository implementations (to be implemented)
│
├── presentation/                   # UI layer
│   ├── theme/                      # App theming
│   │   └── app_theme.dart
│   ├── widgets/                    # Reusable UI components
│   │   └── common/
│   │       ├── app_button.dart
│   │       └── app_text_field.dart
│   ├── screens/                    # App screens (to be implemented)
│   └── providers/                  # State management (to be implemented)
│
└── main.dart                       # App entry point
```

## Layer Responsibilities

### Core Layer (`lib/core/`)

Contains shared utilities, constants, and configurations used across all layers:

- **Constants**: App-wide constants like collection names, API endpoints
- **Config**: Configuration classes for Firebase, themes, etc.
- **Error**: Centralized error handling with custom exceptions and Result pattern
- **Utils**: Utility functions like logging, validation, formatting

### Domain Layer (`lib/domain/`)

Contains the business logic and rules of the application:

- **Entities**: Pure Dart classes representing business objects
- **Repositories**: Abstract interfaces defining data access contracts
- **Use Cases**: Encapsulated business logic operations (to be implemented)

### Data Layer (`lib/data/`)

Handles data persistence and external service integration:

- **Models**: Data Transfer Objects (DTOs) for external APIs and databases
- **Services**: Implementations for external services (Firebase, payment gateways)
- **Repositories**: Concrete implementations of repository interfaces

### Presentation Layer (`lib/presentation/`)

Manages the user interface and user interactions:

- **Theme**: Material Design 3 theme configuration
- **Widgets**: Reusable UI components following design system
- **Screens**: Full-screen UI implementations
- **Providers**: State management using Provider pattern

## Design Patterns Used

### Clean Architecture
- Clear separation of concerns
- Dependency inversion principle
- Testable and maintainable code structure

### Repository Pattern
- Abstraction layer for data access
- Easy to mock for testing
- Flexible data source switching

### Result Pattern
- Explicit error handling
- Type-safe success/failure states
- Consistent error propagation

### Provider Pattern
- Reactive state management
- Efficient widget rebuilding
- Dependency injection

## File Naming Conventions

- **Files**: snake_case (e.g., `user_repository.dart`)
- **Classes**: PascalCase (e.g., `UserRepository`)
- **Variables/Functions**: camelCase (e.g., `getUserById`)
- **Constants**: SCREAMING_SNAKE_CASE (e.g., `API_BASE_URL`)

## Import Organization

Imports should be organized in the following order:

1. Dart core libraries
2. Flutter libraries
3. Third-party packages
4. Local imports (relative paths)

Example:
```dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../entities/user.dart';
import '../../core/error/result.dart';
```

## Testing Structure

Tests should mirror the main code structure:

```
test/
├── unit/
│   ├── domain/
│   ├── data/
│   └── core/
├── widget/
│   └── presentation/
└── integration/
```

## Next Steps

The following components will be implemented in subsequent tasks:

1. Use Cases for business logic
2. Repository implementations
3. State management providers
4. UI screens and navigation
5. Firebase service integrations
6. Testing suite
7. Performance optimizations
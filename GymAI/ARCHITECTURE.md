# AI Gym Coach Architecture

## Architecture Pattern

MVVM (Model - View - ViewModel)

SwiftUI is used for the UI layer.

---

# Project Structure

AI Gym Coach

├── App
│   ├── RootView
│   └── App Entry
│
├── Core
│   ├── Theme
│   ├── Navigation
│   ├── Extensions
│   └── Utilities
│
├── Features
│   ├── Dashboard
│   ├── Profile
│   ├── Workout
│   ├── Progress
│   └── Settings
│
├── Models
│
├── Services
│   ├── AI
│   ├── HealthKit
│   ├── Camera
│   ├── Storage
│   └── Network
│
├── Shared
│   ├── Components
│   ├── Assets
│   └── Helpers
│
└── Tests

---

# Design Principles

- Single Responsibility Principle
- Reusable Components
- Dependency Injection
- Protocol-Oriented Programming
- Testable Code
- Feature-Based Organization

---

# Naming Convention

Views:
- DashboardView
- ProfileView

ViewModels:
- DashboardViewModel
- ProfileViewModel

Models:
- UserProfile
- Workout
- Exercise

Services:
- AIService
- HealthKitService

---

# Navigation

App
→ RootView
→ Dashboard
→ Feature Screens

---

# Dependency Rule

Views
↓

ViewModels
↓

Services
↓

Models

No layer should directly bypass the layer beneath it.

---

# Git Workflow

Small Feature

↓

Build

↓

Test

↓

Commit

One logical change = one commit.

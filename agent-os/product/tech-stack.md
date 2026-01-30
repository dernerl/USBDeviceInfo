# Tech Stack

## Language

- **Swift** — primary language, aligned with the SupportApp codebase

## Frontend / UI

- **SwiftUI** — native macOS UI framework for modern, declarative interfaces
- Target: **macOS 14+** (aligned with SupportApp requirements)

## Backend

- **Azure** — cloud backend for future approval workflow and API integrations

## APIs & Integrations

- **IOKit / system_profiler** — macOS system frameworks for reading USB device information
- **SupportApp (Root3)** — Phase 1: launched via custom action button; Phase 2: Extension integration writing to `nl.root3.support.plist` via `defaults write`
- **CrowdStrike Falcon API** — Phase 3: automated device control exceptions

## Database

- N/A for MVP (device info is read live from macOS; history of last 5 devices may use local storage such as UserDefaults or a plist)

# Product Roadmap

## Phase 1: MVP — Standalone SwiftUI App

- Standalone native macOS SwiftUI app for reading USB device information
- List USB stick details when a device is connected to the MacBook (vendor, product, serial number in Falcon-compatible format)
- Show the last 5 USB devices that were connected to the Mac
- Native macOS GUI designed for the latest macOS version
- Can be launched from SupportApp via a custom action button

## Phase 2: SupportApp Extension Integration

- SupportApp Extension that displays at-a-glance USB info (e.g. currently connected device serial) directly in the SupportApp popover
- Script or Swift CLI writes USB data into the SupportApp plist via `defaults write`
- Extension serves as quick-view; button opens the full standalone app for details and history

## Phase 3: Automated Approval Workflow

- Automatic approval process that creates an exception in CrowdStrike Falcon Device Control for a USB stick via the Falcon API
- End-to-end self-service: user plugs in USB, requests approval, admin reviews, policy is updated automatically
- Azure backend for approval workflow and API orchestration

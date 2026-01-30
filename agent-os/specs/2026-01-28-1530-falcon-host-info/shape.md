# Falcon Host Info - Shaping Notes

## Context

User requested Falcon sensor information to be displayed alongside USB device info. The goal is to show the Falcon Agent ID (AID) for quick reference.

## Scope Decisions

### In Scope (Phase 1 MVP)
- Display Falcon Agent ID with copy button
- Show sensor operational status
- Show sensor version
- Graceful handling when Falcon is not installed

### Out of Scope
- Hostgroup information (requires Falcon API)
- Device Control Policy information (requires Falcon API)
- Privileged operations (no sudo elevation)
- Real-time sensor status updates

## Technical Decisions

### Data Source
Using `falconctl stats agent_info` command because:
- Available locally without API access
- Provides Agent ID, version, and status
- No authentication required
- Standard location: `/Applications/Falcon.app/Contents/Resources/falconctl`

### Error Handling
- Return `nil` if Falcon not installed (app not at expected path)
- Return `nil` if command fails (permission denied, etc.)
- Return `nil` if output cannot be parsed
- UI shows "unavailable" state gracefully

### UI Placement
- Between HostInfoSection and ConnectedDevicesSection
- Follows same card styling as HostInfoSection
- Hidden entirely if Falcon not detected (no empty section shown)

## Constraints

- macOS only (Falcon sensor is platform-specific)
- Read-only (no sensor control or configuration)
- User-space permissions only

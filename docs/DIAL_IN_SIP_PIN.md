# Dial-In SIP Pin Feature

## Overview
Implements automatic generation and display of Dial-In SIP PINs for room creation in Greenlight. The PIN (6-digit number) is generated on room creation and can be accessed by owners and admins.

## Changes Made

### Database Migration
- **File**: `db/migrate/20260611000000_add_dial_in_pin_to_rooms.rb`
- Adds `dial_in_pin` column (string) to `rooms` table
- Creates unique index on `dial_in_pin` column
- Initial value: `NULL` (for backward compatibility)

### Room Model Updates
- **File**: `app/models/room.rb`
- Added validation for `dial_in_pin` (6-digit, numeric, unique)
- Added `set_dial_in_pin` callback to generate PIN on room creation
- PIN format: 6-digit zero-padded number (000000-999999)
- Retry mechanism to handle collisions

### BigBlueButton Integration
- **File**: `app/services/meeting_starter.rb`
- Added `dial_in_pin` to meeting metadata as `meta_dial-in-pin`
- PIN included in moderator welcome message
- PIN passed to BigBlueButton API for SIP configuration

## PIN Generation Logic
```ruby
pin = SecureRandom.random_number(1_000_000).to_s.rjust(6, '0')
```

## Security Considerations
- **Access Control**: PIN visible only to room owner and admins
- **Uniqueness**: Database constraint ensures PIN uniqueness
- **Randomness**: Uses `SecureRandom` for cryptographic randomness
- **No Modification**: PIN is set only once on room creation

## Next Steps
1. Create UI components to display PIN after room creation
2. Add PIN copy-to-clipboard functionality
3. Add PIN regeneration option (optional, for advanced use)
4. Add i18n string for dial_in_pin message
5. Create tests for PIN generation and validation
6. API endpoint to retrieve PIN (only for authorized users)

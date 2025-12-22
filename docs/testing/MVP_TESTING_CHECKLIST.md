# 🧪 Football Coaches App - MVP Testing Checklist

**Project:** Football Coaches App MVP  
**Version:** 0.1.0+1  
**Testing Date:** December 6, 2025  
**Objective:** Comprehensive functional testing of all MVP features before new development

---

## 📋 Table of Contents

1. [Pre-Testing Setup](#pre-testing-setup)
2. [Test Environments](#test-environments)
3. [Authentication & Authorization (RBAC)](#authentication--authorization-rbac)
4. [UI/UX & Material 3 Compliance](#uiux--material-3-compliance)
5. [Teams Management](#teams-management)
6. [Players Management](#players-management)
7. [Tournaments](#tournaments)
8. [Friendly Matches](#friendly-matches)
9. [Venues Management](#venues-management)
10. [Live Match & Timeline Events](#live-match--timeline-events)
11. [Push Notifications](#push-notifications)
12. [Integration Testing](#integration-testing)
13. [Performance & Stability](#performance--stability)
14. [Automated Test Suite](#automated-test-suite)
15. [Sign-Off & Report](#sign-off--report)

---

## Pre-Testing Setup

### System Requirements
- [ ] Flutter 3.0+ installed
- [ ] Android SDK (API 28+) or iOS 12.0+
- [ ] Device/Emulator available for testing
- [ ] Backend mock service running or mock enabled in code
- [ ] Firebase emulator running (if needed)

### Code Verification
- [ ] All dependencies installed: `flutter pub get`
- [ ] Code compiles without errors: `flutter analyze`
- [ ] No breaking changes in main branch
- [ ] All files have been saved and committed

### Environment Configuration
```bash
# From mobile_flutter directory
cd mobile_flutter

# Verify environment
flutter doctor
flutter pub get
flutter analyze

# Check mock service is enabled
# In lib/main.dart: AuthService.instance.setUseMock(true);
```

### Device Setup
```bash
# Start emulator (Android)
emulator -avd Pixel_5_API_30

# OR list available devices
flutter devices

# Run app
flutter run
```

---

## Test Environments

### Environment 1: Development (Recommended for Testing)
- **Mock Service:** Enabled
- **Backend:** Not required
- **Firebase:** Emulator or mock
- **Notifications:** Mock FCM support
- **Use Case:** Full feature testing without backend

### Environment 2: Backend Integration (Optional)
- **Mock Service:** Disabled
- **Backend:** Running on localhost:5000
- **Firebase:** Real project
- **Notifications:** Real FCM
- **Use Case:** Backend integration verification

### Environment 3: Production Simulation
- **Mock Service:** Disabled
- **Backend:** Production server
- **Firebase:** Production project
- **Notifications:** Real FCM
- **Use Case:** Pre-release validation

---

## Authentication & Authorization (RBAC)

### Login Screen (`/login`)

#### T1.1 Basic Login Flow
- [ ] **Navigation:** App starts → Redirected to `/login`
- [ ] **UI Elements Present:**
  - [ ] App logo/title visible
  - [ ] Email input field
  - [ ] Password input field
  - [ ] "Sign In" button
  - [ ] "Create Account" link
  - [ ] Material 3 styling applied
  - [ ] Proper spacing and typography

- [ ] **Input Validation:**
  - [ ] Empty email shows error: "Please enter your email"
  - [ ] Invalid email format shows error: "Please enter a valid email"
  - [ ] Empty password shows error: "Please enter a password"
  - [ ] Both fields can't be submitted empty

- [ ] **Successful Login:**
  - [ ] Enter email: `coach@example.com`
  - [ ] Enter password: `password123`
  - [ ] Click "Sign In"
  - [ ] Loading indicator appears
  - [ ] Redirects to `/onboarding` (if first time) OR `/` (if completed)
  - [ ] Navigation success message or no errors

- [ ] **Invalid Credentials:**
  - [ ] Enter email: `invalid@example.com`
  - [ ] Enter password: `wrongpassword`
  - [ ] Click "Sign In"
  - [ ] Error message displays: "Invalid credentials"
  - [ ] Stay on login screen
  - [ ] Can retry

- [ ] **Network Error Simulation:**
  - [ ] Disable internet (if testing real backend)
  - [ ] Click "Sign In"
  - [ ] Error message displays: "Network error, please try again"
  - [ ] Retry button or auto-retry works

#### T1.2 Register Screen (`/register`)
- [ ] **Navigation:** Click "Create Account" from login
- [ ] **UI Elements:**
  - [ ] Name input field
  - [ ] Email input field
  - [ ] Password input field
  - [ ] Confirm password field
  - [ ] Role selector (dropdown or chips)
  - [ ] "Register" button
  - [ ] "Back to Login" link

- [ ] **Input Validation:**
  - [ ] Name must be 3+ characters
  - [ ] Email must be valid format
  - [ ] Password must be 8+ characters
  - [ ] Passwords must match
  - [ ] Error messages appear inline

- [ ] **Successful Registration:**
  - [ ] Name: `John Coach`
  - [ ] Email: `john.coach@example.com`
  - [ ] Password: `SecurePass123`
  - [ ] Role: `coach`
  - [ ] Click "Register"
  - [ ] Success message: "Account created successfully"
  - [ ] Auto-login happens
  - [ ] Redirected to onboarding

- [ ] **Duplicate Email:**
  - [ ] Use existing email from previous test
  - [ ] Error: "Email already registered"
  - [ ] Stay on register screen

#### T1.3 Onboarding Screen (`/onboarding`)
- [ ] **Entry Point:** After login as new user
- [ ] **UI Elements:**
  - [ ] Welcome message
  - [ ] Step indicator (1/n)
  - [ ] Step-specific content
  - [ ] "Next" button
  - [ ] "Skip" button (if applicable)
  - [ ] Progress bar

- [ ] **Complete Onboarding:**
  - [ ] Step 1: Accept Terms & Conditions
    - [ ] Checkbox to accept
    - [ ] "Continue" button enabled after check
  - [ ] Step 2: Select Primary Role (if not auto-filled)
    - [ ] Options: Coach, Player, Admin, Referee, Fan
    - [ ] Selection highlights properly
    - [ ] "Continue" works
  - [ ] Step 3: Set Active Club (if available)
    - [ ] Club list loads
    - [ ] Can select club
    - [ ] Selection saves
  - [ ] Step 4: Profile Completion
    - [ ] Can upload avatar (skip if not implemented)
    - [ ] Can set bio
    - [ ] "Finish" completes onboarding
  - [ ] Redirects to home screen

- [ ] **Skip Options:**
  - [ ] Skip button (if present) goes to next step or home
  - [ ] All fields marked as skipped

### Onboarding Complete - Role-Based Navigation
After login, test each role's dashboard access:

#### T1.4 Coach Role Features
- [ ] **Accessible Tabs (in HomeScreen):**
  - [ ] ✅ Inicio (Home)
  - [ ] ✅ Equipo (Team)
  - [ ] ✅ Amistosos (Friendly Matches)
  - [ ] ✅ Torneos (Tournaments)
  - [ ] ✅ Chat
  - [ ] ✅ Perfil (Profile)

- [ ] **Restricted Features:**
  - [ ] ❌ Cannot access admin panel (if exists)
  - [ ] ❌ Cannot access referee console (if exists)

#### T1.5 Player Role Features
- [ ] **Accessible Tabs:**
  - [ ] ✅ Inicio (Home)
  - [ ] ✅ Equipo (Team - view only)
  - [ ] ✅ Amistosos (Friendly Matches)
  - [ ] ✅ Chat
  - [ ] ✅ Perfil (Profile)

- [ ] **Restricted Features:**
  - [ ] ❌ Cannot create tournaments
  - [ ] ❌ Cannot add players to team
  - [ ] ❌ Cannot edit match events

#### T1.6 Club Admin Role Features
- [ ] **Accessible Tabs:**
  - [ ] ✅ All tabs
  - [ ] ✅ Venue management
  - [ ] ✅ User management

#### T1.7 Referee Role Features
- [ ] **Accessible Tabs:**
  - [ ] ✅ Inicio (Home)
  - [ ] ✅ Torneos (Tournaments - view)
  - [ ] ✅ Amistosos (Friendly Matches)
  - [ ] ✅ Perfil (Profile)

- [ ] **Special Features:**
  - [ ] ✅ Can manage match events (goals, cards)
  - [ ] ✅ Access to live match controls

#### T1.8 Fan Role Features
- [ ] **Accessible Tabs:**
  - [ ] ✅ Inicio (Home)
  - [ ] ✅ Amistosos (Friendly Matches - view)
  - [ ] ✅ Torneos (Tournaments - view)
  - [ ] ✅ Chat
  - [ ] ✅ Perfil (Profile)

- [ ] **Restricted Features:**
  - [ ] ❌ Cannot manage teams
  - [ ] ❌ Cannot create events
  - [ ] ❌ Cannot edit anything

#### T1.9 Super Admin Role Features
- [ ] **Accessible Tabs:**
  - [ ] ✅ All tabs for all roles
  - [ ] ✅ System administration (if exists)
  - [ ] ✅ User management
  - [ ] ✅ Report generation

### T1.10 Logout Flow
- [ ] **In Home Screen:**
  - [ ] Click logout button (top-right icon)
  - [ ] Confirmation dialog appears
  - [ ] Confirm logout
  - [ ] Redirected to login screen
  - [ ] User token cleared from storage
  - [ ] Cannot access home screen directly

- [ ] **Session Persistence:**
  - [ ] Login as coach
  - [ ] Close app completely
  - [ ] Reopen app
  - [ ] Should restore session (go to home screen, not login)
  - [ ] Token is still valid

---

## UI/UX & Material 3 Compliance

### T2.1 Theme Consistency
- [ ] **Color Scheme:**
  - [ ] Primary color: `#0E7C61` (seed color) ✓
  - [ ] AppBar background: Transparent with proper elevation
  - [ ] Cards: White background with subtle shadow
  - [ ] Text primary: `#102A43` (dark)
  - [ ] Text secondary: `#486581` (medium gray)
  - [ ] Dividers: Subtle black with alpha ~0.06

- [ ] **Typography:**
  - [ ] Display titles: Large, bold (weight 700)
  - [ ] Title Medium: Proper hierarchy
  - [ ] Body Medium: Readable size (~16sp)
  - [ ] Label Medium: For buttons and chips
  - [ ] Consistent across all screens

- [ ] **Spacing & Layout:**
  - [ ] Cards: Margin = 0, no gap
  - [ ] List items: 16px padding
  - [ ] Section padding: 16px horizontal
  - [ ] Border radius: Consistent 16-20px
  - [ ] Chip padding: 12px horizontal, 8px vertical

### T2.2 Material 3 Components
- [ ] **Buttons:**
  - [ ] Elevated buttons: Proper shadow
  - [ ] Filled buttons: Primary color
  - [ ] Outlined buttons: Border color correct
  - [ ] Text buttons: No background
  - [ ] FAB: Rounded shape (not circle), proper size

- [ ] **Input Fields:**
  - [ ] Border color: Subtle black ~0.06
  - [ ] Focus border: Primary color ~0.5 opacity, 1.5 width
  - [ ] Label style: Proper color and size
  - [ ] Hint text: Lighter color
  - [ ] Content padding: 16px horizontal, 14px vertical
  - [ ] Border radius: 16px

- [ ] **Cards:**
  - [ ] Background: White
  - [ ] Elevation: 0 (flat design)
  - [ ] Border radius: 20px
  - [ ] Proper spacing inside

- [ ] **Navigation:**
  - [ ] Bottom navigation bar: White background
  - [ ] Selected indicator: Primary color @ 12% opacity
  - [ ] Labels: Bold (weight 600)
  - [ ] Icons: Proper size and color

- [ ] **Badges:**
  - [ ] Notification badge: Error color (red)
  - [ ] Proper size for count display
  - [ ] Positioned correctly in corner

### T2.3 Responsive Design
- [ ] **Phone (360px width):**
  - [ ] All content fits without horizontal scroll
  - [ ] Text readable
  - [ ] Buttons large enough to tap (48px)
  - [ ] No overlapping elements

- [ ] **Tablet (600px+ width):**
  - [ ] Layout adapts properly
  - [ ] Two-column layouts if applicable
  - [ ] Proper use of screen space
  - [ ] Not stretched

- [ ] **Screen Rotation:**
  - [ ] App handles rotation smoothly
  - [ ] No crashes on orientation change
  - [ ] UI layout adapts
  - [ ] Form inputs preserve data

### T2.4 Dark/Light Mode (if implemented)
- [ ] **Light Mode:**
  - [ ] Colors display correctly
  - [ ] Text readable
  - [ ] No harsh contrasts

- [ ] **Dark Mode (if supported):**
  - [ ] Color scheme inverts properly
  - [ ] Text visible
  - [ ] Cards have proper contrast

### T2.5 Accessibility
- [ ] **Touch Targets:**
  - [ ] All buttons: 48px minimum
  - [ ] All interactive elements: Tappable
  - [ ] Spacing between buttons: Adequate

- [ ] **Text Contrast:**
  - [ ] Text on light background: Dark color
  - [ ] Text on dark background: Light color
  - [ ] Meets WCAG AA standard (4.5:1 ratio)

---

## Teams Management

### T3.1 View Teams List
- [ ] **Navigation:** Home → Click "Equipo" tab
- [ ] **Screen Elements:**
  - [ ] AppBar with title "Equipo"
  - [ ] Team list displays
  - [ ] Each team shows: Name, Badge/Logo (if available), Member count
  - [ ] Cards have proper Material 3 styling
  - [ ] No errors in console

- [ ] **Empty State (if no teams):**
  - [ ] Message: "No teams yet"
  - [ ] "Create Team" button visible and prominent
  - [ ] Proper Material 3 design for empty state

- [ ] **Loaded State (if teams exist):**
  - [ ] List shows 3+ mock teams (if available)
  - [ ] Teams scroll smoothly
  - [ ] Each team clickable

### T3.2 Create Team (Coach only)
- [ ] **Access Control:**
  - [ ] Login as Coach → Can see "+" button or "Create Team"
  - [ ] Login as Player → Cannot create
  - [ ] Login as Fan → Cannot create

- [ ] **Create Team Dialog/Screen:**
  - [ ] Click "Create Team" button
  - [ ] Dialog/Form opens with fields:
    - [ ] Team Name (text input)
    - [ ] Sport Type (dropdown: Football, etc.)
    - [ ] Home Venue (dropdown or selector)
    - [ ] Manager Name (pre-filled with current user)
    - [ ] Color/Badge (if applicable)
    - [ ] Cancel & Create buttons

- [ ] **Validation:**
  - [ ] Team Name: Required, 3+ characters
  - [ ] Sport Type: Required
  - [ ] Error messages inline
  - [ ] Submit button disabled until valid

- [ ] **Successful Creation:**
  - [ ] Enter: `Test Team 2025`
  - [ ] Select Sport: `Football`
  - [ ] Select Venue: Any available
  - [ ] Click "Create"
  - [ ] Loading indicator
  - [ ] Team appears in list
  - [ ] Success toast: "Team created successfully"
  - [ ] Can navigate to team detail

- [ ] **Duplicate Name:**
  - [ ] Try creating team with existing name
  - [ ] Error: "Team with this name already exists"
  - [ ] Stay in form

### T3.3 Edit Team (Coach only)
- [ ] **Access Control:**
  - [ ] Coach who created team: Can edit
  - [ ] Other Coach: Cannot edit (if RBAC enforced)
  - [ ] Player: Cannot edit

- [ ] **Edit Flow:**
  - [ ] Click on team card
  - [ ] View team detail screen
  - [ ] Click "Edit" button
  - [ ] Form pre-filled with current values
  - [ ] Modify team name: `Test Team Updated`
  - [ ] Save changes
  - [ ] List updates
  - [ ] Success message

- [ ] **Cancel Edit:**
  - [ ] Click "Edit"
  - [ ] Make changes
  - [ ] Click "Cancel"
  - [ ] Changes discard
  - [ ] Back to detail view

### T3.4 Delete Team (Coach only)
- [ ] **Delete Flow:**
  - [ ] Open team detail
  - [ ] Click "Delete" button
  - [ ] Confirmation dialog: "Are you sure? This cannot be undone."
  - [ ] Cancel → Dialog closes, team remains
  - [ ] Confirm → Team deleted
  - [ ] Returns to list
  - [ ] Team no longer appears
  - [ ] Success message

- [ ] **Cannot Delete if:**
  - [ ] Team has ongoing matches (if implemented)
  - [ ] Team has players (if enforced)

### T3.5 Team Detail View
- [ ] **Team Information:**
  - [ ] Team name prominently displayed
  - [ ] Logo/badge (if applicable)
  - [ ] Creation date
  - [ ] Manager/Coach info
  - [ ] Member count

- [ ] **Tabs/Sections:**
  - [ ] Overview
  - [ ] Players
  - [ ] Matches
  - [ ] Statistics (if implemented)

- [ ] **Players Tab:**
  - [ ] Shows all team members
  - [ ] Each player card: Name, Number (if applicable), Position
  - [ ] Coach can add/remove players
  - [ ] Player can view but not edit

- [ ] **Matches Tab:**
  - [ ] Shows upcoming and past matches
  - [ ] Sorted by date
  - [ ] Quick access to match details

---

## Players Management

### T4.1 View Players List
- [ ] **Navigation:** Home → Click "Equipo" → Click "Players" tab/section
- [ ] **Player List:**
  - [ ] Displays all players in team
  - [ ] Each player card shows: Name, Number, Position, Status (Active/Inactive)
  - [ ] Avatar/icon if available
  - [ ] Cards are clickable
  - [ ] Material 3 styling consistent

- [ ] **Empty State:**
  - [ ] If no players: "No players in this team"
  - [ ] "Add Player" button visible

- [ ] **Search/Filter (if implemented):**
  - [ ] Search by name works
  - [ ] Filter by position works
  - [ ] Filter by status works

### T4.2 Add Player (Coach only)
- [ ] **Access Control:**
  - [ ] Coach: Can add
  - [ ] Player: Cannot add
  - [ ] Fan: Cannot add

- [ ] **Add Player Dialog:**
  - [ ] Click "Add Player" button
  - [ ] Form opens with fields:
    - [ ] Player Name (text input)
    - [ ] Jersey Number (numeric, 1-99)
    - [ ] Position (dropdown: Goalkeeper, Defender, Midfielder, Forward)
    - [ ] Date of Birth (date picker)
    - [ ] Status (dropdown: Active, Inactive, Injured)
    - [ ] Avatar upload (optional)

- [ ] **Validation:**
  - [ ] Name: Required, 3+ characters
  - [ ] Number: Required, 1-99, unique in team
  - [ ] Position: Required
  - [ ] DOB: Must be valid past date
  - [ ] Error messages inline

- [ ] **Successful Addition:**
  - [ ] Name: `Carlos Silva`
  - [ ] Number: `10`
  - [ ] Position: `Forward`
  - [ ] DOB: `1998-05-15`
  - [ ] Status: `Active`
  - [ ] Click "Add"
  - [ ] Loading indicator
  - [ ] Player appears in list
  - [ ] Success message

- [ ] **Duplicate Number:**
  - [ ] Try adding player with existing number
  - [ ] Error: "Player number already in use"
  - [ ] Form stays open

### T4.3 Edit Player (Coach only)
- [ ] **Edit Flow:**
  - [ ] Click on player card
  - [ ] View player detail
  - [ ] Click "Edit" button
  - [ ] Form pre-filled with current data
  - [ ] Modify position: Change from `Forward` to `Midfielder`
  - [ ] Modify status: `Inactive` (injured)
  - [ ] Save
  - [ ] Player list updates
  - [ ] Success message

- [ ] **Cannot Edit Number:**
  - [ ] Try to change jersey number
  - [ ] Number field disabled (if implemented)
  - [ ] Or allow change with duplicate validation

### T4.4 Delete Player (Coach only)
- [ ] **Delete Flow:**
  - [ ] Open player detail
  - [ ] Click "Delete" button
  - [ ] Confirmation: "Remove player from team?"
  - [ ] Confirm → Player removed
  - [ ] Removed from list
  - [ ] Success message

### T4.5 Player Detail View
- [ ] **Information Displayed:**
  - [ ] Full name, number, position
  - [ ] Date of birth / Age
  - [ ] Status (Active/Inactive)
  - [ ] Avatar
  - [ ] Joined date
  - [ ] Statistics (if available):
    - [ ] Goals scored
    - [ ] Appearances
    - [ ] Cards (yellow/red)

- [ ] **Action Buttons:**
  - [ ] Coach: Edit, Delete
  - [ ] Player: View only (or edit own profile if allowed)

### T4.6 Player Statistics (if implemented)
- [ ] **Season Statistics:**
  - [ ] Goals
  - [ ] Assists
  - [ ] Appearances
  - [ ] Minutes played
  - [ ] Yellow cards
  - [ ] Red cards

- [ ] **Statistics Update:**
  - [ ] Manually updated by coach
  - [ ] Auto-updated from match events (if implemented)
  - [ ] Historical data preserved

---

## Tournaments

### T5.1 View Tournaments List
- [ ] **Navigation:** Home → Click "Torneos" tab
- [ ] **List Display:**
  - [ ] Shows all tournaments
  - [ ] Filters visible (Optional - upcoming/past)
  - [ ] Each tournament card shows:
    - [ ] Name
    - [ ] Type (League/Knockout)
    - [ ] Status (Ongoing/Completed/Scheduled)
    - [ ] Number of teams
    - [ ] Start date
  - [ ] Cards are clickable
  - [ ] Material 3 styling applied

- [ ] **Empty State:**
  - [ ] If no tournaments: "No tournaments"
  - [ ] "Create Tournament" button (if coach)

- [ ] **Filtering (if implemented):**
  - [ ] Show Upcoming: Only future tournaments
  - [ ] Show Ongoing: Only active tournaments
  - [ ] Show Completed: Only past tournaments

### T5.2 Create Tournament (Coach/Admin only)
- [ ] **Access Control:**
  - [ ] Coach: Can create
  - [ ] Admin: Can create
  - [ ] Player: Cannot create
  - [ ] Fan: Cannot create

- [ ] **Create Tournament Flow:**
  - [ ] Click "Create Tournament"
  - [ ] Form opens with:
    - [ ] Tournament Name (text)
    - [ ] Type (dropdown: League or Knockout)
    - [ ] Start Date (date picker)
    - [ ] End Date (date picker)
    - [ ] Number of Teams (numeric)
    - [ ] Description (optional text area)
    - [ ] Venue (if applicable)

- [ ] **Validation:**
  - [ ] Name: Required, 5+ characters
  - [ ] Type: Required
  - [ ] Start Date: Must be future
  - [ ] End Date: Must be after Start Date
  - [ ] Teams: 4+ required
  - [ ] Error messages inline

- [ ] **Successful Creation - League Type:**
  - [ ] Name: `City Football League 2025`
  - [ ] Type: `League`
  - [ ] Start: `2025-01-15`
  - [ ] End: `2025-06-30`
  - [ ] Teams: `8`
  - [ ] Click "Create"
  - [ ] Loading indicator
  - [ ] Redirects to tournament detail
  - [ ] Success message

- [ ] **Successful Creation - Knockout Type:**
  - [ ] Name: `City Cup 2025`
  - [ ] Type: `Knockout`
  - [ ] Start: `2025-02-01`
  - [ ] End: `2025-03-31`
  - [ ] Teams: `8`
  - [ ] Click "Create"
  - [ ] Tournament created
  - [ ] Bracket/stages displayed (if implemented)

### T5.3 Tournament Detail - League View
- [ ] **Tabs/Sections:**
  - [ ] ✅ Overview
  - [ ] ✅ Standings/Table
  - [ ] ✅ Matches
  - [ ] ✅ Teams
  - [ ] ✅ Rules/Info (if applicable)

- [ ] **Overview Tab:**
  - [ ] Tournament name, dates, status
  - [ ] Description
  - [ ] Key stats (teams, matches played)
  - [ ] Edit button (if owner)

- [ ] **Standings Table:**
  - [ ] Shows all teams in standings order
  - [ ] Columns: Position, Team Name, Played, Won, Drawn, Lost, Points
  - [ ] Sorted by points descending
  - [ ] Color coding for promotion/relegation (if applicable)
  - [ ] Proper Material 3 table design

- [ ] **Matches Tab:**
  - [ ] Shows all tournament matches
  - [ ] Grouped by matchday (if league)
  - [ ] Each match shows: Teams, Date, Time, Score (if finished), Status
  - [ ] Can click to view details
  - [ ] Upcoming matches highlighted

- [ ] **Teams Tab:**
  - [ ] Shows all participating teams
  - [ ] Team cards with info
  - [ ] Can click for team detail

### T5.4 Tournament Detail - Knockout View
- [ ] **Bracket Display:**
  - [ ] Initial round bracket shown
  - [ ] Teams seeded properly (if applicable)
  - [ ] Match cards in bracket format
  - [ ] Advancement shown (winners advance)
  - [ ] Semi-finals and finals visible

- [ ] **Match Navigation:**
  - [ ] Can click any match in bracket
  - [ ] Match detail opens with full info
  - [ ] Can go back to bracket

- [ ] **Progression:**
  - [ ] Final completed
  - [ ] Winner displayed prominently
  - [ ] Trophy icon or medal display

### T5.5 Edit Tournament (Owner/Admin only)
- [ ] **Edit Flow:**
  - [ ] Open tournament detail
  - [ ] Click "Edit" button (if visible)
  - [ ] Form pre-filled with current data
  - [ ] Can edit: Name, description, dates (if future)
  - [ ] Cannot edit: Type (if matches started)
  - [ ] Save changes
  - [ ] Detail view updates
  - [ ] Success message

### T5.6 Delete Tournament (Owner/Admin only)
- [ ] **Delete Restrictions:**
  - [ ] Cannot delete if matches exist (if enforced)
  - [ ] Can delete if no matches
  - [ ] Confirmation dialog required

- [ ] **Delete Flow:**
  - [ ] Click "Delete"
  - [ ] Warning: "Delete tournament? Cannot be undone."
  - [ ] Confirm
  - [ ] Tournament removed
  - [ ] Back to tournament list
  - [ ] Success message

### T5.7 Add Teams to Tournament (Coach/Admin)
- [ ] **Initial Setup:**
  - [ ] Create tournament
  - [ ] "Add Teams" dialog appears
  - [ ] Shows available teams (those not in tournament)
  - [ ] Can select multiple teams
  - [ ] Add button to add selected
  - [ ] Teams appear in Teams tab

- [ ] **Add More Teams:**
  - [ ] Tournament ongoing
  - [ ] Can add teams (if league, not knockout)
  - [ ] New teams get 0 points
  - [ ] Standings update

- [ ] **Remove Team (if allowed):**
  - [ ] Click team in tournament
  - [ ] "Remove from tournament" option
  - [ ] Confirmation
  - [ ] Team removed
  - [ ] Standings recalculated

---

## Friendly Matches

### T6.1 View Friendly Matches List
- [ ] **Navigation:** Home → Click "Amistosos" tab
- [ ] **Match List:**
  - [ ] Shows all friendly matches
  - [ ] Status filters visible (Optional: Upcoming/Ongoing/Completed)
  - [ ] Each match card shows:
    - [ ] Home Team vs Away Team
    - [ ] Date and Time
    - [ ] Status (Scheduled/Live/Completed)
    - [ ] Score (if completed)
    - [ ] Venue name
  - [ ] Material 3 styling

- [ ] **Empty State:**
  - [ ] If no matches: "No friendly matches scheduled"
  - [ ] "Create Match" button (if coach)

- [ ] **Filtering (if implemented):**
  - [ ] Upcoming matches highlighted
  - [ ] Completed matches grayed out
  - [ ] Live matches in bold/highlighted

### T6.2 Create Friendly Match (Coach only)
- [ ] **Access Control:**
  - [ ] Coach: Can create
  - [ ] Player: Cannot create
  - [ ] Fan: Cannot create

- [ ] **Create Match Dialog:**
  - [ ] Click "Create Friendly Match"
  - [ ] Form with fields:
    - [ ] Home Team (dropdown - teams managed by coach)
    - [ ] Away Team (dropdown - other teams or create opponent)
    - [ ] Match Date (date picker)
    - [ ] Match Time (time picker)
    - [ ] Venue (dropdown of available venues)
    - [ ] Notes (optional)

- [ ] **Validation:**
  - [ ] Home Team: Required
  - [ ] Away Team: Required, different from home team
  - [ ] Date: Must be future
  - [ ] Time: Required
  - [ ] Venue: Required
  - [ ] Error messages inline

- [ ] **Successful Creation:**
  - [ ] Home Team: `Test Team 2025`
  - [ ] Away Team: `Opponent FC`
  - [ ] Date: `2025-12-10`
  - [ ] Time: `19:00`
  - [ ] Venue: `Central Stadium`
  - [ ] Click "Create"
  - [ ] Match added to list
  - [ ] Status: "Scheduled"
  - [ ] Success message

- [ ] **Opponent Creation (if allowed):**
  - [ ] Select "Create New Team" for away team
  - [ ] Dialog opens to create opponent
  - [ ] Fill opponent name
  - [ ] Opponent created and added to match

### T6.3 Edit Friendly Match (Coach - before match)
- [ ] **Edit before Match:**
  - [ ] Open match detail
  - [ ] Click "Edit" button
  - [ ] Can edit: Date, Time, Venue, Notes (if before match start)
  - [ ] Cannot edit: Teams (if match started)
  - [ ] Save changes
  - [ ] List updates
  - [ ] Success message

- [ ] **Cannot Edit During/After Match:**
  - [ ] If match is live or completed
  - [ ] Edit button disabled or hidden

### T6.4 Delete Friendly Match (Coach - before match)
- [ ] **Delete Flow:**
  - [ ] Match must be scheduled (future)
  - [ ] Click "Delete"
  - [ ] Confirmation dialog
  - [ ] Confirm → Match removed
  - [ ] Removed from list
  - [ ] Success message

- [ ] **Cannot Delete:**
  - [ ] If match is live or completed
  - [ ] Delete button disabled

### T6.5 Friendly Match Detail View
- [ ] **Match Information:**
  - [ ] Home team name and logo
  - [ ] Away team name and logo
  - [ ] Match date and time
  - [ ] Venue information (address, capacity if available)
  - [ ] Current score (if started)
  - [ ] Match status badge

- [ ] **Match Status:**
  - [ ] Scheduled: Time until match shown
  - [ ] Live: "LIVE" badge, real-time updates
  - [ ] Completed: Final score, match summary

- [ ] **Tabs:**
  - [ ] Overview
  - [ ] Timeline (events)
  - [ ] Lineup (if available)
  - [ ] Stats (if available)

- [ ] **Timeline View:**
  - [ ] Shows events in chronological order
  - [ ] Events: Goals, Cards, Substitutions, Match Start/End
  - [ ] Each event shows: Time, Player, Action, Score update
  - [ ] Proper icons/colors for event types

---

## Venues Management

### T7.1 View Venues List
- [ ] **Navigation:** Home → Profile/Settings → Venues (or if Coach, might be in main menu)
- [ ] **Venues List Display:**
  - [ ] Shows all venues
  - [ ] Each venue card shows:
    - [ ] Venue name
    - [ ] City/Location
    - [ ] Capacity
    - [ ] Surface type (if applicable: Grass, Synthetic, etc.)
    - [ ] Status (Active/Inactive)
  - [ ] Material 3 styling
  - [ ] Clickable cards

- [ ] **Empty State:**
  - [ ] If no venues: "No venues available"
  - [ ] "Add Venue" button (if coach/admin)

- [ ] **Filtering (if implemented):**
  - [ ] Filter by city
  - [ ] Filter by surface type
  - [ ] Filter by capacity range

### T7.2 Create Venue (Coach/Admin only)
- [ ] **Access Control:**
  - [ ] Coach: Can create
  - [ ] Admin: Can create
  - [ ] Player: Cannot create
  - [ ] Fan: Cannot create

- [ ] **Create Venue Dialog:**
  - [ ] Click "Add Venue"
  - [ ] Form with fields:
    - [ ] Venue Name (text)
    - [ ] City/Location (text or dropdown)
    - [ ] Address (text)
    - [ ] Capacity (numeric)
    - [ ] Surface Type (dropdown: Grass, Synthetic, Indoor)
    - [ ] Lighting (toggle: Yes/No - if applicable)
    - [ ] Phone Number (optional)
    - [ ] Manager/Contact (optional)
    - [ ] Photos (optional upload)

- [ ] **Validation:**
  - [ ] Name: Required, 3+ characters
  - [ ] City: Required
  - [ ] Address: Required
  - [ ] Capacity: Required, >0
  - [ ] Surface: Required
  - [ ] Error messages inline

- [ ] **Successful Creation:**
  - [ ] Name: `Central Stadium`
  - [ ] City: `Madrid`
  - [ ] Address: `123 Stadium Lane, Madrid`
  - [ ] Capacity: `5000`
  - [ ] Surface: `Grass`
  - [ ] Lighting: Yes
  - [ ] Click "Create"
  - [ ] Venue added to list
  - [ ] Success message

- [ ] **Duplicate Name in Same City:**
  - [ ] Try creating venue with existing name
  - [ ] Error: "Venue already exists in this city"
  - [ ] Form stays open

### T7.3 Edit Venue (Coach/Admin)
- [ ] **Edit Flow:**
  - [ ] Click on venue card
  - [ ] View detail
  - [ ] Click "Edit" button
  - [ ] Form pre-filled
  - [ ] Modify: Name to `Central Stadium Updated`
  - [ ] Modify: Capacity to `6000`
  - [ ] Save
  - [ ] List updates
  - [ ] Success message

- [ ] **Cannot Edit:**
  - [ ] Name (if enforced immutable)
  - [ ] Or allow change with duplicate validation

### T7.4 Delete Venue (Coach/Admin)
- [ ] **Delete Restrictions:**
  - [ ] Cannot delete if venue has scheduled matches (if enforced)
  - [ ] Can delete if no matches

- [ ] **Delete Flow:**
  - [ ] Click "Delete"
  - [ ] Confirmation: "Delete venue? Associated matches will be affected."
  - [ ] Confirm → Deleted
  - [ ] Removed from list
  - [ ] Success message

### T7.5 Venue Detail View
- [ ] **Information:**
  - [ ] Venue name prominently
  - [ ] Location/address
  - [ ] Capacity
  - [ ] Surface type
  - [ ] Lighting available
  - [ ] Contact person (if available)
  - [ ] Phone number
  - [ ] Photos/images (if available)

- [ ] **Additional Info (if available):**
  - [ ] Upcoming matches at this venue
  - [ ] Recent matches hosted
  - [ ] Average attendance (if tracked)

- [ ] **Action Buttons:**
  - [ ] Coach/Admin: Edit, Delete
  - [ ] Player/Fan: View only

### T7.6 Location Service Integration
- [ ] **GPS/Location Features (if implemented):**
  - [ ] App requests location permission
  - [ ] Can see distance to venues
  - [ ] Venues sorted by distance
  - [ ] Map view (if available)
  - [ ] Navigation to venue (via Maps app)

- [ ] **Location Testing:**
  - [ ] Grant location permission
  - [ ] Venues sorted by nearest first
  - [ ] Disable location
  - [ ] Venues shown without distance
  - [ ] Re-enable location works

---

## Live Match & Timeline Events

### T8.1 Start/Begin Match
- [ ] **Navigation:** Open friendly match detail
- [ ] **Before Match:**
  - [ ] Match detail shows scheduled
  - [ ] Time remaining until match
  - [ ] "Start Match" button visible (if coach)
  - [ ] Other roles see "View" only

- [ ] **Start Match (Coach only):**
  - [ ] Click "Start Match" button
  - [ ] Match status changes to "Live"
  - [ ] Live badge appears
  - [ ] Real-time timer shows elapsed time
  - [ ] Can add events

### T8.2 Add Match Events (Referee/Coach)
- [ ] **Add Goal:**
  - [ ] Match is live
  - [ ] Click "Add Event" or goal button
  - [ ] Dialog: Select player, team, time
  - [ ] Enter: Goal by player `Carlos Silva` for `Test Team`
  - [ ] Confirm
  - [ ] Goal appears in timeline
  - [ ] Score updates in match header
  - [ ] Live toast notification appears

- [ ] **Add Yellow Card:**
  - [ ] Select player from team
  - [ ] Click "Add Yellow Card"
  - [ ] Card appears in timeline
  - [ ] Player card count increments
  - [ ] Player highlighted in UI

- [ ] **Add Red Card:**
  - [ ] Select player
  - [ ] Click "Add Red Card"
  - [ ] Red card in timeline
  - [ ] Player marked as sent off
  - [ ] Team shows reduced players (if tracked)

- [ ] **Add Substitution:**
  - [ ] Select player going off
  - [ ] Select replacement player
  - [ ] Click "Confirm"
  - [ ] Substitution in timeline
  - [ ] Lineup updates (if shown)

- [ ] **Add Own Goal (if applicable):**
  - [ ] Select opposition team
  - [ ] Marked as own goal
  - [ ] Counts toward opposition score
  - [ ] Flagged in timeline as "OG"

### T8.3 Timeline Display
- [ ] **Timeline View:**
  - [ ] Shows all events in chronological order
  - [ ] Events: Goals, Cards, Subs, Match events
  - [ ] Each event shows:
    - [ ] Time (in minutes)
    - [ ] Player name
    - [ ] Action icon (ball, card, arrow)
    - [ ] Score update (after goals)

- [ ] **Color Coding:**
  - [ ] Home team events: One color
  - [ ] Away team events: Different color
  - [ ] Yellow cards: Yellow
  - [ ] Red cards: Red
  - [ ] Goals: Gold/highlight color

- [ ] **Event Icons:**
  - [ ] Goals: ⚽
  - [ ] Yellow card: 🟨
  - [ ] Red card: 🟥
  - [ ] Substitution: 🔄
  - [ ] Match start/end: 📍

- [ ] **Scroll Timeline:**
  - [ ] Timeline can scroll for long matches
  - [ ] Latest events at bottom (or top)
  - [ ] No overlapping elements
  - [ ] Readable on small screens

### T8.4 Edit Match Events
- [ ] **Edit Event (Referee only, before match ends):**
  - [ ] Click on event in timeline
  - [ ] "Edit" button appears
  - [ ] Can modify: Time, Player, Team (in some cases)
  - [ ] Save
  - [ ] Timeline updates

- [ ] **Delete Event (Referee only):**
  - [ ] Click on event
  - [ ] "Delete" button
  - [ ] Confirmation: "Remove this event?"
  - [ ] Confirm → Event removed
  - [ ] Score updates (if goal deleted)
  - [ ] Timeline refreshes

- [ ] **Cannot Edit After Match:**
  - [ ] Match finished
  - [ ] Edit/Delete disabled
  - [ ] Frozen record

### T8.5 End Match
- [ ] **End Match (Coach only):**
  - [ ] Match is live
  - [ ] Click "End Match" button
  - [ ] Confirmation: "End the match?"
  - [ ] Confirm → Match status: "Completed"
  - [ ] Final score locked
  - [ ] Match timestamp recorded
  - [ ] Cannot add new events

- [ ] **Match Summary:**
  - [ ] Final score displayed
  - [ ] Complete timeline visible
  - [ ] Team statistics (if available):
    - [ ] Goals
    - [ ] Cards
    - [ ] Shots (if tracked)

### T8.6 Real-Time Updates (if applicable)
- [ ] **Realtime Service Integration:**
  - [ ] Open match detail on one device
  - [ ] Add event on another device (or simulate)
  - [ ] Event appears on first device within 2 seconds
  - [ ] No need to refresh
  - [ ] Score updates in real-time

- [ ] **Concurrent Users:**
  - [ ] Multiple users viewing match
  - [ ] All see updates simultaneously
  - [ ] No conflicts or race conditions

---

## Push Notifications

### T9.1 Permission Request
- [ ] **First App Launch:**
  - [ ] On Android: No system prompt (Android 13+)
  - [ ] On iOS: System prompt "Allow notifications?"
  - [ ] User can allow/deny
  - [ ] If allowed: FCM token obtained
  - [ ] If denied: Cannot receive notifications

- [ ] **Re-Request Permissions:**
  - [ ] Settings (if available)
  - [ ] "Request notification permission"
  - [ ] Prompt appears (if not already granted)

### T9.2 Notification Subscription (Mock FCM)
- [ ] **Auto-Subscribe on Login:**
  - [ ] Login as coach
  - [ ] Active club selected
  - [ ] Auto-subscribe to club topic
  - [ ] No user action needed
  - [ ] Console shows: "Subscribed to topic: clubs_<clubId>"

- [ ] **Manual Subscription:**
  - [ ] Open tournament detail
  - [ ] "Subscribe to notifications" toggle
  - [ ] Toggle on
  - [ ] Subscribe to tournament topic
  - [ ] Console shows: "Subscribed to topic: tournaments_<tournamentId>"
  - [ ] Toggle off
  - [ ] Unsubscribe
  - [ ] Console shows: "Unsubscribed from topic"

### T9.3 Trigger Mock Notifications
- [ ] **In-App Notification Test:**
  - [ ] Use NotificationMixin methods in services
  - [ ] Call: `await notificationService.simulateFCMEvent()`
  - [ ] Notification appears as floating SnackBar
  - [ ] No actual Firebase needed

- [ ] **Match Event Trigger:**
  - [ ] Start a live match
  - [ ] Add goal event
  - [ ] Notification should trigger if subscribed
  - [ ] Test message: "Carlos Silva scored!"
  - [ ] Notification appears

- [ ] **Tournament Update Trigger:**
  - [ ] Update tournament standings
  - [ ] Notification: "Standings updated"
  - [ ] Appears to subscribed users

### T9.4 Notification Display
- [ ] **Foreground Notification:**
  - [ ] App is open
  - [ ] Notification received
  - [ ] Floating SnackBar appears at bottom
  - [ ] Message: Clear, relevant
  - [ ] Auto-dismisses after 4 seconds
  - [ ] Or tap to dismiss

- [ ] **Notification UI:**
  - [ ] Title visible
  - [ ] Body text visible
  - [ ] Type badge (if applicable)
  - [ ] Material 3 styling
  - [ ] Color matches theme

- [ ] **Notification Indicator:**
  - [ ] AppBar has notification bell icon
  - [ ] Badge shows unread count
  - [ ] Badge updates when new notification
  - [ ] Click to open notification history

### T9.5 Notification History
- [ ] **Notification Bottom Sheet:**
  - [ ] Click notification bell in AppBar
  - [ ] Bottom sheet opens
  - [ ] Shows recent notifications (last 20)
  - [ ] Each notification shows: Time, Title, Body, Type
  - [ ] Notifications in reverse chronological order

- [ ] **Clear All:**
  - [ ] "Clear all" button in bottom sheet
  - [ ] Click → All cleared
  - [ ] List empty
  - [ ] Badge resets to 0

- [ ] **Mark as Read:**
  - [ ] Notification marked read on view
  - [ ] Badge count decrements
  - [ ] Or manual mark-read button (if implemented)

### T9.6 RBAC in Notifications
- [ ] **Coach Receives:**
  - [ ] Team player scored → Goal notification
  - [ ] Tournament standings updated → Standings notification
  - [ ] Club admin action → Club notification

- [ ] **Player Receives:**
  - [ ] Team match scheduled → Match notification
  - [ ] Coach added substitution → You're on bench (if applicable)
  - [ ] Team stats update → General notification

- [ ] **Fan Receives:**
  - [ ] Subscribed tournament updated → Notification
  - [ ] Subscribed team scored → Notification
  - [ ] Cannot receive admin notifications

- [ ] **Admin Receives:**
  - [ ] All notifications for managed club
  - [ ] User joined → Admin notification

### T9.7 Background & Terminated Notifications
- [ ] **Background Mode (Optional - requires real Firebase):**
  - [ ] App in background
  - [ ] Notification sent to device
  - [ ] System notification tray shows notification
  - [ ] Click notification → App opens to relevant screen
  - [ ] OR notification appears in app when resumed

- [ ] **Terminated State (Optional):**
  - [ ] App completely closed
  - [ ] Notification sent
  - [ ] System notification in tray
  - [ ] Tap → App launches
  - [ ] Navigates to relevant screen (if deeplink supported)

---

## Integration Testing

### T10.1 End-to-End Match Workflow
- [ ] **Complete Match Lifecycle:**
  1. [ ] Create friendly match
     - [ ] Navigate to Amistosos tab
     - [ ] Click "Create Match"
     - [ ] Fill form with valid data
     - [ ] Submit
  2. [ ] Verify match in list
     - [ ] Match appears with status "Scheduled"
  3. [ ] Open match detail
     - [ ] All info displayed correctly
  4. [ ] Start match
     - [ ] Click "Start Match"
     - [ ] Status → "Live"
  5. [ ] Add events
     - [ ] Add 2 goals (one per team)
     - [ ] Add 1 yellow card
     - [ ] Add 1 substitution
  6. [ ] Verify timeline
     - [ ] All events visible in order
     - [ ] Correct scores
  7. [ ] End match
     - [ ] Click "End Match"
     - [ ] Status → "Completed"
     - [ ] Final score locked
  8. [ ] View final state
     - [ ] Cannot add new events
     - [ ] Match archived

### T10.2 Team Management Workflow
- [ ] **Create and Manage Team:**
  1. [ ] Create team (as coach)
  2. [ ] Add 5+ players to team
  3. [ ] Edit player details
  4. [ ] Remove one player
  5. [ ] Verify team detail page
  6. [ ] View team statistics (if available)

### T10.3 Tournament Participation Workflow
- [ ] **Create and Manage Tournament:**
  1. [ ] Create league tournament
  2. [ ] Add 4+ teams
  3. [ ] Create matches between teams
  4. [ ] Verify standings update
  5. [ ] Complete several matches
  6. [ ] Check final standings

### T10.4 Multi-User Scenario (if possible)
- [ ] **Simultaneous Users:**
  1. [ ] Login as Coach on Device A
  2. [ ] Login as Player on Device B
  3. [ ] Coach starts match on A
  4. [ ] Player sees live match on B
  5. [ ] Coach adds goal on A
  6. [ ] Player sees goal on B in real-time (if realtime integrated)
  7. [ ] Coach ends match on A
  8. [ ] Player sees completed match on B

### T10.5 Data Consistency
- [ ] **Cross-Screen Consistency:**
  - [ ] Create player on team screen
  - [ ] Go to player screen
  - [ ] Player appears there too
  - [ ] Go back to team
  - [ ] Player still shown
  - [ ] Refresh app
  - [ ] Player still exists

- [ ] **Concurrent Edits:**
  - [ ] Edit match on screen 1
  - [ ] View match on screen 2
  - [ ] Updated data visible on screen 2

---

## Performance & Stability

### T11.1 Load Times
- [ ] **Screen Navigation:**
  - [ ] Home screen loads: < 2 seconds
  - [ ] Team screen loads: < 2 seconds
  - [ ] Tournament list loads: < 2 seconds
  - [ ] Match detail loads: < 1 second
  - [ ] Profile loads: < 1 second

- [ ] **Data Operations:**
  - [ ] Create team: < 3 seconds
  - [ ] Add player: < 2 seconds
  - [ ] Start match: < 1 second
  - [ ] Add match event: < 500ms

### T11.2 List Performance
- [ ] **Large Lists (50+ items):**
  - [ ] Team list with 50 teams: Smooth scroll
  - [ ] Player list with 50+ players: No lag
  - [ ] Match list with 100+ matches: Responsive
  - [ ] No memory leaks (check with DevTools)

### T11.3 Memory Management
- [ ] **Memory Usage:**
  - [ ] Baseline memory: < 150MB
  - [ ] After loading large list: < 250MB
  - [ ] After switching screens 10x: No growth
  - [ ] Streams properly closed on dispose

- [ ] **DevTools Check (if available):**
  - [ ] No memory leaks in graphs
  - [ ] Garbage collection working
  - [ ] No orphaned streams

### T11.4 Crashes and Errors
- [ ] **No Crashes:**
  - [ ] Rotate device multiple times: No crash
  - [ ] Switch apps and back: No crash
  - [ ] Kill and restart app: No crash
  - [ ] Rapid navigation: No crash

- [ ] **Edge Cases:**
  - [ ] Empty lists don't crash
  - [ ] Null fields handled gracefully
  - [ ] Invalid input doesn't crash
  - [ ] Network errors handled

### T11.5 Console Output
- [ ] **Dart Console:**
  - [ ] No unhandled exceptions
  - [ ] No null safety violations
  - [ ] No memory warnings
  - [ ] Clean startup logs

- [ ] **Expected Logs Only:**
  - [ ] Firebase initialization
  - [ ] NotificationService init
  - [ ] Location service init
  - [ ] Auth service logs
  - [ ] No red error logs

### T11.6 Keyboard Handling
- [ ] **Input Fields:**
  - [ ] Keyboard appears when typing
  - [ ] Keyboard hides on submit
  - [ ] No overlapping keyboard and buttons
  - [ ] Scroll works while keyboard open
  - [ ] Bottom nav not hidden by keyboard

### T11.7 Image Loading
- [ ] **Avatar Images (if applicable):**
  - [ ] Images load without flicker
  - [ ] Placeholder shown while loading
  - [ ] Failed images show fallback icon
  - [ ] No infinite loading loops

---

## Automated Test Suite

### T12.1 Run All Tests
```bash
cd mobile_flutter
flutter test
```

- [ ] **Expected Output:**
  - [ ] All tests pass
  - [ ] No skipped tests
  - [ ] No errors or failures
  - [ ] 100% pass rate

### T12.2 Existing Test Files
Test files that should exist and pass:

- [ ] **notification_service_test.dart**
  - [ ] 25+ unit tests
  - [ ] All passing ✓
  - [ ] Tests FCM, topics, RBAC, persistence

- [ ] **notification_widget_test.dart**
  - [ ] 15+ widget tests
  - [ ] All passing ✓
  - [ ] Tests UI components, Material 3

- [ ] **onboarding_screen_test.dart**
  - [ ] Tests onboarding flow
  - [ ] Verify steps work
  - [ ] All passing ✓

- [ ] **profile_screen_test.dart**
  - [ ] Tests profile display
  - [ ] Tests user info
  - [ ] All passing ✓

- [ ] **match_detail_screen_test.dart**
  - [ ] Tests match detail view
  - [ ] Tests event timeline
  - [ ] All passing ✓

- [ ] **venues_management_screen_test.dart**
  - [ ] Tests venue CRUD
  - [ ] All passing ✓

- [ ] **realtime_service_test.dart**
  - [ ] Tests realtime updates
  - [ ] Connection handling
  - [ ] All passing ✓

- [ ] **realtime_integration_test.dart**
  - [ ] Integration tests
  - [ ] All passing ✓

- [ ] **services_test.dart**
  - [ ] General service tests
  - [ ] All passing ✓

- [ ] **venue_service_test.dart**
  - [ ] Venue service logic
  - [ ] All passing ✓

- [ ] **widget_test.dart**
  - [ ] Basic widget tests
  - [ ] All passing ✓

### T12.3 Test Coverage Goals
- [ ] **Target Coverage:**
  - [ ] Services: > 80% coverage
  - [ ] Widgets: > 70% coverage
  - [ ] Models: > 90% coverage
  - [ ] Overall: > 75% coverage

- [ ] **Critical Paths Tested:**
  - [ ] Authentication flows ✓
  - [ ] CRUD operations ✓
  - [ ] Real-time updates ✓
  - [ ] Notifications ✓

### T12.4 Continuous Integration (Optional)
- [ ] **Pre-commit Checks:**
  - [ ] `flutter analyze` passes
  - [ ] `flutter test` passes
  - [ ] No uncommitted changes in generated files

- [ ] **Code Quality:**
  - [ ] No linting errors
  - [ ] Proper formatting
  - [ ] No unused imports

---

## Sign-Off & Report

### T13.1 Pre-Release Checklist

#### Functionality: All CRUD Works
- [ ] Teams: Create, Read, Update, Delete
- [ ] Players: Create, Read, Update, Delete
- [ ] Tournaments: Create, Read, Update, Delete
- [ ] Friendly Matches: Create, Read, Update, Delete
- [ ] Venues: Create, Read, Update, Delete

#### Navigation: All Screens Accessible
- [ ] Login / Register ✓
- [ ] Onboarding ✓
- [ ] Home / Dashboard ✓
- [ ] Teams ✓
- [ ] Players ✓
- [ ] Tournaments ✓
- [ ] Friendly Matches ✓
- [ ] Venues ✓
- [ ] Chat (if implemented) ✓
- [ ] Profile ✓

#### RBAC: All 6 Roles Working
- [ ] Coach: Full access to team management ✓
- [ ] Player: View-only team access ✓
- [ ] Club Admin: Access to admin functions ✓
- [ ] Referee: Match event management ✓
- [ ] Fan: View-only access ✓
- [ ] Super Admin: Full system access ✓

#### UI/UX: Material 3 Compliance
- [ ] Color scheme consistent (#0E7C61) ✓
- [ ] Typography proper hierarchy ✓
- [ ] Spacing and padding correct ✓
- [ ] Responsive layout ✓
- [ ] Touch targets adequate ✓

#### Testing: All Tests Pass
- [ ] 40+ notification tests passing ✓
- [ ] All screen tests passing ✓
- [ ] Service tests passing ✓
- [ ] Integration tests passing ✓
- [ ] 100% pass rate ✓

#### Stability: No Crashes
- [ ] No crashes on navigation ✓
- [ ] No crashes on rotation ✓
- [ ] No crashes on rapid actions ✓
- [ ] Clean console output ✓

#### Performance: Meets Requirements
- [ ] Screen loads < 2 seconds ✓
- [ ] Operations responsive ✓
- [ ] Large lists smooth ✓
- [ ] Memory stable ✓

### T13.2 Known Issues (If Any)
Document any known issues, workarounds, and plans:

1. [ ] **Issue:** [Description]
   - **Status:** [Open/Accepted/Planned for Next Release]
   - **Workaround:** [If available]
   - **Plan:** [When to fix]

2. [ ] **Issue:** [Description]
   - **Status:** [Open/Accepted/Planned for Next Release]

### T13.3 Test Execution Summary
```
Total Test Cases:         [150+]
Total Tests Passed:       [150+]
Total Tests Failed:       [0]
Total Tests Skipped:      [0]

Pass Rate:               100%
Critical Issues:          0
Warnings:                 0
```

### T13.4 Environment Details
- [ ] **Device/Emulator:**
  - [ ] Device Model: [e.g., Pixel 5, iPhone 13]
  - [ ] OS Version: [e.g., Android 13, iOS 15]
  - [ ] Flutter Version: [e.g., 3.10.0]
  - [ ] Dart Version: [Automatically installed]

- [ ] **Testing Date & Time:**
  - [ ] Date: December 6, 2025
  - [ ] Time: [HH:MM AM/PM]
  - [ ] Duration: [X minutes]

### T13.5 Tester Sign-Off
```
Tested By:      _________________________
Name:           _________________________
Date:           _________________________
Status:         ☐ PASS  ☐ FAIL  ☐ PARTIAL

Signature:      _________________________
```

### T13.6 Final Report Template

**TESTING REPORT**

**Project:** Football Coaches App MVP  
**Version:** 0.1.0+1  
**Date:** December 6, 2025

**Executive Summary:**
[Brief overview of testing results]

**Test Coverage:**
- Total Test Cases: [Number]
- Passed: [Number]
- Failed: [Number]
- Pass Rate: [Percentage]

**Areas Tested:**
- [x] Authentication & RBAC (All 6 roles)
- [x] CRUD Operations (All entities)
- [x] UI/UX Compliance (Material 3)
- [x] Real-time Updates
- [x] Push Notifications
- [x] Performance & Stability
- [x] Automated Test Suite

**Critical Findings:**
- [Issue 1: Severity, impact, resolution]
- [Issue 2: Severity, impact, resolution]

**Recommendations:**
1. [Recommendation 1]
2. [Recommendation 2]

**Status:** 🟢 READY FOR RELEASE / 🟡 CONDITIONAL / 🔴 NOT READY

**Sign-Off:** [Tester Name], [Date]

---

## Additional Testing Tips

### Performance Profiling
```bash
# Use Flutter DevTools
flutter pub global activate devtools
devtools

# In browser, open Dart DevTools → Memory tab
# Monitor memory usage during testing
```

### Console Logging
```bash
# View logs during testing
flutter logs

# Filter for errors
flutter logs | grep -i error
```

### Test Specific Feature
```bash
# Run specific test file
flutter test test/notification_service_test.dart

# Run with verbose output
flutter test -v

# Run with coverage
flutter test --coverage
```

### Hot Reload Testing
```bash
# During development
flutter run

# Press 'r' for hot reload
# Press 'R' for full restart
# Verify changes immediately
```

### Error Handling
When you encounter an error:
1. Note the exact error message
2. Reproduce the steps
3. Check console for stack trace
4. Check issue in KNOWN_ISSUES.md (create if needed)
5. File a bug with reproduction steps

---

## Next Steps After Testing

### If All Tests Pass ✅
1. Create release branch: `release/0.1.0`
2. Update version in pubspec.yaml
3. Generate release APK/IPA
4. Tag release in git
5. Document release notes

### If Issues Found 🐛
1. Document issues with reproduction steps
2. Create bug fixes on feature branches
3. Re-test fixes
4. Update test cases if needed
5. Re-run full test suite
6. Repeat until all pass

### For Next Sprint 📋
1. Review performance metrics
2. Identify improvement opportunities
3. Plan feature enhancements
4. Update documentation
5. Schedule next testing cycle

---

**Document Created:** December 6, 2025  
**Last Updated:** December 6, 2025  
**Status:** Ready for MVP Testing  
**Version:** 1.0


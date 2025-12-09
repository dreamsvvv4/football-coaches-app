# 🎯 MVP Test Data & Reproducible Scenarios

**Project:** Football Coaches App MVP  
**Purpose:** Provide standard test data and step-by-step reproducible test scenarios  
**Last Updated:** December 6, 2025

---

## Test User Accounts

Use these credentials for consistent testing across different testers:

### Role: COACH
```
Email:       coach@example.com
Password:    password123
Role:        Coach
Permissions: Full team management, tournament creation, match management
Team:        Test Coach FC (pre-populated)
Club:        Test Club (pre-populated)
```

**Test Scenarios:**
- [ ] Create and manage teams
- [ ] Add/edit/remove players
- [ ] Create and manage tournaments
- [ ] Create and manage friendly matches
- [ ] Start and manage live matches
- [ ] Receive all notifications

### Role: PLAYER
```
Email:       player@example.com
Password:    password123
Role:        Player
Permissions: View team, view matches, chat
Team:        Test Coach FC
Status:      Active
```

**Test Scenarios:**
- [ ] View team details
- [ ] View assigned matches
- [ ] Receive match notifications
- [ ] Participate in chat
- [ ] Cannot create teams or tournaments

### Role: CLUB_ADMIN
```
Email:       admin@example.com
Password:    password123
Role:        Club Admin
Permissions: Club management, user management, venue management
Club:        Test Club
```

**Test Scenarios:**
- [ ] Manage club users
- [ ] Manage venues
- [ ] View all club teams
- [ ] Manage tournaments within club

### Role: REFEREE
```
Email:       referee@example.com
Password:    password123
Role:        Referee
Permissions: Match event management, tournament access
```

**Test Scenarios:**
- [ ] Manage match events
- [ ] Access live match controls
- [ ] View tournaments
- [ ] Cannot manage teams

### Role: FAN
```
Email:       fan@example.com
Password:    password123
Role:        Fan
Permissions: View-only tournaments, matches, chat
```

**Test Scenarios:**
- [ ] View tournaments
- [ ] View matches
- [ ] Participate in chat
- [ ] Subscribe to notifications
- [ ] Cannot manage anything

### Role: SUPER_ADMIN
```
Email:       admin@admin.com
Password:    password123
Role:        Super Admin
Permissions: Full system access
```

**Test Scenarios:**
- [ ] Access all features
- [ ] Manage all users
- [ ] System administration

---

## Pre-populated Test Data

### Teams
```
Team 1:
  Name:        Test Coach FC
  Sport:       Football
  Manager:     coach@example.com
  Home Venue:  Central Stadium
  Players:     5 (see below)

Team 2:
  Name:        Opponent FC
  Sport:       Football
  Manager:     coach2@example.com (optional, can create during test)
  Home Venue:  West Stadium

Team 3:
  Name:        Young Squad
  Sport:       Football
  Manager:     coach@example.com
  Home Venue:  Youth Arena
```

### Players (in Test Coach FC)
```
Player 1:
  Name:        John Doe
  Number:      10
  Position:    Forward
  DOB:         1998-05-15
  Status:      Active

Player 2:
  Name:        Carlos Silva
  Number:      7
  Position:    Midfielder
  DOB:         1999-03-22
  Status:      Active

Player 3:
  Name:        Miguel Santos
  Number:      1
  Position:    Goalkeeper
  DOB:         1997-01-10
  Status:      Active

Player 4:
  Name:        Ana Garcia
  Number:      5
  Position:    Defender
  DOB:         2000-07-18
  Status:      Active

Player 5:
  Name:        Luis Martinez
  Number:      3
  Position:    Defender
  DOB:         1998-11-25
  Status:      Active
```

### Venues
```
Venue 1:
  Name:        Central Stadium
  City:        Madrid
  Address:     123 Stadium Lane, Madrid
  Capacity:    5000
  Surface:     Grass
  Lighting:    Yes

Venue 2:
  Name:        West Stadium
  City:        Barcelona
  Address:     456 Sports Park, Barcelona
  Capacity:    3000
  Surface:     Synthetic
  Lighting:    Yes

Venue 3:
  Name:        Youth Arena
  City:        Valencia
  Address:     789 Youth Center, Valencia
  Capacity:    1000
  Surface:     Grass
  Lighting:    No
```

### Tournaments
```
League Tournament:
  Name:        City Football League 2025
  Type:        League
  Start Date:  2025-01-15
  End Date:    2025-06-30
  Teams:       8
  Status:      Scheduled

Cup Tournament:
  Name:        City Cup 2025
  Type:        Knockout
  Start Date:  2025-02-01
  End Date:    2025-03-31
  Teams:       8
  Status:      Scheduled
```

---

## Reproducible Test Scenarios

### Scenario 1: Complete Team Setup (30 minutes)

**Objective:** Create a team, add players, and verify complete roster

**Preconditions:**
- [ ] App is running
- [ ] Logged in as Coach (coach@example.com)
- [ ] On Home screen

**Steps:**
1. Navigate to "Equipo" (Teams) tab
   - [ ] Click "Equipo" in bottom navigation
   - [ ] Should see Teams screen
   - [ ] Existing teams listed (or empty state)

2. Create new team
   - [ ] Click "Create Team" button
   - [ ] Fill form:
     ```
     Team Name:    My Test Squad
     Sport:        Football
     Home Venue:   Central Stadium
     Color:        Blue (if applicable)
     ```
   - [ ] Click "Create"
   - [ ] **Verify:** Team appears in list with status "Active"
   - [ ] **Expected Time:** < 3 seconds

3. Add 5 players to team
   - [ ] Click on created team
   - [ ] Click "Players" tab
   - [ ] Click "Add Player"
   - [ ] **Player 1:**
     ```
     Name:         Carlos Mendes
     Number:       10
     Position:     Forward
     DOB:          1998-05-15
     Status:       Active
     ```
   - [ ] Click "Add"
   - [ ] **Verify:** Player appears in list
   - [ ] Repeat for 4 more players:
     - [ ] Sofia Rodriguez (9, Forward, Active)
     - [ ] Miguel Santos (7, Midfielder, Active)
     - [ ] Ana Garcia (5, Defender, Active)
     - [ ] Luis Martinez (1, Goalkeeper, Active)

4. Verify complete roster
   - [ ] Go to team detail
   - [ ] Check Players tab
   - [ ] **Verify:** All 5 players listed
   - [ ] **Verify:** Positions correct
   - [ ] **Verify:** Numbers unique (1, 5, 7, 9, 10)
   - [ ] **Verify:** All marked "Active"

5. Edit one player
   - [ ] Click on Carlos Mendes
   - [ ] Click "Edit"
   - [ ] Change position to "Midfielder"
   - [ ] Click "Save"
   - [ ] **Verify:** List shows "Midfielder" for Carlos

6. Delete one player
   - [ ] Click on Sofia Rodriguez
   - [ ] Click "Delete"
   - [ ] Confirm deletion
   - [ ] **Verify:** Sofia removed from list
   - [ ] **Verify:** 4 players remain

7. Final verification
   - [ ] Team has 4 players
   - [ ] All info correct
   - [ ] No console errors
   - [ ] Smooth navigation

**Expected Outcome:** ✅ Team roster complete and verified

**Common Issues & Fixes:**
- If player number shows error: Ensure number between 1-99 and unique
- If form doesn't submit: Check all required fields filled
- If player doesn't appear: Try refreshing, then reload team

---

### Scenario 2: Complete Match Lifecycle (45 minutes)

**Objective:** Create, start, manage, and complete a friendly match with events

**Preconditions:**
- [ ] App running
- [ ] Logged in as Coach
- [ ] Teams exist: "Test Coach FC" (your team) and "Opponent FC"
- [ ] Venue selected: "Central Stadium"

**Steps:**

#### Part 1: Create Match (5 min)
1. Navigate to "Amistosos" (Friendly Matches) tab
   - [ ] Click "Amistosos" in bottom navigation
   - [ ] See friendly matches screen
   - [ ] Existing matches listed (or empty)

2. Create friendly match
   - [ ] Click "Create Match" button
   - [ ] Fill form:
     ```
     Home Team:    Test Coach FC
     Away Team:    Opponent FC
     Match Date:   Tomorrow (2025-12-07)
     Match Time:   19:00 (7 PM)
     Venue:        Central Stadium
     Notes:        Friendly preparation match
     ```
   - [ ] Click "Create"
   - [ ] **Verify:** Match appears in list
   - [ ] **Verify:** Status shows "Scheduled"
   - [ ] **Verify:** Correct date/time displayed

#### Part 2: Start Match (2 min)
1. Open match detail
   - [ ] Click on created match in list
   - [ ] See match detail screen
   - [ ] Current score: 0-0
   - [ ] Status: "Scheduled"
   - [ ] "Start Match" button visible

2. Start the match
   - [ ] Click "Start Match" button
   - [ ] **Verify:** Status changes to "Live" ⚽
   - [ ] **Verify:** LIVE badge appears prominently
   - [ ] **Verify:** Elapsed time shows 00:00 and starts incrementing
   - [ ] **Verify:** "Add Event" button enabled

#### Part 3: Add Events (20 min)

**Event 1: First Goal (Home)**
- [ ] Click "Add Event" / "Add Goal" button
- [ ] Dialog appears for goal entry
- [ ] Select:
  ```
  Team:       Test Coach FC (Home)
  Player:     Carlos Mendes (10)
  Time:       08:00 (or auto-filled)
  Type:       Goal
  ```
- [ ] Click "Confirm"
- [ ] **Verify:** Score updates to 1-0
- [ ] **Verify:** Event appears in timeline:
  ```
  08:00 | ⚽ Carlos Mendes | Test Coach FC | 1-0
  ```
- [ ] **Verify:** Goal notification appears (optional)

**Event 2: Yellow Card**
- [ ] Click "Add Event"
- [ ] Select Yellow Card
- [ ] Select:
  ```
  Team:       Test Coach FC
  Player:     Ana Garcia (5, Defender)
  Time:       15:00
  Type:       Yellow Card
  ```
- [ ] Click "Confirm"
- [ ] **Verify:** 🟨 Yellow card in timeline
- [ ] **Verify:** Score remains 1-0

**Event 3: Second Goal (Away)**
- [ ] Click "Add Event"
- [ ] Select Goal
- [ ] Select:
  ```
  Team:       Opponent FC (Away)
  Player:     [Any away player, or auto-populated]
  Time:       22:00
  Type:       Goal
  ```
- [ ] Click "Confirm"
- [ ] **Verify:** Score updates to 1-1
- [ ] **Verify:** Timeline shows away goal in different color/team

**Event 4: Substitution**
- [ ] Click "Add Event"
- [ ] Select Substitution
- [ ] Fill:
  ```
  Team:           Test Coach FC
  Player Off:     Sofia Rodriguez (9)
  Player On:      Luis Martinez (3)
  Time:           35:00
  ```
- [ ] Click "Confirm"
- [ ] **Verify:** 🔄 Substitution in timeline
- [ ] **Verify:** Shows player off and player on

**Event 5: Red Card**
- [ ] Click "Add Event"
- [ ] Select Red Card
- [ ] Select:
  ```
  Team:       Opponent FC
  Player:     [Away player]
  Time:       40:00
  Type:       Red Card
  ```
- [ ] Click "Confirm"
- [ ] **Verify:** 🟥 Red card appears
- [ ] **Verify:** Different color from yellow card
- [ ] **Verify:** Player marked as sent off

#### Part 4: Verify Timeline (5 min)
- [ ] Timeline shows all 5 events in order:
  1. ⚽ Goal - Carlos Mendes (8')
  2. 🟨 Yellow - Ana Garcia (15')
  3. ⚽ Goal - Away Player (22')
  4. 🔄 Sub - Rodriguez → Martinez (35')
  5. 🟥 Red - Away Player (40')

- [ ] Events grouped by team (visual distinction)
- [ ] Score correctly shows 1-1
- [ ] Timeline scrollable if needed
- [ ] Time stamps in ascending order

#### Part 5: End Match (2 min)
1. Click "End Match" button
   - [ ] Confirmation dialog appears
   - [ ] Message: "Are you sure you want to end the match?"

2. Confirm end
   - [ ] Click "Confirm"
   - [ ] **Verify:** Status changes to "Completed" ✓
   - [ ] **Verify:** Final score locked: 1-1
   - [ ] **Verify:** Match timestamp recorded
   - [ ] **Verify:** Cannot add new events

3. Verify final state
   - [ ] All events still visible
   - [ ] Timeline frozen (cannot edit)
   - [ ] Summary available (if implemented)

**Expected Outcome:** ✅ Full match lifecycle complete with all events

**Event Timeline Checklist:**
- [ ] All events recorded
- [ ] Correct order maintained
- [ ] Correct teams shown
- [ ] Correct players shown
- [ ] Scores update correctly
- [ ] Icons/colors appropriate
- [ ] Time stamps accurate

---

### Scenario 3: RBAC Verification (30 minutes)

**Objective:** Verify each role has correct permissions

**Setup:** Have multiple accounts ready:
- coach@example.com (Coach)
- player@example.com (Player)
- admin@example.com (Admin)
- referee@example.com (Referee)
- fan@example.com (Fan)

**Steps for Each Role:**

#### Coach Role Testing (5 min)
1. Login as coach@example.com
2. Verify visible tabs:
   - [ ] Home (Inicio) ✓
   - [ ] Team (Equipo) ✓
   - [ ] Friendly Matches (Amistosos) ✓
   - [ ] Tournaments (Torneos) ✓
   - [ ] Chat ✓
   - [ ] Profile (Perfil) ✓

3. Verify can create:
   - [ ] Teams: Click "Create Team" → Form appears ✓
   - [ ] Players: Team → Players → "Add Player" ✓
   - [ ] Tournaments: "Torneos" → "Create" ✓
   - [ ] Friendly Matches: "Amistosos" → "Create" ✓
   - [ ] Venues: Should be able to (if coach feature) ✓

4. Logout

#### Player Role Testing (5 min)
1. Login as player@example.com
2. Verify visible tabs:
   - [ ] Home (Inicio) ✓
   - [ ] Team (Equipo) ✓ (view-only)
   - [ ] Friendly Matches (Amistosos) ✓ (view-only)
   - [ ] Chat ✓
   - [ ] Profile (Perfil) ✓

3. Verify cannot create:
   - [ ] Teams: No "Create" button ✓
   - [ ] Players: Cannot access add player form ✓
   - [ ] Tournaments: "Torneos" tab may exist but "Create" disabled ✓

4. Verify can view:
   - [ ] Team roster
   - [ ] Match schedule
   - [ ] Chat messages

5. Logout

#### Admin Role Testing (5 min)
1. Login as admin@example.com
2. Verify accessible:
   - [ ] All tabs ✓
   - [ ] User management (if available) ✓
   - [ ] Venue management ✓
   - [ ] All edit/delete permissions ✓

3. Logout

#### Referee Role Testing (5 min)
1. Login as referee@example.com
2. Verify can:
   - [ ] Access live matches ✓
   - [ ] Manage match events ✓
   - [ ] View tournaments ✓

3. Verify cannot:
   - [ ] Create teams ✓
   - [ ] Manage club users ✓

4. Logout

#### Fan Role Testing (5 min)
1. Login as fan@example.com
2. Verify visible tabs:
   - [ ] Home ✓
   - [ ] Tournaments (view-only) ✓
   - [ ] Friendly Matches (view-only) ✓
   - [ ] Chat ✓
   - [ ] Profile ✓

3. Verify cannot:
   - [ ] Create anything ✓
   - [ ] Edit anything ✓
   - [ ] Manage users ✓
   - [ ] Access admin features ✓

4. Logout

**Expected Outcome:** ✅ Each role has exactly correct permissions

**RBAC Verification Checklist:**
- [ ] Coach: Full edit access
- [ ] Player: View access, limited participation
- [ ] Admin: All management features
- [ ] Referee: Event management access
- [ ] Fan: View-only access
- [ ] Super Admin: Complete access

---

### Scenario 4: Push Notification Flow (20 minutes)

**Objective:** Test notification subscription, triggering, and display

**Preconditions:**
- [ ] App running
- [ ] Logged in as Coach
- [ ] Notifications permission granted

**Steps:**

#### Part 1: Verify Notification Indicator (5 min)
1. Look at AppBar (top of home screen)
   - [ ] Should see bell icon 🔔 on right side
   - [ ] Icon clickable

2. Click bell icon
   - [ ] Bottom sheet slides up
   - [ ] Title: "Notifications"
   - [ ] Shows recent notifications (or "No notifications yet")
   - [ ] "Clear All" button visible
   - [ ] Can scroll if many notifications
   - [ ] Closes on back or tap outside

3. Close and go back

#### Part 2: Auto-Subscribe on Login (2 min)
1. Check notification subscriptions
   - [ ] After login, app auto-subscribes to active club
   - [ ] Console should show: "Subscribed to topic: clubs_<id>"
   - [ ] No user action needed

#### Part 3: Trigger Notification (8 min)
1. Start a friendly match
   - [ ] Create or open existing match
   - [ ] Click "Start Match"
   - [ ] Status: "Live"

2. Add goal event
   - [ ] Click "Add Event" → "Goal"
   - [ ] Select player: Carlos Mendes
   - [ ] Click "Confirm"
   - [ ] **Watch for notification:**
     - [ ] Floating SnackBar appears at bottom
     - [ ] Message: Something like "Carlos Mendes scored!"
     - [ ] Color-coded (gold or primary color)
     - [ ] Auto-dismisses after ~4 seconds
     - [ ] OR click to dismiss manually

3. Check notification history
   - [ ] Click bell icon
   - [ ] Should see goal notification in history
   - [ ] Shows: Time, Title, Body
   - [ ] Type badge (if applicable)

#### Part 4: Notification UI Verification (5 min)
1. Notification SnackBar appearance:
   - [ ] Title visible
   - [ ] Body text visible
   - [ ] Proper Material 3 styling
   - [ ] Color matches theme
   - [ ] No overlapping with other UI
   - [ ] Closes smoothly

2. Notification History UI:
   - [ ] Proper cards for each notification
   - [ ] Material 3 styling
   - [ ] Time displayed (relative or absolute)
   - [ ] Clear visual hierarchy
   - [ ] "Clear All" button works

3. Bell Icon Badge:
   - [ ] Shows count of unread notifications
   - [ ] Color: Error/red
   - [ ] Updates when new notification received
   - [ ] Resets to 0 after "Clear All"

**Expected Outcome:** ✅ Notifications display correctly and intuitively

**Notification Verification Checklist:**
- [ ] Indicator visible in AppBar
- [ ] Auto-subscription on login
- [ ] Notifications trigger on events
- [ ] SnackBar displays and dismisses
- [ ] History bottom sheet works
- [ ] Clear all button functional
- [ ] Badge updates correctly
- [ ] Material 3 compliant

---

### Scenario 5: Responsive Design Testing (20 minutes)

**Objective:** Verify UI adapts across different screen sizes

**Setup:** Use multiple devices or emulator with different screen sizes
- Phone (360px - 480px wide)
- Tablet (600px - 1200px wide)
- Test both portrait and landscape

#### Phone (360px) Portrait Testing (5 min)
1. Open app in portrait mode
2. Navigate through each screen:
   - [ ] Home Screen
     - [ ] AppBar fits
     - [ ] Navigation bar at bottom
     - [ ] Content doesn't overflow
   - [ ] Teams Screen
     - [ ] Cards don't need horizontal scroll
     - [ ] Text readable
     - [ ] Buttons large enough (48px)
   - [ ] Player List
     - [ ] Each player card fits width
     - [ ] No truncated text
   - [ ] Match Detail
     - [ ] Timeline displays properly
     - [ ] Events readable
     - [ ] Score display prominent

3. Form Testing:
   - [ ] "Create Team" form
     - [ ] All fields visible without scroll
     - [ ] Keyboard doesn't hide submit button
     - [ ] Can scroll to reach all fields
   - [ ] "Create Match" form
     - [ ] Date/time pickers work
     - [ ] Input fields accessible
     - [ ] Submit button always reachable

#### Tablet (600px+) Landscape Testing (5 min)
1. Rotate device to landscape
2. Verify layout adapts:
   - [ ] AppBar remains at top
   - [ ] Navigation bar repositions (bottom or side)
   - [ ] Content uses full width properly
   - [ ] Two-column layout if applicable
   - [ ] No wasted space
   - [ ] No content cut off

3. Data preservation:
   - [ ] Form data maintained after rotation
   - [ ] Scroll position preserved (if implemented)
   - [ ] No crashes on rotation

#### Large Screen Testing (5 min)
1. Tablet or desktop browser at 1200px+
2. Verify:
   - [ ] Content not stretched
   - [ ] Proper margins maintained
   - [ ] Not cluttered
   - [ ] Good use of space
   - [ ] Multi-column layout if applicable

#### Touch Target Testing (5 min)
1. On phone, verify all interactive elements:
   - [ ] Buttons: 48px x 48px minimum
   - [ ] Links: Tappable without difficulty
   - [ ] Cards: Can click full card
   - [ ] Spacing: Enough space between buttons

2. Edge cases:
   - [ ] Can tap last item in list without cutting off
   - [ ] Keyboard doesn't hide critical buttons
   - [ ] No overlapping tap targets

**Expected Outcome:** ✅ UI responsive and accessible across sizes

---

### Scenario 6: Stress Test - Large Data Volume (30 minutes)

**Objective:** Verify app handles large lists and datasets

**Setup:** Create substantial test data

**Steps:**

#### Step 1: Create Large Team (10 min)
1. Create team with 20+ players
   - [ ] Create team: "Large Squad"
   - [ ] Add players iteratively:
     - [ ] 10 outfield players
     - [ ] 5 midfielders
     - [ ] 5 defenders
     - [ ] 2+ goalkeepers

2. Verify team screen:
   - [ ] Loads in reasonable time (< 2 sec)
   - [ ] Scrolling smooth (no lag)
   - [ ] No memory warnings
   - [ ] All players display
   - [ ] Search/filter works if available

#### Step 2: Create Multiple Tournaments (8 min)
1. Create 5+ tournaments:
   - [ ] Each with 8-12 teams
   - [ ] Verify tournaments list loads smoothly
   - [ ] Sorting works
   - [ ] Filtering works (if available)

#### Step 3: Create Match Series (8 min)
1. Create 20+ friendly matches:
   - [ ] Some in future
   - [ ] Some in past
   - [ ] Some with events
   - [ ] Verify list loads smoothly
   - [ ] Sorting by date works
   - [ ] Filtering works

2. Performance checks:
   - [ ] No jank or frame drops
   - [ ] Smooth scrolling
   - [ ] Memory stable

#### Step 4: Timeline Stress Test (4 min)
1. Create single match with 30+ events:
   - [ ] Add many goals, cards, substitutions
   - [ ] Verify timeline displays all
   - [ ] Scrolling smooth
   - [ ] All events visible
   - [ ] No truncation

**Expected Outcome:** ✅ App handles large datasets smoothly

**Stress Test Checklist:**
- [ ] 20+ players load smoothly
- [ ] 5+ tournaments responsive
- [ ] 20+ matches manageable
- [ ] 30+ timeline events displayable
- [ ] No memory leaks
- [ ] No crashes
- [ ] Performance acceptable (< 60fps drops rare)

---

## Test Data Management

### Creating Test Data
```bash
# If API endpoints available:
POST /api/teams
{
  "name": "Test Team",
  "sport": "football",
  "homeVenueId": "venue_1"
}

POST /api/teams/{id}/players
{
  "name": "John Doe",
  "number": 10,
  "position": "forward"
}

POST /api/matches
{
  "homeTeamId": "team_1",
  "awayTeamId": "team_2",
  "date": "2025-12-07",
  "time": "19:00",
  "venueId": "venue_1"
}
```

### Cleaning Up Test Data
```bash
# Or use UI to delete:
1. Delete all created test teams
2. Delete all test matches
3. Delete all test tournaments
4. Return to clean state

# Or reset mock data:
AuthService.instance.resetMockData()
```

### Data Reset
If needed, completely reset app state:
```bash
# Clear app data on device
adb shell pm clear com.example.football_coaches_app

# Or in Flutter:
await SharedPreferences.getInstance().clear();
```

---

## Quick Copy-Paste Test Commands

### Commands for Quick Tests
```bash
# Terminal 1: Start app
cd mobile_flutter
flutter run

# Terminal 2: Watch logs
flutter logs

# Terminal 3: Run tests
cd mobile_flutter
flutter test

# Run specific test
flutter test test/notification_service_test.dart -v

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze

# Format code
flutter format lib/
```

### Common Debug Prints
Add to code for debugging:
```dart
// In services
print('DEBUG: User role: ${AuthService.instance.currentUser?.role}');
print('DEBUG: Notification subscribed: ${NotificationService.instance.currentTopics}');

// In UI
debugPrint('Navigation: ${ModalRoute.of(context)?.settings.name}');
```

---

## Expected vs Actual Results Template

When you find an issue, document it:

```
ISSUE REPORT
═════════════

Test Case:    T4.3 Add Match Events
Step:         Event 2 - Yellow Card
Expected:     Yellow card icon appears in timeline
Actual:       No icon shown, only text "Yellow card"
Severity:     LOW (visual only)
Reproducible: Yes
Status:       Open
```

---

**Ready to begin testing! Use these scenarios as your guide.**


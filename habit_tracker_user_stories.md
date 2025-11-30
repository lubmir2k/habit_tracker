# Habit Tracker User Stories

This document contains all user stories for the Habit Tracker mobile application, organized by feature area.

---

## Login/Registration Screen

### User Stories

**US-001: Account Registration**
- As a user, I want to register with my name, username, age, and country so that I can create an account and access the habit tracking features.
- **Acceptance Criteria:**
  1. Registration form displays fields for name, username, age, and country
  2. All fields are validated before submission
  3. User is redirected to login page after successful registration
- **Priority:** High

**US-002: Account Login**
- As a user, I want to log in using my username and password so that I can access my account and track my habits.
- **Acceptance Criteria:**
  1. Login form displays username and password fields
  2. Successful login redirects to home page
  3. User session is maintained while logged in
- **Priority:** High

**US-003: Error Feedback on Login**
- As a user, I want to receive a message if I enter the wrong username or password so that I know my login attempt was unsuccessful.
- **Acceptance Criteria:**
  1. Error message displays when credentials are incorrect
  2. Error message is clear and user-friendly
  3. User can retry login after error
- **Priority:** High

**US-004: Store User Data**
- As a user, I want my registration details to be saved in local storage so that my data persists between app sessions.
- **Acceptance Criteria:**
  1. User data is saved to local storage on registration
  2. Data persists after app is closed
  3. Data is available on subsequent logins
- **Priority:** High

---

## Home Screen

### User Stories

**US-005: View Welcome Message**
- As a user, I want to see a personalized welcome message with my name on the homepage so that I feel recognized and can confirm I am logged into the correct account.
- **Acceptance Criteria:**
  1. Welcome message displays user's name from profile
  2. Message updates when user changes their name in settings
  3. Message is prominently displayed at top of home screen
- **Priority:** Medium

**US-006: Display Daily Progress**
- As a user, I want to see my daily progress for each habit on the homepage so that I can easily monitor my progress.
- **Acceptance Criteria:**
  1. Home screen shows list of habits for today
  2. Each habit shows completion status
  3. Progress updates in real-time when habits are marked complete
- **Priority:** High

**US-007: View Completed Habits**
- As a user, I want to see a section for completed habits on the homepage so that I can track what I have already achieved.
- **Acceptance Criteria:**
  1. Separate "Done" section displays completed habits
  2. Completed habits show visual indication (checkmark, strikethrough)
  3. User can move habits back to to-do list
- **Priority:** Medium

**US-008: Quick Navigation**
- As a user, I want to access my most-used features from the home screen so that I can navigate the app efficiently.
- **Acceptance Criteria:**
  1. FAB (+) button provides quick access to add habits
  2. Menu icon provides access to all app sections
  3. Swipe gestures allow quick habit completion
- **Priority:** High

---

## Detail Screen

### User Stories

**US-009: Add a New Habit**
- As a user, I want to add new habits on the configuration page so that I can manage and update my habits as needed.
- **Acceptance Criteria:**
  1. Add habit form with name field
  2. Habit added to list immediately
  3. Habit saved to local storage
- **Priority:** High

**US-010: Delete a Habit**
- As a user, I want to delete existing habits so that I can keep my habits up to date.
- **Acceptance Criteria:**
  1. Delete option available for each habit
  2. Confirmation before deletion
  3. Habit removed from storage permanently
- **Priority:** Medium

**US-011: Personalize Habit with Color**
- As a user, I want to assign a specific color to each habit so that I can make it personal to me.
- **Acceptance Criteria:**
  1. Color picker available when adding/editing habit
  2. Selected color displayed on habit card
  3. Color saved with habit data
- **Priority:** Low

**US-012: View Habit Details**
- As a user, I want to view detailed information about a selected habit so that I can understand my tracking history.
- **Acceptance Criteria:**
  1. Habit detail screen shows name, color, and creation date
  2. Shows completion history for the habit
  3. Provides edit and delete options
- **Priority:** Medium

---

## Persistent Data Integration

### User Stories

**US-013: Persist Habits Data**
- As a user, I want my habits to be saved when I close the app so that I don't lose my data.
- **Acceptance Criteria:**
  1. All habits are saved to local storage
  2. Habits persist after app restart
  3. Completion status is preserved
- **Priority:** High

**US-014: Persist User Profile**
- As a user, I want my profile data to persist across sessions so that I don't need to re-enter details every time.
- **Acceptance Criteria:**
  1. User profile saved to local storage
  2. Profile data loads on app start
  3. Changes are saved immediately
- **Priority:** High

**US-015: Persist User Preferences**
- As a user, I want to save my preferences such as theme settings so that the app remembers my settings.
- **Acceptance Criteria:**
  1. Theme preference saved to local storage
  2. Notification preferences persisted
  3. Settings applied on app start
- **Priority:** Medium

**US-016: Persist Completion History**
- As a user, I want my habit completion history to persist so that I can track my progress over time.
- **Acceptance Criteria:**
  1. Daily completion data saved with timestamps
  2. History available for reports
  3. Data survives app reinstall (where possible)
- **Priority:** Medium

---

## External API Integration

### User Stories

**US-017: Fetch Motivational Quotes**
- As a user, I want to see a motivational quote on my home screen so that I feel inspired to complete my habits.
- **Acceptance Criteria:**
  1. Quote fetched from external API
  2. New quote displayed daily
  3. Fallback to cached quote if offline
- **Priority:** Low

**US-018: Sync Data to Cloud**
- As a user, I want to sync my habit data to the cloud so that I can access it from multiple devices.
- **Acceptance Criteria:**
  1. Data syncs when connected to internet
  2. Conflict resolution for offline changes
  3. Sync status indicator shown
- **Priority:** Low

**US-019: Weather-Based Suggestions**
- As a user, I want to receive habit suggestions based on weather so that I can plan outdoor activities appropriately.
- **Acceptance Criteria:**
  1. Weather data fetched from API
  2. Relevant suggestions displayed
  3. User can dismiss suggestions
- **Priority:** Low

---

## Settings Menu

### User Stories

**US-020: Access Menu Options**
- As a user, I want to access a menu with options for configuring my habits, viewing reports, editing my profile, and signing out so that I can easily navigate to different parts of the app.
- **Acceptance Criteria:**
  1. Hamburger menu icon visible on home screen
  2. Menu opens as drawer/sidebar when tapped
  3. Menu contains: Personal Info, Reports, Notifications, Sign Out
- **Priority:** High

**US-021: Navigate to Profile**
- As a user, I want to navigate to my profile page from the menu so that I can view and update my personal information.
- **Acceptance Criteria:**
  1. "Personal Info" option visible in menu
  2. Tapping option navigates to profile screen
  3. Back navigation returns to home screen
- **Priority:** Medium

**US-022: Navigate to Reports**
- As a user, I want to access the reports page from the menu so that I can view my progress.
- **Acceptance Criteria:**
  1. "Reports" option visible in menu
  2. Tapping option navigates to reports screen
  3. Back navigation returns to home screen
- **Priority:** Medium

**US-023: Sign Out from Menu**
- As a user, I want to sign out of my account using an option in the menu so that I can securely log out when I'm finished using the app.
- **Acceptance Criteria:**
  1. "Sign Out" option visible in menu
  2. Tapping sign out clears session data
  3. User is redirected to login screen
- **Priority:** High

---

## Settings Screen

### User Stories

**US-024: View Personal Information**
- As a user, I want to view my saved name, username, age, and country on my profile page so that I can see the details I provided during registration.
- **Acceptance Criteria:**
  1. Profile page displays name, username, age, and country
  2. Data is loaded from local storage
  3. Fields are clearly labeled
- **Priority:** Medium

**US-025: Edit Personal Information**
- As a user, I want to update my name, username, age, and country on my profile page so that I can keep my information up to date.
- **Acceptance Criteria:**
  1. Edit mode allows modifying all profile fields
  2. Form validation ensures valid input
  3. Cancel option to discard changes
- **Priority:** Medium

**US-026: Enable Dark Mode**
- As a user, I want to enable dark mode in the settings screen so that I can reduce eye strain during nighttime usage.
- **Acceptance Criteria:**
  1. Dark mode toggle available in settings
  2. Theme changes immediately when toggled
  3. Preference persists across sessions
- **Priority:** Low

**US-027: Update Name in Header**
- As a user, I want my updated name to be displayed in the app's header after I change it in the profile so that my changes are immediately visible.
- **Acceptance Criteria:**
  1. App header/welcome message updates after profile save
  2. No app restart required
  3. Name persists across sessions
- **Priority:** Low

---

## Notifications

### User Stories

**US-028: Enable/Disable Notifications**
- As a user, I want to be able to enable or disable notifications for the app so that I can choose whether or not to receive reminders for my habits.
- **Acceptance Criteria:**
  1. Global notification toggle available
  2. Setting persisted to local storage
  3. Notifications stop when disabled
- **Priority:** Medium

**US-029: Add Habits for Notifications**
- As a user, I want to select specific habits to receive notifications for so that I only get reminders for the habits I am actively working on.
- **Acceptance Criteria:**
  1. Per-habit notification toggle
  2. Only selected habits trigger notifications
  3. Settings saved per habit
- **Priority:** Medium

**US-030: Set Notification Times**
- As a user, I want to have the option to receive notifications three times a day (morning, afternoon, evening) for all selected habits so that I get timely reminders throughout the day.
- **Acceptance Criteria:**
  1. Three time slots: morning, afternoon, evening
  2. User can customize times for each slot
  3. Notifications scheduled accordingly
- **Priority:** Low

**US-031: Daily Reminder Notification**
- As a user, I want to receive a daily reminder notification so that I don't forget to complete my habits.
- **Acceptance Criteria:**
  1. Push notification sent at configured time
  2. Notification shows pending habits count
  3. Tapping notification opens app
- **Priority:** Medium

---

## Summary

| Feature Area | User Stories | Priority Distribution |
|--------------|--------------|----------------------|
| Login/Registration | 4 | 4 High |
| Home Screen | 4 | 2 High, 2 Medium |
| Detail Screen | 4 | 1 High, 2 Medium, 1 Low |
| Persistent Data | 4 | 2 High, 2 Medium |
| External API | 3 | 3 Low |
| Settings Menu | 4 | 2 High, 2 Medium |
| Settings Screen | 4 | 2 Medium, 2 Low |
| Notifications | 4 | 3 Medium, 1 Low |
| **Total** | **31** | **9 High, 13 Medium, 9 Low** |

---

## Related Resources

- [GitHub Issues](../../issues) - Detailed tracking of each user story
- [Product Backlog](./product_backlog.md) - Prioritized sprint planning

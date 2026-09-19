# 🪄 SpellCraft Academy

## Product Requirements Document (PRD)

**Version:** 1.0
**Platform:** Flutter Web + Mobile
**Backend:** Supabase
**Authentication:** Google OAuth via Supabase Auth
**Deployment:** Vercel
**Repository:** GitHub Public Repository
**PWA:** Required
**Development Environment:** Antigravity IDE
**Primary Goal:** Beginner-friendly but visually impressive Flutter educational puzzle game.

---

# 1. Product Overview

SpellCraft Academy is a fantasy-themed interactive puzzle game where the player becomes a student at a magical academy.

Players learn fictional spells by completing short puzzles, logic challenges, pattern-recognition challenges, and memory challenges.

Successfully completing lessons unlocks new spells and academy levels.

The application should feel like a polished fantasy game rather than a traditional educational application.

The project must remain technically simple enough for a beginner Flutter developer to understand and maintain.

---

# 2. Project Goals

The application must demonstrate:

1. Flutter application development.
2. Clean and visually appealing UI.
3. AI-assisted development using detailed prompts.
4. Supabase integration.
5. Google Login through Supabase Authentication.
6. User-specific data storage.
7. Supabase database synchronization.
8. Responsive Flutter Web UI.
9. PWA support.
10. GitHub public repository.
11. Vercel deployment.

---

# 3. Target Users

Primary target:

Students and casual users who enjoy:

* Fantasy games
* Puzzle games
* Magic-themed interfaces
* Short interactive challenges

The application should be understandable without requiring instructions longer than a few sentences.

---

# 4. Core Game Concept

The player joins SpellCraft Academy.

The academy contains multiple magical schools.

Each school contains lessons.

Each lesson contains a small puzzle.

Completing a puzzle successfully:

* awards XP,
* increases the player's level,
* unlocks a spell,
* updates progress in Supabase.

The initial version should contain a small but complete playable experience.

Do NOT build a large RPG system.

---

# 5. MVP Scope

The first release should contain:

## Authentication

* Google Login
* Logout
* Persistent authentication session
* User profile information

## Academy

Three magical schools:

1. Elemental Arts
2. Arcane Runes
3. Mystic Logic

Each school contains three lessons.

Total initial lessons:

9

## Spells

Each lesson unlocks one spell.

Initial spell list:

1. Lumos
2. Ignis
3. Aqua
4. Rune Lock
5. Arcane Shield
6. Mystic Key
7. Time Spark
8. Mind Echo
9. Astral Gate

The spells are fictional and are purely part of the game.

## Puzzle Types

Use simple puzzle mechanics.

### Puzzle Type 1 — Sequence

Example:

2 → 4 → 8 → ?

Answer:

16

### Puzzle Type 2 — Symbol Selection

Show several magical symbols.

Ask the player to select the correct symbol according to the clue.

### Puzzle Type 3 — Pattern Matching

Display a sequence of symbols and ask which symbol comes next.

### Puzzle Type 4 — Memory

Briefly display 4–6 magical symbols.

Hide them.

Ask the player to identify a previously displayed symbol.

### Puzzle Type 5 — Multiple Choice

Present a question with four answers.

Only one answer is correct.

---

# 6. Game Flow

The main application flow is:

```text
Launch App
    ↓
Welcome Screen
    ↓
Google Login
    ↓
Academy Dashboard
    ↓
Choose Magical School
    ↓
Choose Lesson
    ↓
Lesson Introduction
    ↓
Puzzle
    ↓
Answer
    ↓
Success / Failure
    ↓
XP Reward
    ↓
Spell Unlock
    ↓
Return to Academy
```

Returning users should skip the login/welcome experience when a valid Supabase session exists.

---

# 7. Screens

The application should contain the following screens.

---

## Screen 1 — Welcome Screen

Purpose:

Introduce the game.

Visual style:

* Dark fantasy background
* Deep navy/purple atmosphere
* Glowing magical particles
* Large academy logo/title
* Magical book or wand illustration
* Elegant fantasy typography

Content:

```text
SPELLCRAFT
ACADEMY

Master the Arcane.
Unlock Your Magic.

[ ENTER THE ACADEMY ]
```

The button opens the Login screen.

---

# 8. Screen 2 — Login Screen

Display:

```text
Welcome, Apprentice

Enter SpellCraft Academy

[ Continue with Google ]
```

Use Supabase Google OAuth.

After successful authentication:

Navigate to Academy Dashboard.

Do not create a custom password login system.

Google authentication is the only required login method for MVP.

---

# 9. Screen 3 — Academy Dashboard

This is the primary home screen after login.

Display:

* User avatar
* User display name
* Current level
* XP progress
* Number of unlocked spells
* Continue Learning button
* Magical schools
* Spellbook button
* Profile/logout option

Example:

```text
GOOD EVENING, APPRENTICE

Level 4
████████░░ 420 / 500 XP

Choose your path

┌─────────────────────┐
│ 🔥 ELEMENTAL ARTS   │
│ Master the elements  │
│ 2 / 3 lessons        │
└─────────────────────┘

┌─────────────────────┐
│ ᚱ ARCANE RUNES      │
│ Decode ancient magic │
│ 1 / 3 lessons        │
└─────────────────────┘

┌─────────────────────┐
│ ✦ MYSTIC LOGIC      │
│ Challenge your mind  │
│ 0 / 3 lessons        │
└─────────────────────┘

[ OPEN SPELLBOOK ]
```

---

# 10. Screen 4 — School Selection

Display all magical schools.

Each school card should contain:

* Icon
* Name
* Description
* Progress
* Locked/unlocked state

Example:

```text
🔥 Elemental Arts

Harness fire, water and elemental energy.

Progress
██████░░░░ 2 / 3
```

All three schools should be available in the MVP.

---

# 11. Screen 5 — Lesson Selection

Show lessons belonging to the selected school.

Example:

```text
ELEMENTAL ARTS

✓ Lesson 01 — Spark
✓ Lesson 02 — Flame
🔒 Lesson 03 — Tidal Force
```

A lesson is unlocked when the previous lesson is completed.

For MVP:

* Lesson 1 is unlocked.
* Lesson 2 unlocks after Lesson 1.
* Lesson 3 unlocks after Lesson 2.

---

# 12. Screen 6 — Lesson Introduction

Before each puzzle show a short story.

Example:

```text
LESSON 02

IGNIS

"The first flame is not created.
It is awakened."

The academy lantern flickers before you.

Focus your energy.
```

Button:

```text
[ BEGIN LESSON ]
```

Keep text short.

---

# 13. Screen 7 — Puzzle Screen

This is the main gameplay screen.

Display:

* Lesson title
* Progress indicator
* Puzzle question
* Puzzle content
* Answer controls
* Submit button

Example:

```text
IGNIS
LESSON 02

CHALLENGE 1 / 3

Complete the magical sequence.

🔥 → 🔥🔥 → 🔥🔥🔥 → ?

○ 4 flames
○ 5 flames
○ 6 flames
○ 8 flames

[ CAST SPELL ]
```

Each lesson should contain 3 small challenges.

---

# 14. Puzzle Rules

For MVP:

Each lesson contains exactly 3 questions.

A lesson is completed when all 3 questions are answered correctly.

If an answer is wrong:

Display a friendly message:

```text
The spell fizzled.

Try again, apprentice.
```

Do not permanently fail the lesson.

The player can retry.

---

# 15. Screen 8 — Lesson Success

After completing all challenges:

Display an animated success state.

Example:

```text
✨ SPELL MASTERED ✨

IGNIS

You have awakened the Flame Spell.

+100 XP

NEW SPELL UNLOCKED

🔥 IGNIS

[ ADD TO SPELLBOOK ]
```

Then allow:

```text
[ RETURN TO ACADEMY ]
```

---

# 16. Screen 9 — Spellbook

The spellbook shows all spells.

Unlocked spells should be visually distinct from locked spells.

Example:

```text
SPELLBOOK

🔥 IGNIS
Mastery: Beginner

💧 AQUA
Mastery: Beginner

✦ LUMOS
Mastery: Beginner

🔒 ARCANE SHIELD
Complete Arcane Runes II
```

Clicking an unlocked spell opens its detail.

---

# 17. Screen 10 — Spell Detail

Display:

* Spell icon
* Spell name
* Description
* School
* Date unlocked
* Mastery level
* XP earned

Example:

```text
🔥 IGNIS

ELEMENTAL ARTS

The first flame awakened
within the academy walls.

Mastery
Beginner

XP Earned
100

Unlocked
18 September 2026
```

---

# 18. Screen 11 — Profile

Display:

* Google profile photo
* Name
* Email
* Current level
* XP
* Lessons completed
* Spells unlocked

Buttons:

```text
[ LOG OUT ]
```

No additional account management is required.

---

# 19. User Progress System

Each authenticated user must have independent progress.

User progress includes:

* XP
* Current level
* Completed lessons
* Unlocked spells
* Lesson attempts
* Last played lesson

Never store progress globally.

Every progress record must be associated with the authenticated Supabase user ID.

---

# 20. XP System

Use a simple XP system.

Successful lesson:

+100 XP

Optional bonus:

+25 XP for completing a lesson without mistakes.

Level calculation:

```text
Level 1 = 0–199 XP
Level 2 = 200–399 XP
Level 3 = 400–599 XP
Level 4 = 600–799 XP
...
```

Do not build a complicated RPG progression system.

---

# 21. Supabase Database

Create the following tables.

---

## profiles

Columns:

```text
id UUID PRIMARY KEY
display_name TEXT
avatar_url TEXT
email TEXT
created_at TIMESTAMP
updated_at TIMESTAMP
```

The `id` must correspond to the Supabase authenticated user's ID.

---

## schools

Columns:

```text
id UUID PRIMARY KEY
name TEXT
description TEXT
icon TEXT
sort_order INTEGER
created_at TIMESTAMP
```

---

## lessons

Columns:

```text
id UUID PRIMARY KEY
school_id UUID
title TEXT
description TEXT
spell_name TEXT
spell_description TEXT
spell_icon TEXT
lesson_order INTEGER
created_at TIMESTAMP
```

---

## puzzles

Columns:

```text
id UUID PRIMARY KEY
lesson_id UUID
question TEXT
puzzle_type TEXT
options JSONB
correct_answer TEXT
sort_order INTEGER
created_at TIMESTAMP
```

---

## user_progress

Columns:

```text
id UUID PRIMARY KEY
user_id UUID
lesson_id UUID
completed BOOLEAN
score INTEGER
attempts INTEGER
completed_at TIMESTAMP
created_at TIMESTAMP
updated_at TIMESTAMP
```

---

## user_spells

Columns:

```text
id UUID PRIMARY KEY
user_id UUID
lesson_id UUID
spell_name TEXT
mastery_level TEXT
xp_earned INTEGER
unlocked_at TIMESTAMP
```

---

## user_stats

Columns:

```text
user_id UUID PRIMARY KEY
total_xp INTEGER
current_level INTEGER
lessons_completed INTEGER
spells_unlocked INTEGER
updated_at TIMESTAMP
```

---

# 22. Supabase Security

Row Level Security must be enabled for user-specific tables.

Users must only be able to access their own:

* user_progress
* user_spells
* user_stats
* profile

Users must not be able to modify another user's records.

Public read access can be used for static game content:

* schools
* lessons
* puzzles

Never expose the Supabase service-role key in Flutter.

Use only the Supabase anonymous/public client key in the application.

---

# 23. Google Authentication

Use Supabase Authentication with Google OAuth.

Required flow:

```text
Flutter
   ↓
Supabase Auth
   ↓
Google OAuth
   ↓
Google account
   ↓
Supabase session
   ↓
Flutter application
```

After login:

1. Check whether a profile exists.
2. Create a profile if necessary.
3. Create user_stats if necessary.
4. Navigate to Dashboard.

---

# 24. UI Design

The visual direction should be:

## Theme

Fantasy academy / magical library / arcane interface.

## Color direction

Use:

* Dark navy
* Deep purple
* Warm gold
* Soft violet
* Subtle cyan magical glow

Do not use excessive gradients.

Use gradients primarily for:

* hero backgrounds
* magical cards
* buttons
* glow effects

---

# 25. Typography

Use a fantasy-style display font for major titles.

Use a clean readable font for normal text.

Recommended:

Display:

```text
Cinzel
```

Body:

```text
Inter
```

If external fonts create deployment problems, use Flutter-compatible fallback fonts.

---

# 26. UI Components

Create reusable components:

```text
MagicButton
SpellCard
SchoolCard
LessonCard
XPProgressBar
PuzzleOption
GlassPanel
MagicBackground
AppHeader
```

Do not duplicate large UI sections between screens.

---

# 27. Responsive Design

The application must work on:

* Desktop
* Tablet
* Mobile browser

For desktop:

Use a centered content area with maximum width.

For mobile:

Cards should stack vertically.

The navigation must remain usable on small screens.

Do not design the web application as desktop-only.

---

# 28. Animations

Use simple Flutter animations.

Recommended:

* Fade-in
* Slide-in
* Scale animation
* Progress bar animation
* Spell unlock animation
* Button hover animation for web
* Subtle floating magical particles

Do not add complicated 3D graphics.

Performance is more important than visual effects.

---

# 29. PWA

The Flutter Web build must be installable as a Progressive Web App.

Requirements:

* Valid web manifest
* App icon
* Application name
* Theme color
* Responsive layout
* Service worker generated by Flutter
* Standalone display mode where supported

Test the deployed web application as a PWA.

---

# 30. GitHub

Create a public GitHub repository.

Suggested repository name:

```text
spellcraft-academy
```

Repository should contain:

```text
README.md
PRD.md
lib/
web/
android/
ios/
test/
pubspec.yaml
```

Do not commit:

* API secrets
* Supabase service-role keys
* local credentials
* `.env` files containing secrets

---

# 31. Deployment

Build:

```bash
flutter build web
```

The production web files should be generated successfully.

Deploy the Flutter web build to Vercel.

The deployed application must:

* Load correctly.
* Allow Google login.
* Communicate with Supabase.
* Save user progress.
* Work responsively.
* Support PWA installation.

---

# 32. Error Handling

Handle:

* Internet unavailable
* Supabase unavailable
* Google login failure
* Puzzle submission errors
* Database errors
* Empty data
* Authentication expiration

Show friendly messages instead of raw technical exceptions.

Example:

```text
The magical archives are temporarily unavailable.

Please try again.
```

Never show raw database errors to users.

---

# 33. Loading States

Every network-dependent screen must have an appropriate loading state.

Examples:

```text
Opening the academy...
Loading your spellbook...
Consulting the magical archives...
```

Use animated loading indicators where appropriate.

---

# 34. Empty States

Example:

```text
Your spellbook is waiting.

Complete your first lesson
to discover your first spell.
```

---

# 35. Accessibility

The UI should:

* Have readable text.
* Maintain sufficient contrast.
* Provide semantic labels where appropriate.
* Make buttons large enough to click.
* Avoid relying only on color to communicate state.

---

# 36. Seed Data

The application must include initial data for:

### School 1

Elemental Arts

Lessons:

1. Spark — Lumos
2. Flame — Ignis
3. Tidal Force — Aqua

### School 2

Arcane Runes

Lessons:

1. Ancient Marks — Rune Lock
2. Protective Glyph — Arcane Shield
3. Key of Ages — Mystic Key

### School 3

Mystic Logic

Lessons:

1. Time Pattern — Time Spark
2. Mind Mirror — Mind Echo
3. Astral Gate — Astral Gate

Each lesson must contain exactly three puzzles.

---

# 37. Sample Puzzle Data

## Lesson: Spark

Puzzle 1:

Question:

```text
Complete the sequence:

2 → 4 → 8 → ?
```

Options:

```text
10
12
16
18
```

Correct:

```text
16
```

Puzzle 2:

Question:

```text
Which symbol represents light?
```

Options:

```text
🌙
☀️
🌑
☁️
```

Correct:

```text
☀️
```

Puzzle 3:

Question:

```text
Which comes next?

✨ 🔥 ✨ 🔥 ?
```

Options:

```text
🔥
✨
🌙
💧
```

Correct:

```text
✨
```

---

# 38. Game Completion

The MVP is considered complete when:

1. User can open the application.
2. User can sign in with Google.
3. User reaches the Academy Dashboard.
4. User can select a school.
5. User can select an unlocked lesson.
6. User can complete three puzzles.
7. User receives XP.
8. User unlocks a spell.
9. Spell appears in Spellbook.
10. Progress is saved to Supabase.
11. User can log out.
12. User can log in again and see their saved progress.
13. Application works on mobile and desktop browsers.
14. `flutter build web` succeeds.
15. Application is deployed to Vercel.
16. Application can function as a PWA.
17. GitHub repository is public.

---

# 39. Out of Scope

Do NOT implement:

* Multiplayer
* Chat
* Real-time PvP
* Payments
* Complex inventory
* Character customization
* 3D graphics
* AI-generated puzzles
* Voice interaction
* Social networking
* Friend system
* Leaderboards
* Complex RPG combat
* Push notifications

These features may be considered future enhancements but are not part of MVP.

---

# 40. Future Enhancements

Possible future versions could add:

* More magical schools
* Daily quests
* Boss puzzles
* Achievement system
* Sound effects
* Background music
* More spell animations
* Leaderboards
* Multiplayer challenges
* AI-generated puzzle content

These features should NOT be implemented in the first version.

---

# 41. Architecture

Use a simple Flutter architecture.

Suggested structure:

```text
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── theme/
│   ├── constants/
│   └── utils/
│
├── models/
│   ├── profile.dart
│   ├── school.dart
│   ├── lesson.dart
│   ├── puzzle.dart
│   ├── spell.dart
│   └── user_progress.dart
│
├── services/
│   ├── auth_service.dart
│   ├── database_service.dart
│   └── progress_service.dart
│
├── screens/
│   ├── welcome/
│   ├── login/
│   ├── dashboard/
│   ├── schools/
│   ├── lessons/
│   ├── puzzle/
│   ├── spellbook/
│   └── profile/
│
└── widgets/
    ├── magic_button.dart
    ├── school_card.dart
    ├── lesson_card.dart
    ├── spell_card.dart
    ├── xp_bar.dart
    └── glass_panel.dart
```

Keep business logic out of UI widgets wherever practical.

---

# 42. Development Principle

The project must be developed incrementally.

Do NOT generate the entire application with a single AI prompt.

Development order:

```text
1. Project setup
2. Theme
3. Welcome screen
4. Google authentication
5. Supabase setup
6. Database
7. Dashboard
8. Schools
9. Lessons
10. Puzzle engine
11. XP
12. Spellbook
13. Profile
14. Progress synchronization
15. Responsive UI
16. PWA
17. Testing
18. GitHub
19. Vercel deployment
```

Each stage should be implemented and tested before moving to the next.

---

# 43. Definition of Done

The application must feel like a coherent magical academy experience.

The user should be able to:

```text
Login
 ↓
Enter Academy
 ↓
Choose School
 ↓
Choose Lesson
 ↓
Solve Puzzles
 ↓
Earn XP
 ↓
Unlock Spell
 ↓
View Spellbook
 ↓
Logout
 ↓
Login again
 ↓
See saved progress
```

The UI should be polished enough for a classroom demonstration while the underlying implementation remains beginner-friendly.

END OF PRD
# Maxx - Looksmaxing Glow-Up Progress Tracker

A privacy-first iOS app for tracking your glow-up journey. Built with SwiftUI, SwiftData, and zero external dependencies. All data stays on your device.

## Features

### Core
- **Progress Photo Tracking** - Capture and organize photos by category and angle
- **Before/After Comparison** - Side-by-side slider comparison of any two photos
- **Daily Routines** - Customizable routines with streak tracking and reminders
- **Glow Score** - Dynamic daily score based on routine completion, mood, and consistency
- **Analytics Dashboard** - Charts and insights powered by Swift Charts
- **Daily Check-In** - Rate your mood, skin, and confidence each day
- **Journal** - Optional daily journal entries

### Categories
Skin | Hair | Fitness | Face Structure | Style | Grooming | Posture | Teeth

### Onboarding (Woofz-style)
1. **Welcome** - Animated logo, feature preview, CTA
2. **Gender Selection** - Personalization step
3. **Goal Selection** - Total Transformation / Subtle Enhancements / Maintenance / Specific Area / Build Confidence
4. **Focus Areas** - Multi-select grid of categories
5. **Age Input** - Slider with personalized insights
6. **Commitment Level** - Casual / Consistent / Dedicated / Obsessed
7. **Analyzing** - Animated progress ring with step-by-step status
8. **Paywall** - RevenueCat-ready with weekly/monthly/yearly plans

### Privacy
- 100% local storage via SwiftData
- No backend servers, no Firebase, no Supabase
- No analytics or tracking SDKs
- Data never leaves the device

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI | SwiftUI (iOS 18+) |
| Language | Swift 6 |
| Persistence | SwiftData |
| Architecture | MVVM + @Observable |
| Charts | Swift Charts |
| Payments | RevenueCat (stubbed) |
| Notifications | UserNotifications |
| Photos | PhotosUI + PhotosPicker |

## Project Structure

```
Maxx/
├── App/
│   ├── MaxxApp.swift              # Entry point + SwiftData container
│   └── ContentView.swift          # Tab router + splash + onboarding gate
├── Models/
│   ├── UserProfile.swift          # User profile (SwiftData)
│   ├── ProgressPhoto.swift        # Photo model (SwiftData)
│   ├── DailyLog.swift             # Daily check-in (SwiftData)
│   ├── Routine.swift              # Routine model (SwiftData)
│   └── GlowUpCategory.swift       # Enums: categories, goals, etc.
├── Views/
│   ├── Onboarding/                # 8-screen Woofz-style flow
│   ├── Home/                      # Dashboard + daily check-in
│   ├── Progress/                  # Photo gallery + compare + camera
│   ├── Routines/                  # Routine list + add/edit
│   ├── Analytics/                 # Charts dashboard
│   ├── Settings/                  # Preferences + data management
│   └── Components/                # GlowScoreRing, StreakBadge, etc.
├── ViewModels/
│   ├── OnboardingViewModel.swift
│   ├── HomeViewModel.swift
│   ├── ProgressViewModel.swift
│   └── RoutineViewModel.swift
├── Services/
│   ├── PhotoStorageService.swift   # Image compression + thumbnails
│   ├── NotificationService.swift   # Local notifications
│   └── HapticService.swift         # Haptic feedback
└── Extensions/
    ├── Color+Theme.swift           # Full dark theme color system
    ├── Date+Helpers.swift          # Date formatting + ranges
    └── View+Modifiers.swift        # Glass card, shimmer, animations
```

## Build Instructions

### Prerequisites
- Xcode 16+
- iOS 18+ SDK
- macOS 15+ (Sequoia)

### Setup
1. Clone the repo
2. Open `Maxx.xcodeproj` in Xcode
3. Select your development team in Signing & Capabilities
4. Build and run on simulator or device (iOS 18+)

### Creating the Xcode Project
Since this is a code-first project, create the Xcode project:
1. Open Xcode > File > New > Project
2. Choose "App" under iOS
3. Set Product Name: `Maxx`
4. Interface: SwiftUI, Language: Swift, Storage: SwiftData
5. Save in the `Maxx-GlowUp-Tracker` directory
6. Delete the auto-generated files and replace with files from `Maxx/`

## RevenueCat Setup

The paywall is stubbed and ready for RevenueCat integration:

1. Install the RevenueCat SDK via SPM: `https://github.com/RevenueCat/purchases-ios`
2. Add your API key in `MaxxApp.swift`:
   ```swift
   Purchases.configure(withAPIKey: "YOUR_REVENUECAT_PUBLIC_KEY")
   ```
3. Create products in App Store Connect matching the paywall plans
4. Update `PaywallView.swift` to call `Purchases.shared.purchase(package:)`

## Screenshots

> Screenshots placeholder - add after first build

| Onboarding | Home | Progress | Routines | Analytics |
|:---:|:---:|:---:|:---:|:---:|
| ![](screenshots/onboarding.png) | ![](screenshots/home.png) | ![](screenshots/progress.png) | ![](screenshots/routines.png) | ![](screenshots/analytics.png) |

## License

Private repository. All rights reserved.

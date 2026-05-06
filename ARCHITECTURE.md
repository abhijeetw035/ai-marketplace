# SmartBazaar — Architecture Documentation

> **Target audience:** Technical interviewers, senior engineers, and contributors.
> **Stack:** SwiftUI · MVVM · Firebase · Combine · NWPathMonitor

---

## 1. Project Vision

SmartBazaar is an AI-powered secondhand marketplace for the Indian market.

**Core user flow:**
```
Seller posts item → AI suggests price → Listing goes live with trust score
    → Buyer searches intelligently → Buyer chats with negotiation help → Deal closes
```

The architecture is designed to support this flow end-to-end with clean separation of concerns, offline resilience, and AI integration at every interaction point.

---

## 2. Directory Structure

```
SmartBazaar/
├── App/
│   ├── SmartBazaarApp.swift        # Entry point, injects environment objects
│   └── MainTabView.swift           # Root navigation
├── Core/
│   ├── DesignSystem/
│   │   └── DesignSystem.swift      # Tokens, styles, button styles, animations
│   └── Components/
│       ├── TrustScoreView.swift    # TrustBadge + TrustScorePanel
│       ├── OfflineBanner.swift     # Connectivity banner
│       └── SkeletonLoader.swift    # Shimmer + skeleton cards
├── Features/
│   ├── Feed/                       # Home feed with pagination
│   ├── Search/                     # Intent-based semantic search
│   ├── CreateListing/              # Listing creation with AI pricing
│   ├── ListingDetail/              # Detail view with trust panel
│   ├── Chat/                       # Messaging with negotiation assistant
│   ├── Wishlist/                   # Saved listings
│   └── Profile/                    # User profile
├── Models/
│   └── Models.swift                # Codable domain models
└── Services/
    ├── FirebaseListingService.swift # Firestore CRUD + pagination
    ├── FirebaseAuthService.swift    # Firebase Auth
    ├── ChatService.swift            # Mock + Firebase chat
    ├── WishlistService.swift        # Firebase wishlist sub-collection
    ├── AIService.swift              # AI pricing, negotiation, intent search
    ├── TrustScoreService.swift      # Rule-based trust scoring engine
    ├── CacheService.swift           # File-system JSON cache
    ├── SyncService.swift            # Persistent offline action queue
    ├── NetworkMonitor.swift         # NWPathMonitor connectivity
    ├── AnalyticsService.swift       # Typed analytics events
    └── NotificationService.swift   # Local push notifications
```

---

## 3. Architectural Pattern — MVVM + Service Layer

```
View  ──→  ViewModel  ──→  ServiceProtocol  ──→  Firebase / AI / Cache
  ↑                ↓
@Published state   Combine / async-await
```

- **Views** are pure SwiftUI — no business logic, only layout.
- **ViewModels** are `@MainActor` classes that own state and orchestrate services.
- **Services** are protocol-based with production Firebase implementations and `Mock*` variants for previews and tests.
- All async work uses Swift Concurrency (`async/await`, `Task`, structured cancellation).

---

## 4. Key Services

### 4.1 Firebase Listing Service
- Cursor-based pagination using `DocumentSnapshot` as the page cursor (not offset).
- `updateListing` uses `setData(merge: false)` — full overwrites to avoid partial-update conflicts.
- Image upload stub is ready to swap in `Storage.storage().reference()` calls.

### 4.2 AI Service (MockAIService)
Three separate AI capabilities, all behind `AIServiceProtocol`:

| Method | What it does |
|--------|-------------|
| `suggestPrice` | Category baselines × condition multiplier × description-signal refinement |
| `analyzeNegotiation` | Extracts offer amount via number parsing, computes deal probability, generates quick replies |
| `parseSearchIntent` | Extracts budget, category, use-case from natural language; scores and re-ranks listing results |

**Swap path:** Replace `MockAIService` with a `GeminiAIService` that calls the Gemini API. The protocol boundary means zero ViewModelchanges.

### 4.3 Trust Score Engine
Purely synchronous, no network calls. Evaluates a `Listing` against four dimensions (25 pts each):
- **Title** — length, spam words, ALL CAPS
- **Description** — length, embedded phone numbers, external links, off-platform payment cues
- **Price** — category-specific expected range, suspiciously low values
- **Images** — presence and quantity

Outputs a `TrustGrade` (`Trusted / Moderate / Caution / Suspicious`) with an explanatory string and a list of typed `TrustFlag`s.

### 4.4 Offline-First Sync
```
User action (offline)
    → PersistentSyncService.enqueue(type:payload:)
        → persisted to UserDefaults as Codable JSON

Network reconnects (NWPathMonitor)
    → FeedViewModel.onReconnect()
        → syncService.syncPendingActions()      // flushes queue
        → fetchListings()                        // refreshes feed
        → NotificationService.scheduleSyncCompleteNotification()
```

Conflict resolution policy: **last-write-wins** with automatic discard after 3 retries.

---

## 5. Data Flow — Create Listing (with AI pricing)

```
User types title/description
    → CreateListingViewModel.suggestPrice()  [debounced 1 s]
        → AIService.suggestPrice(title:description:category:condition:)
            → Returns PriceSuggestionResult
        → Updates price field + shows explanation text in UI

User taps Publish
    → CreateListingViewModel.publishListing()
        if online  → FirebaseListingService.createListing()
        if offline → FeedViewModel.queueCreateListing()  [synced later]
```

---

## 6. Data Flow — Negotiation Chat

```
Incoming message received
    → ChatViewModel.analyzeLatestMessageForNegotiation()
        → AIService.analyzeNegotiation(message:currentPrice:isSeller:)
            → Returns NegotiationAnalysisResult
                · isOffer: Bool
                · dealProbability: Int (0–100)
                · suggestionText: String
                · quickReplies: [String]
    → ChatView renders AI banner with deal probability badge + quick-reply chips

User taps quick reply
    → ChatViewModel.sendMessage(text:)
    → AI banner dismissed immediately (optimistic UX)
```

---

## 7. Analytics Strategy

All events are defined as a typed `AnalyticsEvent` enum with associated values. Logging is a single call site:

```swift
AnalyticsService.shared.log(.searchPerformed(query: query, resultCount: results.count))
```

**Swap path:** Replace the `print` statement in `AnalyticsService.log()` with `Analytics.logEvent()` from Firebase Analytics — no callers change.

Key events tracked:
- Feed views, pagination, card taps
- AI price suggestion requests
- Listing publish (with price + category)
- Search queries and no-result rates
- Negotiation hint impressions and quick-reply usage
- Offline banner shown + sync completions

---

## 8. Design System

All UI primitives defined in `DesignSystem.swift`:

| Token | Value |
|-------|-------|
| Primary colour | `#111111` |
| Accent (blue) | `#2563EB` |
| Background | `#FFFFFF` |
| Secondary background | `#F8F9FA` |
| Success | Green |
| Warning | Orange |
| Error | Red |
| Corner radii | 8 / 12 / 16 / 50 px |
| Spacing | 4 / 8 / 16 / 24 / 32 px |

Reusable button styles:
- `PrimaryButtonStyle` — full-width, accent fill, spring press animation, drop shadow
- `ScalePressButtonStyle` — scale-only press for cards
- `AppearAnimation` modifier — fade-in + slide-up entrance with configurable delay for staggered list animations

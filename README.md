# BiteBack

**BiteBack** is a location-aware, mission-driven engagement platform that enables local businesses to incentivize customer behavior through real-world challenges and digital rewards. By combining QR code technology, real-time location filtering, and Firebase-backed data persistence, BiteBack empowers restaurants and service providers to drive customer retention in a novel, gamified way.

## 🌟 Key Features

- **Business Missions**: Businesses can create custom missions (e.g., "Try our new sandwich!" or "Bring a friend") that customers complete in exchange for free items or rewards.
- **QR Code Redemption**: Each mission generates a secure QR code that can be scanned for validation at the business location.
- **Location-Aware Discovery**: Customers see only nearby, verified businesses with active missions using a real-time map interface powered by CoreLocation.
- **Role-Based Onboarding**: Separate onboarding for consumers and businesses with tailored fields, including business verification and geolocation setup.
- **Firebase Integration**: Full backend support using Firebase Auth and Firestore, including user storage, mission tracking, and business verification.

## 🔧 Technologies Used

- **Frontend**: SwiftUI, MapKit, CoreLocation, CodeScanner
- **Backend**: Firebase Authentication, Firestore Database
- **Platform**: iOS (iPhone compatible)
- **Tools**: Xcode, CocoaPods, Git, Google Firebase Console

## 📱 User Roles

### 👤 Consumer
- Browse nearby missions on an interactive map
- Complete tasks to earn rewards
- Scan QR codes at participating businesses to confirm mission completion

### 🏢 Business
- Sign up with verification (name, address, etc.)
- Create and manage time-limited missions
- Scan customers’ QR codes to validate completion and track engagement

## 🧠 System Design Highlights

- **Real-Time Location Filtering**: Only display businesses within a configurable radius from the user's current location.
- **QR Code Workflow**: Secure encoding of mission identifiers in scannable QR formats, validated upon scan.
- **Firestore Schema**:
  - `users/` — Separate documents for consumers and business users
  - `missions/` — Each mission document contains references to business, reward, expiration, and QR status
  - `redemptions/` — Tracks which users have completed which missions

## 🚀 Future Improvements

- Mission expiration & analytics dashboard for businesses
- Push notifications for new nearby missions
- Reward tier system for customer loyalty
- Admin portal for verifying businesses and flagging abuse
---

> BiteBack reimagines local loyalty by turning customer engagement into a rewarding game — all while giving businesses the tools to drive traffic, build community, and grow smarter.

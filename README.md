# Expenny: Transaction Tracking Flutter App

[![Expenny App Icon](/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png)](https://play.google.com/store/apps/details?id=com.ojasvishaklya.expenny)

A minimal expense tracker for Android. Log transactions by hand, or let Expenny import them automatically from your bank's SMS alerts. Everything stays on your device.

Available on the [Google Play Store](https://play.google.com/store/apps/details?id=com.ojasvishaklya.expenny).

## Screenshots

<img src="/screenshots/image1.jpeg" alt="Expenny Screenshot 1" width="200"/> <img src="/screenshots/image2.jpeg" alt="Expenny Screenshot 2" width="200"/> <img src="/screenshots/image3.jpeg" alt="Expenny Screenshot 3" width="200"/> <img src="/screenshots/image4.jpeg" alt="Expenny Screenshot 4" width="200"/>

## Features

- **SMS auto-import** — Reads bank transaction alerts from your inbox and turns them into transactions, no typing required.
- **Transaction tracking** — Add, edit, and delete transactions.
- **Categorization** — Tag transactions as Food, Transportation, Entertainment, and more.
- **Visual insights** — Charts and tag-wise breakdowns to see where the money goes.
- **Offline by design** — No network calls, no accounts, no telemetry. The release build doesn't declare the `INTERNET` permission, so it can't reach the network. The only permission Expenny asks you for is `READ_SMS`, and messages are read locally and never leave the device. See [Permissions](#permissions) for everything the app declares.

## SMS Auto-Import

Grant SMS access once from **Preferences → Import from Messages**, and Expenny handles the rest:

- **Automatic** — Syncs silently on app start. New alerts appear as transactions without any action.
- **No duplicates** — Each message is tracked by its SMS id, so re-syncing never double-counts. Editing an imported transaction won't cause it to reappear.
- **Incremental** — Looks back three months on first import, then only reads what's new.
- **Verifiable** — The original message is saved with the transaction and shown on the edit screen, so you can always check what a figure came from.

Imported transactions land under the `miscellaneous` tag with `Card/UPI` as the payment method — retag them from the edit screen as you like.

## Permissions

The release APK declares the permissions below. Expenny itself declares only `READ_SMS`; the rest are added by libraries it depends on. None of them allows network access.

| Permission | Added by | Why |
|---|---|---|
| `READ_SMS` | Expenny | Reads bank alerts for SMS auto-import. Expenny asks for it only when you tap **Import from Messages**. |
| `ACCESS_COARSE_LOCATION` | `another_telephony` (SMS reading) | Declared by the library for telephony features Expenny doesn't use. Expenny never requests it, so it stays off. |
| `WAKE_LOCK`, `RECEIVE_BOOT_COMPLETED`, `FOREGROUND_SERVICE`, `ACCESS_NETWORK_STATE` | `androidx.work`, via `home_widget` | Background scheduling used by the home screen widget library. Android grants these automatically at install. |
| `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` | `androidx.core` | Private to the app. It keeps Expenny's internal broadcast receivers closed to other apps. |

Debug and profile builds (what `flutter run` produces) also declare `INTERNET` for Flutter's development tooling, and debug builds add external-storage permissions. The release build on the Play Store has neither.

## Getting Started

```bash
git clone https://github.com/ojasvishaklya/expenny-android.git
cd expenny-android
flutter pub get
flutter run
```

## Roadmap

- [ ] Reminder notifications to prompt regular transaction entry
- [ ] Budget limits with notifications when approaching or exceeding them
- [ ] Multi-currency support with conversion
- [ ] App lock for sensitive financial data
- [ ] Sync on app resume, so alerts arriving while backgrounded are picked up immediately

## Contributing

Contributions are welcome at any skill level, whether it's your first open-source PR or a deep change.

1. Fork the repository and clone your fork
2. Make your changes
3. Verify them — `flutter analyze` and `flutter build apk --release` should both pass
4. Open a pull request describing what changed

Found a bug or have an idea? Open an issue on the [Issues](https://github.com/ojasvishaklya/expenny-android/issues) page.

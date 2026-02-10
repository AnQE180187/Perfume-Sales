# Profile Feature - Quick Reference

## 🚀 Quick Start

```dart
// Import the profile screen
import 'package:perfume_gpt_app/features/profile/presentation/screens/profile_screen.dart';

// Use in navigation
Navigator.pushNamed(context, '/profile');
// or
context.go('/profile');
```

## 📂 File Structure

```
profile/
├─ models/user_profile.dart           # User data model
├─ providers/profile_provider.dart    # State management
└─ presentation/
    ├─ screens/profile_screen.dart    # Main screen
    ├─ sections/                      # UI sections
    │   ├─ profile_header_section.dart
    │   ├─ user_identity_section.dart
    │   ├─ olfactory_signature_section.dart
    │   └─ account_actions_section.dart
    └─ widgets/                       # Reusable widgets
        ├─ profile_action_tile.dart
        └─ ai_insight_card.dart
```

## 🧩 Reusable Components

### ProfileActionTile

Use for any list item with icon + title + chevron:

```dart
ProfileActionTile(
  icon: Icons.shopping_bag_outlined,
  title: 'My Orders',
  subtitle: '2 active shipments', // Optional
  onTap: () => Navigator.pushNamed(context, '/orders'),
)
```

### AiInsightCard

Use for displaying AI-generated insights:

```dart
AiInsightCard(
  olfactoryTags: ['Woody', 'Citrus', 'Bergamot'],
  onFindNextScent: () => Navigator.pushNamed(context, '/consultation'),
  onViewScentProfile: () => Navigator.pushNamed(context, '/scent-profile'),
)
```

## 📊 State Management

```dart
// Watch profile state
final profileAsync = ref.watch(profileProvider);

profileAsync.when(
  data: (profile) => Text(profile.name),
  loading: () => CircularProgressIndicator(),
  error: (e, _) => Text('Error: $e'),
);

// Access profile notifier
ref.read(profileNotifierProvider.notifier).editProfile();
```

## 🎯 Adding New Profile Actions

1. Add to `AccountActionsSection`:

```dart
ProfileActionTile(
  icon: Icons.settings_outlined,
  title: 'Settings',
  onTap: onSettings, // Pass callback from parent
)
```

2. Handle navigation in `profile_screen.dart`:

```dart
void _handleSettings(BuildContext context) {
  Navigator.pushNamed(context, '/settings');
}
```

## 🧪 Testing

```bash
# Test models
flutter test test/features/profile/models/

# Test widgets
flutter test test/features/profile/presentation/widgets/

# Test full screen
flutter test test/features/profile/presentation/screens/
```

Example widget test:

```dart
testWidgets('ProfileActionTile displays title', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ProfileActionTile(
        icon: Icons.shopping_bag,
        title: 'My Orders',
        onTap: () {},
      ),
    ),
  );

  expect(find.text('My Orders'), findsOneWidget);
});
```

## 🔄 Migration from Old Profile

Old import (deprecated):

```dart
import 'lib/features/membership/presentation/profile_screen.dart';
```

New import:

```dart
import 'lib/features/profile/presentation/screens/profile_screen.dart';
```

**Note**: Old import still works via export, but use new path for clarity.

## 📝 Common Tasks

### Add New Section

1. Create file in `presentation/sections/`
2. Import in `profile_screen.dart`
3. Add to ListView in correct order

### Customize AI Card

Modify `ai_insight_card.dart` or create variant:

```dart
// Create custom variant
class CompactAiInsightCard extends AiInsightCard {
  // Custom implementation
}
```

### Change Navigation

Update handlers in `profile_screen.dart`:

```dart
void _handleMyOrders(BuildContext context) {
  // Custom navigation logic
  context.push('/orders');
}
```

## 🎨 Theming

All components use:

- `AppTheme.accentGold` for accents
- `AppTheme.deepCharcoal` for text
- `AppTheme.mutedSilver` for secondary text
- `AppTheme.ivoryBackground` for backgrounds

## 📚 Documentation

- [Full Refactor Summary](./PROFILE_REFACTOR_SUMMARY.md)
- [Architecture Details](../../PROFILE_SCREEN_REFACTOR.md)

## 💡 Tips

1. **Keep screen thin**: Profile screen should only orchestrate, not implement UI
2. **Use sections**: Group related UI in section files
3. **Extract reusable**: If used >1 time, make it a widget
4. **Test independently**: Each component should be testable alone
5. **Document why**: Add comments explaining decisions, not implementation

## 🐛 Common Issues

### Profile not loading?

Check `profileProvider` state:

```dart
ref.listen(profileProvider, (prev, next) {
  next.when(
    data: (_) => print('Profile loaded'),
    loading: () => print('Loading...'),
    error: (e, _) => print('Error: $e'),
  );
});
```

### Navigation not working?

Ensure routes are registered in main router config.

### Styling issues?

Import theme:

```dart
import 'package:perfume_gpt_app/core/theme/app_theme.dart';
```

## 📞 Support

For questions about the Profile feature refactor, contact the team or refer to the comprehensive documentation files.

---

**Version**: 1.0  
**Last Updated**: January 2026  
**Status**: Production Ready ✅

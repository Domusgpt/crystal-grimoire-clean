# 🤝 Contributing to CrystalGrimoire

Thank you for your interest in contributing to CrystalGrimoire! This guide will help you get started.

## 🏗️ Project Structure

```
crystal_grimoire_flutter/    # Flutter app
├── lib/
│   ├── screens/           # UI screens
│   ├── services/          # Business logic
│   ├── models/           # Data models
│   └── widgets/          # Reusable components

backend_crystal/           # Python backend
├── app_server.py         # Main FastAPI server
└── app/                  # Backend modules
```

## 🔧 Development Setup

1. **Fork and Clone**
   ```bash
   git clone https://github.com/[YOUR_USERNAME]/crystal-grimoire-clean.git
   cd crystal-grimoire-clean
   ```

2. **Create Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make Changes**
   - Follow existing code style
   - Add tests for new features
   - Update documentation

4. **Test Your Changes**
   ```bash
   # Backend tests
   cd backend_crystal
   pytest

   # Flutter tests
   cd crystal_grimoire_flutter
   flutter test
   ```

## 📝 Code Style

### Flutter/Dart
- Use `flutter analyze` before committing
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Format with `flutter format .`

### Python
- Follow PEP 8
- Use type hints
- Format with `black`
- Lint with `flake8`

## 🔄 Pull Request Process

1. **Update Documentation**
   - Add/update relevant docs
   - Update README if needed
   - Add inline comments for complex logic

2. **Write Good Commit Messages**
   ```
   feat: Add crystal sharing feature
   
   - Implement share button on results screen
   - Add social media integration
   - Update UI tests
   
   Closes #123
   ```

3. **PR Description Template**
   ```markdown
   ## Description
   Brief description of changes

   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Breaking change
   - [ ] Documentation update

   ## Testing
   - [ ] Unit tests pass
   - [ ] Manual testing completed
   - [ ] No console errors

   ## Screenshots (if applicable)
   ```

## 🧪 Testing Guidelines

### Flutter Tests
```dart
// Example widget test
testWidgets('Crystal card displays name', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: CrystalCard(crystal: mockCrystal),
    ),
  );
  
  expect(find.text('Amethyst'), findsOneWidget);
});
```

### Backend Tests
```python
# Example API test
def test_identify_crystal():
    response = client.post(
        "/api/v1/crystal/identify",
        files={"images": test_image},
    )
    assert response.status_code == 200
    assert "crystal" in response.json()
```

## 🎯 Areas for Contribution

### High Priority
- 🔧 Implement missing features (journal, settings, payments)
- 🧪 Add comprehensive test coverage
- 📱 Improve mobile responsiveness
- 🌐 Add internationalization

### Good First Issues
- 📝 Fix typos in documentation
- 🎨 Improve UI animations
- 🐛 Fix small bugs
- ✨ Add loading states

### Feature Ideas
- 🔍 Advanced search filters
- 📊 Crystal statistics dashboard
- 🎮 Gamification elements
- 🤖 Voice identification

## 🚫 What Not to Do

- Don't commit API keys or secrets
- Don't break existing tests
- Don't change core architecture without discussion
- Don't add large dependencies without justification

## 💬 Communication

- **Issues**: Use GitHub issues for bugs and features
- **Discussions**: Use GitHub discussions for questions
- **Discord**: Join our community (link in README)

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for helping make CrystalGrimoire better! 🔮✨
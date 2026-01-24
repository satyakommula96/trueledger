# TrueCash

A privacy-first personal finance tracker with AI-powered insights.

[![CI](https://github.com/satyakommula96/truecash/actions/workflows/ci.yml/badge.svg)](https://github.com/satyakommula96/truecash/actions/workflows/ci.yml)
[![Documentation](https://github.com/satyakommula96/truecash/actions/workflows/deploy-docs.yml/badge.svg)](https://github.com/satyakommula96/truecash/actions/workflows/deploy-docs.yml)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## 🌟 Features

- **💰 Complete Financial Tracking**: Track income, expenses, budgets, and saving goals
- **🤖 AI-Powered Insights**: Get intelligent forecasts and personalized financial advice
- **🔒 Privacy First**: All data stored locally with optional encryption
- **📊 Beautiful Analytics**: Visualize your financial health with interactive charts
- **🌙 Modern UI**: Dark mode, smooth animations, and premium design
- **📱 Cross-Platform**: Available on Android, iOS, Linux, macOS, Windows, and Web

## 📖 Documentation

**📚 [View Live Documentation](https://satyakommula96.github.io/truecash/)** | **📂 [Browse docs/ folder](docs/)**

### Start Here

**New to the project?** Read **[docs/architecture/overview.md](docs/architecture/overview.md)** first.

This comprehensive guide covers:
- Clean Architecture principles and layer boundaries
- Data flow through the application
- Non-negotiable architectural rules
- State management with Riverpod
- Key design patterns

Then proceed to **[docs/development/adding-features.md](docs/development/adding-features.md)** to learn the development workflow.

### Core Documentation

- **[Installation Guide](docs/getting-started/installation.md)** - Setup for all platforms
- **[Architecture Overview](docs/architecture/overview.md)** - System design and principles
- **[Adding Features](docs/development/adding-features.md)** - Step-by-step development guide
- **[Error Handling](docs/development/error-handling.md)** - Result pattern and failure types
- **[Testing Guide](docs/development/testing.md)** - Testing strategy and patterns
- **[Contributing Guidelines](docs/contributing/guidelines.md)** - How to contribute

### Local Documentation Server

```bash
# Install MkDocs
pip install -r requirements.txt

# Serve documentation locally
mkdocs serve

# View at http://127.0.0.1:8000/
```

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.0+
- Dart SDK 3.0+

### Installation

```bash
# Clone the repository
git clone https://github.com/satyakommula96/truecash.git
cd truecash

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Platform-Specific Setup

#### Linux
```bash
sudo apt-get install libsecret-1-dev libjsoncpp-dev libsqlite3-dev
```

#### macOS
```bash
xcode-select --install
```

#### Windows
Ensure Visual Studio 2022 with C++ tools is installed.

## 🏗️ Architecture

TrueCash follows **Clean Architecture** principles with four distinct layers:

```
┌─────────────────────────────────────┐
│      Presentation Layer             │  (UI, Providers, Screens)
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│        Domain Layer                 │  (Use Cases, Entities, Interfaces)
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│         Data Layer                  │  (Repositories, Data Sources)
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│         Core Layer                  │  (Utils, Services, Theme)
└─────────────────────────────────────┘
```

See [Architecture Documentation](docs/architecture/overview.md) for details.

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test
flutter test test/unit/domain/usecases/
```

**Test Results**: All 21 tests passing ✅
- 19 Unit tests
- 1 Widget test
- 1 Integration test

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](docs/contributing/guidelines.md) for details.

### Development Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests (`flutter test`)
5. Run analyzer (`flutter analyze`)
6. Format code (`dart format .`)
7. Commit changes (`git commit -m 'feat: add amazing feature'`)
8. Push to branch (`git push origin feature/amazing-feature`)
9. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with [Flutter](https://flutter.dev/)
- State management with [Riverpod](https://riverpod.dev/)
- Database with [SQLite](https://www.sqlite.org/)
- Icons from [Material Icons](https://fonts.google.com/icons)

## 📧 Contact

- GitHub: [@satyakommula96](https://github.com/satyakommula96)
- Issues: [GitHub Issues](https://github.com/satyakommula96/truecash/issues)

---

**Made with ❤️ for privacy-conscious users**

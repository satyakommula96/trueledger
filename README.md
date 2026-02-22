# TrueLedger

A privacy-first personal finance tracker with AI-powered insights.

[![CI](https://github.com/satyakommula96/trueledger/actions/workflows/ci.yml/badge.svg)](https://github.com/satyakommula96/trueledger/actions/workflows/ci.yml)
[![Documentation](https://github.com/satyakommula96/trueledger/actions/workflows/deploy-docs.yml/badge.svg)](https://github.com/satyakommula96/trueledger/actions/workflows/deploy-docs.yml)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)

### 🚀 **[Live Web Demo](https://trueledger.satyakommula.com)**

## 🌟 Features

- **💰 Complete Financial Tracking**: Track income, expenses, budgets, and saving goals.
- **🌐 Web Support**: Fully responsive web version powered by **SQLite WASM** for local persistence.
- **🤖 AI-Powered Insights**: An intelligent local engine that analyzes your financial behavior to provide actionable advice:
  - **Wealth Projections**: Predicts net worth growth based on current savings velocity.
  - **Overspending & Burn Rate**: Detects abnormal spending surges and calculates how many days your liquid assets will last if income stops.
  - **Subscription Leakage**: Identifies zombie subscriptions consuming disproportionate amounts of income.
  - **True Cost Analysis**: Translates heavy spending categories into "hours of life worked" based on your effective hourly wage.
- **🔒 Privacy First**: All data stored locally with AES-256 encryption (SQLCipher) on mobile/desktop.
- **📊 Beautiful Analytics**: Visualize your financial health with interactive charts and streak tracking.
- **🌙 Modern UI**: Dark mode, smooth animations, and premium design inspired by modern fintech apps.
- **📱 Cross-Platform**: Native experience on Android, iOS, Linux, macOS, Windows, and Web.

## 📖 Documentation

**📚 [View Live Documentation](https://satyakommula96.github.io/trueledger/)** | **📂 [Browse docs/ folder](docs/)**

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

### 🧪 Demo Data / Seeding
To easily experience TrueLedger with a rich set of populated data, you can instantly inject demo entries (transactions, budgets, loans, investments, and more):
1. Launch the **TrueLedger App**.
2. Navigate to **Settings** -> **Data & Privacy**.
3. Tap on **Seed Data** to automatically populate your dashboard. You can clear this anytime by tapping **Clear All Data**.

### Prerequisites

- Flutter SDK 3.0+
- Dart SDK 3.0+

### Installation

```bash
# Clone the repository
git clone https://github.com/satyakommula96/trueledger.git
cd trueledger

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### 🐳 Docker Deployment (Web)

For web deployment with Docker (ideal for Vercel, cloud hosting, or local testing):

```bash
# Quick start with Docker Compose
cd docker
docker-compose up --build

# Or with Docker CLI
docker build -f docker/Dockerfile -t trueledger-web .
docker run -d -p 8080:80 --name trueledger trueledger-web
```

Access at: http://localhost:8080

**📚 See [docs/deployment/docker-quickstart.md](docs/deployment/docker-quickstart.md) for quick reference or [docker/README.md](docker/README.md) for complete documentation.**

### Platform-Specific Setup

#### Linux
```bash
sudo apt-get install libsecret-1-dev libjsoncpp-dev libsqlite3-dev libsqlcipher-dev libssl-dev
```

#### macOS
```bash
# Ensure Xcode Command Line Tools are installed
xcode-select --install

# Install SQLCipher for database encryption
brew install sqlcipher
```

#### Windows
1. Ensure Visual Studio 2022 with C++ tools is installed.
2. For database encryption, ensure a **`sqlcipher.dll`** is available. This can be:
   - Obtained from a prebuilt binary distribution (e.g., [Zetetic](https://www.zetetic.net/sqlcipher/))
   - Installed via a package manager like `vcpkg`
   - Bundled in your application directory for release.

## 🏗️ Architecture

TrueLedger follows **Clean Architecture** principles with four distinct layers:

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

**Test Results**:
- Unit tests
- Widget tests
- Integration tests

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

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with [Flutter](https://flutter.dev/)
- State management with [Riverpod](https://riverpod.dev/)
- Database with [SQLite](https://www.sqlite.org/)
- Icons from [Material Icons](https://fonts.google.com/icons)

## 📧 Contact

- GitHub: [@satyakommula96](https://github.com/satyakommula96)
- Issues: [GitHub Issues](https://github.com/satyakommula96/trueledger/issues)

---

**Made with ❤️ for privacy-conscious users**

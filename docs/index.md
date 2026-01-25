# TrueCash Documentation

Welcome to the **TrueCash** documentation! TrueCash is a privacy-first, offline-first personal finance tracker with AI-powered insights.

## 🌟 Key Features

- **💰 Complete Financial Tracking**: Track income, expenses, budgets, and saving goals
- **🤖 AI-Powered Insights**: Get intelligent forecasts and personalized financial advice
- **🔒 Privacy First**: All data stored locally with optional encryption ([View Policy](privacy.md))
- **📊 Beautiful Analytics**: Visualize your financial health with interactive charts
- **🌙 Modern UI**: Dark mode, smooth animations, and premium design
- **📱 Cross-Platform**: Available on Android, iOS, Linux, macOS, Windows, and Web

## 🚀 Quick Links

<div class="grid cards" markdown>

-   :material-clock-fast:{ .lg .middle } __Getting Started__

    ---

    Install TrueCash and start tracking your finances in minutes

    [:octicons-arrow-right-24: Installation Guide](getting-started/installation.md)

-   :material-code-braces:{ .lg .middle } __Architecture__

    ---

    Learn about the Clean Architecture pattern and project structure

    [:octicons-arrow-right-24: Architecture Overview](architecture/overview.md)

-   :material-hammer-wrench:{ .lg .middle } __Development__

    ---

    Contribute to TrueCash and add new features

    [:octicons-arrow-right-24: Development Guide](development/adding-features.md)

-   :material-test-tube:{ .lg .middle } __Testing__

    ---

    Write and run tests for quality assurance

    [:octicons-arrow-right-24: Testing Guide](development/testing.md)

</div>

## 📖 What's Inside

This documentation covers:

- **Getting Started**: Installation, configuration, and quick start guides
- **Architecture**: Deep dive into Clean Architecture, layers, and design patterns
- **Development**: How to add features, write tests, and follow best practices
- **Features**: Detailed guides for each app feature
- **Database**: Schema, migrations, and performance optimization
- **Platform-Specific**: Platform-specific implementation details
- **CI/CD**: Continuous integration and deployment workflows

## 🏗️ Architecture at a Glance

TrueCash follows **Clean Architecture** principles with four distinct layers:

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (UI, Screens, Widgets, Providers)      │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│          Domain Layer                   │
│  (Use Cases, Models, Repositories)      │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│           Data Layer                    │
│  (Repository Impl, Data Sources)        │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│           Core Layer                    │
│  (Utils, Services, Constants)           │
└─────────────────────────────────────────┘
```

[Learn more about the architecture →](architecture/overview.md)

## 🎯 Philosophy

TrueCash is built with these core principles:

1. **Privacy First**: Your financial data never leaves your device
2. **Offline First**: Full functionality without internet connection
3. **User Experience**: Beautiful, intuitive, and delightful to use
4. **Code Quality**: Clean, testable, and maintainable codebase
5. **Cross-Platform**: One codebase, six platforms

## 🤝 Contributing

We welcome contributions! Check out our [Contributing Guidelines](contributing/guidelines.md) to get started.

## 📄 License

TrueCash is open source software. See the repository for license details.

---

**Ready to dive in?** Start with the [Installation Guide](getting-started/installation.md) or explore the [Architecture Overview](architecture/overview.md).

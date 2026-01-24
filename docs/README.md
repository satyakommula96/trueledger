# TrueCash Documentation

## 📖 Overview

This folder contains the complete documentation for TrueCash, a privacy-first personal finance tracker built with Flutter and Clean Architecture.

### Core Documentation

- **[architecture/overview.md](architecture/overview.md)** – App architecture, Clean Architecture principles, and layer boundaries
- **[getting-started/installation.md](getting-started/installation.md)** – Local development setup and platform-specific requirements
- **[database/schema.md](database/schema.md)** – Database schema, tables, and relationships
- **[development/testing.md](development/testing.md)** – Testing strategy, patterns, and CI/CD
- **[development/adding-features.md](development/adding-features.md)** – Step-by-step guide to adding new features

### Additional Resources

- **[getting-started/quick-start.md](getting-started/quick-start.md)** – 5-minute tutorial for new users
- **[architecture/clean-architecture.md](architecture/clean-architecture.md)** – Deep dive into Clean Architecture
- **[contributing/guidelines.md](contributing/guidelines.md)** – How to contribute to the project
- **[DEPLOYMENT.md](DEPLOYMENT.md)** – GitHub Pages deployment guide

## 🚀 Start Here

**If you are new to this project, read [architecture/overview.md](architecture/overview.md) first.**

This will give you a complete understanding of:
- The Clean Architecture pattern used
- Layer responsibilities and boundaries
- Data flow through the application
- Key design patterns

Then proceed to [development/adding-features.md](development/adding-features.md) to learn the development workflow.

## 📚 Documentation Structure

```
docs/
├── getting-started/        # Installation and quick start
├── architecture/           # Architecture and design
├── development/            # Development guides
├── features/               # Feature documentation
├── database/               # Database schema and migrations
├── platforms/              # Platform-specific guides
├── cicd/                   # CI/CD and deployment
├── contributing/           # Contributing guidelines
└── api/                    # API reference
```

## 🔧 Viewing Documentation

### Online (Recommended)

**Live Documentation**: https://satyakommula96.github.io/truecash/

### Locally with MkDocs

```bash
# Install dependencies
pip install -r requirements.txt

# Serve locally
mkdocs serve

# View at http://127.0.0.1:8000/
```

### As Markdown

All documentation is written in Markdown and can be read directly in this folder.

## 🎯 Quick Links by Role

### New Developers
1. [Installation Guide](getting-started/installation.md)
2. [Architecture Overview](architecture/overview.md)
3. [Adding Features Guide](development/adding-features.md)

### Contributors
1. [Contributing Guidelines](contributing/guidelines.md)
2. [Code of Conduct](contributing/code-of-conduct.md)
3. [Testing Guide](development/testing.md)

### Users
1. [Quick Start](getting-started/quick-start.md)
2. [Configuration](getting-started/configuration.md)
3. [Features Overview](features/dashboard.md)

## 📝 Documentation Standards

- All code examples use Dart/Flutter
- Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) style guide
- Use absolute imports: `package:truecash/...`
- Include practical examples for every concept
- Keep pages focused and concise

## 🤝 Contributing to Documentation

Found an error or want to improve the docs?

1. Edit the relevant `.md` file in the `docs/` folder
2. Test locally with `mkdocs serve`
3. Submit a pull request

See [Contributing Guidelines](contributing/guidelines.md) for details.

---

**Need help?** Open an [issue](https://github.com/satyakommula96/truecash/issues) or start a [discussion](https://github.com/satyakommula96/truecash/discussions).

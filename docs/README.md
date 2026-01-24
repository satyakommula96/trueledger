# README

This file provides instructions for setting up and using the MkDocs documentation.

## Setup

### Install MkDocs and Dependencies

You'll need Python 3 and pip installed. Then run:

```bash
pip install mkdocs-material mkdocs-git-revision-date-localized-plugin
```

Or using pip3:

```bash
pip3 install mkdocs-material mkdocs-git-revision-date-localized-plugin
```

### Verify Installation

```bash
mkdocs --version
```

## Local Development

### Serve Documentation Locally

```bash
mkdocs serve
```

This will start a local server at `http://127.0.0.1:8000/` with live reload.

### Build Documentation

```bash
mkdocs build
```

This generates static HTML files in the `site/` directory.

## Documentation Structure

```
docs/
├── index.md                    # Homepage
├── getting-started/
│   ├── installation.md         # Installation guide
│   ├── quick-start.md          # Quick start tutorial
│   └── configuration.md        # Configuration options
├── architecture/
│   ├── overview.md             # Architecture overview
│   ├── clean-architecture.md   # Clean Architecture deep dive
│   ├── project-structure.md    # File organization
│   ├── data-flow.md            # Data flow examples
│   └── state-management.md     # Riverpod patterns
├── development/
│   ├── adding-features.md      # Feature development guide
│   ├── testing.md              # Testing guide
│   ├── design-patterns.md      # Design patterns
│   └── code-style.md           # Code style guide
├── features/
│   ├── dashboard.md            # Dashboard feature
│   ├── transactions.md         # Transactions feature
│   ├── budgets.md              # Budgets feature
│   ├── saving-goals.md         # Saving goals feature
│   ├── ai-insights.md          # AI insights feature
│   └── analytics.md            # Analytics feature
├── database/
│   ├── schema.md               # Database schema
│   ├── migrations.md           # Migration guide
│   └── performance.md          # Performance optimization
├── platforms/
│   ├── android.md              # Android-specific
│   ├── ios.md                  # iOS-specific
│   ├── linux.md                # Linux-specific
│   ├── macos.md                # macOS-specific
│   ├── windows.md              # Windows-specific
│   └── web.md                  # Web-specific
├── cicd/
│   ├── pipeline.md             # CI/CD pipeline
│   ├── testing.md              # Automated testing
│   └── releases.md             # Release process
├── contributing/
│   ├── guidelines.md           # Contributing guidelines
│   └── code-of-conduct.md      # Code of Conduct
└── api/
    └── index.md                # API reference
```

## Writing Documentation

### Markdown Extensions

The documentation supports:

- **Admonitions**: `!!! note`, `!!! warning`, `!!! tip`
- **Code Blocks**: With syntax highlighting
- **Tabs**: For platform-specific content
- **Tables**: Standard markdown tables
- **Diagrams**: ASCII art diagrams

### Example Admonition

```markdown
!!! note "Important"
    This is an important note.

!!! warning "Warning"
    This is a warning.

!!! tip "Tip"
    This is a helpful tip.
```

### Example Tabs

```markdown
=== "Android"
    Android-specific content

=== "iOS"
    iOS-specific content

=== "Linux"
    Linux-specific content
```

### Example Code Block

````markdown
```dart
class MyClass {
  void myMethod() {
    print('Hello, world!');
  }
}
```
````

## Deployment

### GitHub Pages

To deploy to GitHub Pages:

```bash
mkdocs gh-deploy
```

This builds the documentation and pushes it to the `gh-pages` branch.

### Custom Domain

To use a custom domain, create a `docs/CNAME` file with your domain:

```
docs.truecash.app
```

## Configuration

The documentation is configured in `mkdocs.yml`. Key settings:

- **theme**: Material theme with dark/light mode
- **nav**: Navigation structure
- **markdown_extensions**: Enabled markdown features
- **plugins**: Search, git revision dates

## TODO

The following pages still need to be created:

- [ ] `architecture/project-structure.md`
- [ ] `architecture/data-flow.md`
- [ ] `architecture/state-management.md`
- [ ] `development/testing.md`
- [ ] `development/design-patterns.md`
- [ ] `development/code-style.md`
- [ ] `features/*.md` (all feature pages)
- [ ] `database/*.md` (all database pages)
- [ ] `platforms/*.md` (all platform pages)
- [ ] `cicd/*.md` (all CI/CD pages)
- [ ] `api/index.md`

You can extract content from `ARCHITECTURE.md` to populate these pages.

## Resources

- [MkDocs Documentation](https://www.mkdocs.org/)
- [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/)
- [Markdown Guide](https://www.markdownguide.org/)

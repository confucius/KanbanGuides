# 🛠️ Development Guide

This guide provides detailed information for developers working on the Open Guide to Kanban project.

## 🌐 Live Sites for Reference

- **Production**: [kanbanguides.org](https://kanbanguides.org) - **Live production site**
- **Preview**: [red-pond-0d8225910-preview.centralus.2.azurestaticapps.net](https://red-pond-0d8225910-preview.centralus.2.azurestaticapps.net/) - **Test environment with latest changes**

## Development Environment Setup

### Prerequisites

Before starting development, ensure you have:

✅ **Hugo Extended** (v0.146.0+)  
✅ **Git** (latest version)  
✅ **PowerShell 7+** (required for automation scripts)  
✅ **Text Editor/IDE** (VS Code recommended)  
✅ **Node.js** (for advanced tooling, optional)

> **⚠️ Important**: This project uses Hugo's new template system introduced in v0.146.0. Earlier Hugo versions are not compatible.

> **📋 Installation Help**: For detailed PowerShell 7+ installation instructions, see the [Getting Started Guide](./getting-started.md#powershell-automation-scripts).

### Installation Verification

```powershell
# Verify Hugo installation
hugo version

# Verify Git installation
git --version

# Verify you have Hugo Extended
hugo env
```

## Project Setup

### 1. Clone and Setup

```powershell
# Clone the repository
git clone https://github.com/KanbanGuides/KanbanGuides.git
cd KanbanGuides

# Navigate to the Hugo site directory
cd site

# Start development server
hugo server -D --bind 0.0.0.0
```

### 2. Development Server Options

```powershell
# Basic development server
hugo server -D

# With specific port and host binding
hugo server -D --bind 0.0.0.0 --port 1313

# With live reload and draft content
hugo server -D --watch --liveReload

# With specific environment
hugo server -D --environment local

# With verbose logging
hugo server -D --verbose --debug
```

## Code Standards and Guidelines

### File Organization

```text
site/
├── content/              # Content files (.md)
├── layouts/              # Templates (.html) - Updated for Hugo v0.146.0+
│   ├── _partials/       # Reusable template components (renamed from partials/)
│   ├── _shortcodes/     # Custom shortcodes (renamed from shortcodes/)
│   ├── _markup/         # Render hooks for markdown elements
│   ├── baseof.html      # Base template (moved from _default/)
│   ├── single.html      # Single page template (moved from _default/)
│   ├── list.html        # List page template (moved from _default/)
│   ├── home.html        # Homepage template (renamed from index.html)
│   └── [content-type]/  # Content-specific templates
├── static/               # Static assets
├── data/                 # Data files (.yaml/.json)
├── i18n/                 # Translations (.yaml)
└── hugo.yaml            # Configuration
```

### Naming Conventions

- **Files**: Use kebab-case (`my-file.md`)
- **Directories**: Use kebab-case (`my-directory/`)
- **Templates**: Use kebab-case (`my-template.html`)
- **CSS Classes**: Use Bootstrap conventions
- **Variables**: Use camelCase in templates

### Content Guidelines

- Use **front matter** for all content files
- Follow **Markdown** best practices
- Include **meta descriptions** for SEO
- Use **semantic HTML** in templates
- Ensure **accessibility** compliance

## Working with Content

### Content Structure

```yaml
---
title: "Page Title"
description: "Page description for SEO"
date: 2025-06-09
draft: false
weight: 10
language: "en"
---
# Page Content
Your markdown content here...
```

### Creating New Pages

```powershell
# Create a new page
hugo new content/your-page.md

# Create a new guide section
hugo new content/guide/new-section.md

# Create a creator profile
hugo new content/creators/new-creator/index.md
```

### Content Best Practices

1. **Front Matter**

   - Always include `title`, `description`, `date`
   - Use `weight` for ordering
   - Set `draft: false` when ready to publish

2. **Markdown**

   - Use semantic heading hierarchy (H1 → H2 → H3)
   - Include alt text for images
   - Use relative links for internal pages

3. **Images**
   - Place in `/static/images/` directory
   - Use descriptive filenames
   - Optimize for web (WebP preferred)

### Content Attribution Fields

The guide supports three types of attribution through front matter: **creators**, **contributors**, and **translators**. Each serves a specific purpose and has different loading behavior.

#### Loading Behavior

- **Creators & Contributors**: Only loaded from the default language (English) page (`index.md`)
- **Translators**: Only loaded from language-specific pages (`index.es.md`, `index.de.md`, etc.)

This ensures consistent attribution across all languages while allowing language-specific translator recognition.

#### Creators Section

Creators are the original authors and founders of the guide content.

```yaml
creators:
  - name: John Coleman # Required: Full name
    image: https://example.com/photo.jpg # Optional: Direct image URL (highest priority)
    gravatarHash: abc123def456... # Optional: SHA256 hash for Gravatar
    githubUsername: johncoleman # Optional: GitHub username for avatar
    url: https://linkedin.com/in/john # Optional: Profile/website link
```

**Field Priority for Images**:

1. `image` - Direct URL to profile image (highest priority)
2. `gravatarHash` - SHA256 hash for Gravatar service
3. `githubUsername` - GitHub username for GitHub avatar (lowest priority)

#### Contributors Section

Contributors are people who have contributed to the guide content, improvements, or maintenance.

```yaml
contributors:
  - name: Martin Hinshelwood # Required: Full name
    gravatarHash: a9a55b4384e0420e... # Optional: Gravatar hash
    githubUsername: mrhinsh # Optional: GitHub username
    url: https://linkedin.com/in/martin # Optional: Profile link
  - name: Jim Benson # Minimal example with just name and URL
    url: https://linkedin.com/in/jim
  - name: Magdalena Firlit # Minimal example with just name
```

**Same image priority order applies**: `image` > `gravatarHash` > `githubUsername`

#### Translators Section

Translators are recognized on language-specific pages only. This section should **only** appear in translated content files (not in the default English `index.md`).

```yaml
# Example for Spanish translation (index.es.md)
translators:
  - name: María García # Required: Full name
    language: es # Optional: Language code translated
    gravatarHash: def789ghi012... # Optional: Gravatar hash
    url: https://linkedin.com/in/maria # Optional: Profile link
  - name: Carlos Rodriguez
    language: es
    githubUsername: carlosrod
    url: https://github.com/carlosrod
```

#### Complete Front Matter Example

**Default Language File (`index.md`)**:

```yaml
---
title: Open Guide to Kanban
description: Community-driven reference for Kanban in knowledge work
# ... other front matter fields ...

creators:
  - name: John Coleman
    image: https://media.linkedin.com/dms/image/v2/D4E03AQGlxycsyUPltg/profile-displayphoto-shrink_800_800/profile-displayphoto-shrink_800_800/0/1676027893027
    url: https://www.linkedin.com/in/johnanthonycoleman/

contributors:
  - name: Martin Hinshelwood
    gravatarHash: a9a55b4384e0420e376f441384d0c13fdadb9d39e72892ac60c3e89c3079d10d
    githubUsername: mrhinsh
    url: https://www.linkedin.com/in/martinhinshelwood/
  - name: Jim Benson
    url: https://www.linkedin.com/in/jimbenson/
---
```

**Translated File (`index.es.md`)**:

```yaml
---
title: Guía Abierta de Kanban
description: Referencia comunitaria para Kanban en trabajo del conocimiento
# ... other localized front matter fields ...

# Do NOT include creators/contributors here - they're loaded from default language

translators:
  - name: María García
    language: es
    gravatarHash: def789ghi012jkl345mno678pqr901stu234vwx567yz
    url: https://www.linkedin.com/in/mariagarcia/
  - name: Carlos Rodriguez
    language: es
    githubUsername: carlosrod
---
```

#### Implementation Notes

1. **Image Resolution Priority**: The system will attempt to load images in this order:

   - `image` field (direct URL)
   - `gravatarHash` (Gravatar service)
   - `githubUsername` (GitHub avatar API)
   - Fall back to default avatar if none available

2. **Gravatar Hash Generation**: Use SHA256 hash of the lowercase, trimmed email address:

   ```bash
   echo -n "email@example.com" | sha256sum
   ```

3. **GitHub Username**: Should be the exact GitHub username (case-sensitive)

4. **URL Validation**: URLs should be well-formed and preferably HTTPS

5. **Language Consistency**: Ensure translator `language` field matches the file's language code

## Working with Layouts

### Template Development (Hugo v0.146.0+ New Template System)

Hugo's new template system uses a simplified structure with enhanced template lookup. The key changes include:

#### Template Structure Changes

- **No more `_default/` folder**: All default templates are now in the root `layouts/` directory
- **Renamed folders**: `partials/` → `_partials/`, `shortcodes/` → `_shortcodes/`
- **New `_markup/` folder**: For render hooks (links, images, code blocks, etc.)
- **Simplified naming**: `index.html` → `home.html`, page-kind-specific templates

#### Template Development

Hugo uses Go templates with the following structure:

```html
{{ define "main" }}
<main class="container">
  <h1>{{ .Title }}</h1>
  <div class="content">{{ .Content }}</div>
</main>
{{ end }}
```

#### New Template Lookup Order

The new template lookup considers these identifiers in order of importance:

1. **Custom Layout** - Set in front matter (`layout: myCustomLayout`)
2. **Page Kinds** - `home`, `section`, `taxonomy`, `term`, `page`
3. **Standard Layouts** - `list`, `single`
4. **Output Format** - `html`, `rss`, `json`
5. **Language** - `en`, `de`, `es`, etc.
6. **Page Path** - Specific content paths

### Key Template Variables

- `{{ .Title }}` - Page title
- `{{ .Content }}` - Page content
- `{{ .Params }}` - Front matter parameters
- `{{ .Site }}` - Site configuration
- `{{ .Language }}` - Current language

### Partial Templates

Create reusable components in `/layouts/_partials/` (note the underscore prefix):

```html
<!-- layouts/_partials/components/my-component.html -->
<div class="my-component">
  <h2>{{ .title }}</h2>
  <p>{{ .content }}</p>
</div>
```

Use in templates:

```html
{{ partial "components/my-component.html" (dict "title" "My Title" "content" "My content") }}
```

### Content-Specific Templates

With the new template system, you can organize templates by content path:

```text
layouts/
├── baseof.html              # Base template for all pages
├── home.html                # Homepage template
├── single.html              # Default single page template
├── list.html                # Default list page template
├── guide/                   # Guide-specific templates
│   ├── single.html         # Guide single page template
│   └── list.html           # Guide list template
└── _partials/
    ├── components/
    │   ├── navigation.html
    │   └── language-switcher.html
    └── functions/
        └── get-page-param.html
```

## Internationalization (i18n)

### Adding Translations

1. **Create/Update Translation File**

   ```yaml
   # i18n/en.yaml
   - id: "welcome"
     translation: "Welcome"

   # i18n/de.yaml
   - id: "welcome"
     translation: "Willkommen"
   ```

2. **Use in Templates**

   ```html
   <h1>{{ i18n "welcome" }}</h1>
   ```

### Content Translation

- Create language-specific content in subdirectories
- Use the same file structure for each language
- Example: `content/en/guide/index.md` and `content/de/guide/index.md`

## Styling and CSS

### Bootstrap 5 Usage

The project uses Bootstrap 5 as the primary CSS framework:

```html
<!-- Use Bootstrap classes -->
<div class="container">
  <div class="row">
    <div class="col-md-8">
      <p class="lead">Content here</p>
    </div>
  </div>
</div>
```

### Custom CSS

Add custom styles to `/static/css/style.css`:

```css
/* Custom component styles */
.kanban-guide-content {
  font-family: "Inter", sans-serif;
  line-height: 1.6;
}

.creator-profile {
  border-radius: 0.5rem;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}
```

### CSS Best Practices

- Use Bootstrap classes first
- Create component-specific CSS classes
- Follow BEM methodology for custom classes
- Ensure responsive design
- Test across different screen sizes

## Testing and Quality Assurance

### Local Testing

```powershell
# Build the site locally
hugo --environment local

# Check for broken links (if linkchecker is installed)
linkchecker http://localhost:1313

# Validate HTML (if html5validator is installed)
html5validator --root public/
```

### Content Validation

- ✅ All links work correctly
- ✅ Images load and have alt text
- ✅ Meta descriptions are present
- ✅ Front matter is complete
- ✅ Markdown syntax is correct

### Cross-browser Testing

Test the site in:

- ✅ Chrome/Chromium
- ✅ Firefox
- ✅ Safari (if on macOS)
- ✅ Edge
- ✅ Mobile browsers

## Debugging and Troubleshooting

### Common Issues

#### Hugo Server Won't Start

```powershell
# Check Hugo version
hugo version

# Verify you're in the correct directory
cd site

# Check configuration
hugo config
```

#### Content Not Appearing

1. Check front matter has `draft: false`
2. Verify file is in correct location
3. Check template is rendering content
4. Review Hugo's content organization rules

#### Styling Issues

1. Check Bootstrap classes are correct
2. Verify custom CSS is loaded
3. Inspect browser developer tools
4. Clear browser cache

### Debug Mode

```powershell
# Run with debug output
hugo server -D --debug --verbose

# Check configuration
hugo config

# List all content
hugo list all
```

## Performance Optimization

### Build Optimization

```powershell
# Production build with minification
hugo --minify --environment production

# Check build performance
hugo --templateMetrics
```

### Asset Optimization

- **Images**: Use WebP format when possible
- **CSS**: Minimize custom CSS
- **JavaScript**: Only include necessary scripts
- **Fonts**: Use system fonts or optimize web fonts

## Git Workflow

### Branch Strategy

```powershell
# Create feature branch
git checkout -b feature/my-new-feature

# Make changes and commit
git add .
git commit -m "feat: add new feature description"

# Push and create pull request
git push origin feature/my-new-feature
```

### Commit Messages

Follow conventional commit format:

- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `style:` - Code style changes
- `refactor:` - Code refactoring
- `test:` - Test additions/changes

## IDE Setup (VS Code)

### Recommended Extensions

- **Hugo Language and Syntax Support**
- **Markdown All in One**
- **YAML**
- **GitLens**
- **Prettier**
- **Bootstrap 5 Quick Snippets**

### VS Code Settings

```json
{
  "files.associations": {
    "*.html": "html"
  },
  "emmet.includeLanguages": {
    "html": "html"
  }
}
```

## Advanced Development

### Custom Shortcodes

Create reusable content components:

```html
<!-- layouts/shortcodes/alert.html -->
<div class="alert alert-{{ .Get 0 }}" role="alert">{{ .Inner }}</div>
```

Usage in content:

```markdown
{{< alert "info" >}}
This is an info alert.
{{< /alert >}}
```

Access in templates:

```html
{{ range .Site.Data.creators }}
<div class="creator">
  <h3>{{ .name }}</h3>
  <p>{{ .role }}</p>
</div>
{{ end }}
```

## Hugo Template System Migration (v0.146.0+)

This project has been updated to use Hugo's new template system introduced in v0.146.0. Here's what you need to know:

### Key Changes Summary

| **Old System**        | **New System**         | **Action Required**                   |
| --------------------- | ---------------------- | ------------------------------------- |
| `layouts/_default/`   | `layouts/` (root)      | Move all `_default` templates to root |
| `layouts/partials/`   | `layouts/_partials/`   | Rename folder with underscore prefix  |
| `layouts/shortcodes/` | `layouts/_shortcodes/` | Rename folder with underscore prefix  |
| `layouts/index.html`  | `layouts/home.html`    | Rename homepage template              |
| `list-baseof.html`    | `baseof.list.html`     | Move identifier after first dot       |

### Migration Examples

#### Before (Old Template System)

```text
layouts/
├── _default/
│   ├── baseof.html
│   ├── single.html
│   ├── list.html
│   └── index.html
├── partials/
│   └── header.html
└── shortcodes/
    └── button.html
```

#### After (New Template System)

```text
layouts/
├── baseof.html          # Moved from _default/
├── single.html          # Moved from _default/
├── list.html           # Moved from _default/
├── home.html           # Renamed from index.html
├── _partials/          # Renamed from partials/
│   └── header.html
└── _shortcodes/        # Renamed from shortcodes/
    └── button.html
```

### Template Lookup Changes

The new system uses a more intuitive lookup order:

1. **Custom Layout** - Set in front matter (`layout: custom`)
2. **Page Kind** - `home`, `section`, `taxonomy`, `term`, `page`
3. **Standard Layout** - `list`, `single`, `all`
4. **Output Format** - `html`, `rss`, `json`
5. **Language** - `en`, `de`, `es`
6. **Page Path** - Content-specific paths

### Path-Based Templates

You can now organize templates by content structure:

```text
layouts/
├── baseof.html              # Global base template
├── home.html               # Homepage
├── single.html             # Default single page
├── guide/                  # Guide-specific templates
│   ├── single.html        # Override for guide pages
│   └── list.html          # Override for guide lists
└── creators/               # Creator-specific templates
    └── single.html        # Override for creator pages
```

### Internal Template Changes

Replace internal template calls with partials:

```html
<!-- Old Way -->
{{ template "_internal/opengraph.html" . }}

<!-- New Way -->
{{ partial "opengraph.html" . }}
```

### Upgrading Notes

1. **Minimum Version**: Hugo Extended v0.146.0 or higher
2. **Breaking Changes**: Some old template calls may not work
3. **Testing Required**: Verify all templates render correctly
4. **Documentation**: Update any custom documentation

For more details, see the [official Hugo template system overview](https://gohugo.io/templates/new-templatesystem-overview/).

## CI/CD Integration

The project uses GitHub Actions for automated builds and deployments. See deployment configuration in `.github/workflows/`.

### Local Build Testing

Before pushing, test the build locally:

```powershell
# Test production build
hugo --environment production --minify

# Verify output
cd public
ls -la
```

---

🔙 **Back to**: [Documentation Home](./README.md)  
➡️ **Next**: [Deployment Guide](./deployment.md)

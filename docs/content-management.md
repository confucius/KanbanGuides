# 📝 Content Management Guide

This guide covers all aspects of managing content in the Open Guide to Kanban project, including content creation, front matter configuration, attribution, and translation management.

## 🌐 Live Sites

- **Production**: [kanbanguides.org](https://kanbanguides.org) - **Live production site**
- **Preview**: [red-pond-0d8225910-preview.centralus.2.azurestaticapps.net](https://red-pond-0d8225910-preview.centralus.2.azurestaticapps.net/) - **Test your content changes**

## Content Structure Overview

### File Organization

```text
site/content/
├── guide/
│   ├── index.md       # Default language (English) guide content
│   ├── index.es.md    # Spanish translation
│   ├── index.de.md    # German translation
│   └── index.fr.md    # French translation
├── creators/
│   └── index.md       # Creator profiles (English only)
└── download/
    └── index.md       # Download page (multilingual)
```

### Language Handling

- **Default Language**: English (`index.md`)
- **Translations**: Language-specific files (`index.{lang}.md`)
- **Content Loading**: Default language content is used as fallback for missing translations

## Front Matter Configuration

### Core Fields

All content pages should include these basic front matter fields:

```yaml
---
title: "Page Title"
description: "SEO-optimized page description"
keywords:
  - keyword1
  - keyword2
  - keyword3
date: 2025-06-11T09:00:00Z
slug: "page-slug"
type: "page-type"
lang: "en"
weight: 10
draft: false
---
```

### Attribution Fields

The guide supports three types of attribution: **creators**, **contributors**, and **translators**.

#### Loading Behavior

- **Creators & Contributors**: Only loaded from the default language (English) page (`index.md`)
- **Translators**: Only loaded from language-specific translation pages (`index.es.md`, `index.de.md`, etc.)

This ensures consistent attribution across all languages while allowing language-specific translator recognition.

#### Field Schema

All attribution types support the same field structure:

```yaml
# Required field
name: "Full Name"

# Optional image fields (priority order: image > gravatarHash > githubUsername)
image: "https://direct-url-to-image.jpg" # Highest priority
gravatarHash: "sha256-hash-of-lowercase-email" # Medium priority
githubUsername: "github-username" # Lowest priority

# Optional profile link
url: "https://profile-or-website-url.com"

# Translator-specific field
language: "es" # Only used in translators section
```

#### Creators Section

Creators are the original authors and founders of the guide content.

```yaml
creators:
  - name: John Coleman
    image: https://media.linkedin.com/dms/image/v2/D4E03AQGlxycsyUPltg/profile-displayphoto-shrink_800_800/profile-displayphoto-shrink_800_800/0/1676027893027
    url: https://www.linkedin.com/in/johnanthonycoleman/
```

**Rules**:

- Only include in default language (`index.md`)
- Creators are displayed on all language versions
- At least one creator is required

#### Contributors Section

Contributors are people who have made significant contributions to the guide content.

```yaml
contributors:
  - name: Martin Hinshelwood
    gravatarHash: a9a55b4384e0420e376f441384d0c13fdadb9d39e72892ac60c3e89c3079d10d
    githubUsername: mrhinsh
    url: https://www.linkedin.com/in/martinhinshelwood/
  - name: Jim Benson
    url: https://www.linkedin.com/in/jimbenson/
  - name: Magdalena Firlit
```

**Rules**:

- Only include in default language (`index.md`)
- Contributors are displayed on all language versions
- Order represents contribution priority/timing

#### Translators Section

Translators are recognized on language-specific pages only.

```yaml
# Example for Spanish translation (index.es.md)
translators:
  - name: María García
    language: es
    gravatarHash: def789ghi012jkl345mno678pqr901stu234vwx567yz
    url: https://www.linkedin.com/in/mariagarcia/
  - name: Carlos Rodriguez
    language: es
    githubUsername: carlosrod
```

**Rules**:

- Only include in translated pages (`index.{lang}.md`)
- Never include in default language page (`index.md`)
- Language field should match the file's language code

### Image Priority System

The system attempts to load profile images in this priority order:

1. **`image`** - Direct URL to profile image (highest priority)
2. **`gravatarHash`** - SHA256 hash for Gravatar service
3. **`githubUsername`** - GitHub username for GitHub avatar API
4. **Default avatar** - System fallback if none available

#### Generating Gravatar Hash

```bash
# Generate SHA256 hash of lowercase, trimmed email
echo -n "email@example.com" | sha256sum
```

## Content Creation Workflow

### 1. Creating New Content

```bash
# Navigate to content directory
cd site/content/guide

# Create or edit English content
nano index.md

# Create translations
nano index.es.md  # Spanish
nano index.de.md  # German
nano index.fr.md  # French
```

### 2. Front Matter Template

Use this template for new content pages:

```yaml
---
title: "Your Page Title"
description: "SEO-optimized description under 160 characters"
keywords:
  - kanban
  - flow
  - agile
date: 2025-06-11T09:00:00Z
slug: "url-friendly-slug"
type: "guide"
lang: "en"
weight: 10
draft: false

# Only include creators/contributors in DEFAULT language (index.md)
creators:
  - name: Creator Name
    image: https://example.com/image.jpg
    url: https://example.com/profile

contributors:
  - name: Contributor Name
    gravatarHash: sha256-hash-here
    url: https://example.com/profile

# Only include translators in TRANSLATED pages (index.{lang}.md)
# translators:
#   - name: Translator Name
#     language: es
#     githubUsername: username
---
```

### 3. Content Guidelines

#### Writing Style

- **Clear and concise** language appropriate for Kanban practitioners
- **Present tense** for most content
- **Active voice** preferred over passive voice
- **Consistent terminology** throughout the guide

#### Markdown Standards

- Use semantic heading hierarchy (`# H1 → ## H2 → ### H3`)
- Include descriptive alt text for images
- Use relative links for internal references
- Follow proper markdown formatting

#### SEO Optimization

- Unique, descriptive titles under 60 characters
- Meta descriptions under 160 characters
- Relevant keywords without stuffing
- Proper heading structure for content hierarchy

## Translation Management

### Creating Translations

1. **Copy base structure** from English version
2. **Translate all content** including front matter
3. **Add translator attribution** in the `translators` section
4. **Never include** `creators` or `contributors` in translated versions

### Translation Example

**English (`index.md`)**:

```yaml
---
title: Open Guide to Kanban
description: Community-driven reference for Kanban in knowledge work
lang: en

creators:
  - name: John Coleman
    url: https://example.com

contributors:
  - name: Martin Hinshelwood
    url: https://example.com
---
```

**Spanish (`index.es.md`)**:

```yaml
---
title: Guía Abierta de Kanban
description: Referencia comunitaria para Kanban en trabajo del conocimiento
lang: es

# Do NOT include creators/contributors here

translators:
  - name: María García
    language: es
    url: https://example.com
---
```

### Translation Quality Standards

- **Accuracy**: Maintain meaning and intent of original content
- **Consistency**: Use consistent terminology across all translated content
- **Cultural Adaptation**: Adapt examples and references for target culture
- **Technical Precision**: Preserve technical Kanban terminology
- **Formatting**: Maintain markdown structure and formatting

## Content Validation

### Pre-Publication Checklist

#### Front Matter Validation

- [ ] All required fields present (`title`, `description`, `date`, `lang`)
- [ ] Creators/contributors only in default language (`index.md`)
- [ ] Translators only in translated pages (`index.{lang}.md`)
- [ ] Valid image URLs or proper hash values
- [ ] Consistent language codes

#### Content Quality

- [ ] Proper markdown formatting
- [ ] Working internal and external links
- [ ] Descriptive alt text for images
- [ ] Consistent heading hierarchy
- [ ] Spelling and grammar check

#### Content SEO

- [ ] Title under 60 characters
- [ ] Description under 160 characters
- [ ] Relevant keywords included
- [ ] Proper slug format

### Testing Content

1. **Local Testing**:

   ```bash
   hugo serve -D --bind 0.0.0.0
   ```

2. **Preview Environment**: Test on [preview site](https://red-pond-0d8225910-preview.centralus.2.azurestaticapps.net/)

3. **Multi-language Testing**: Verify content displays correctly in all supported languages

## Troubleshooting

### Common Issues

#### Attribution Not Displaying

- **Problem**: Creators/contributors not showing on translated pages
- **Solution**: Ensure they're only defined in `index.md` (default language)

#### Image Not Loading

- **Problem**: Profile image not displaying
- **Solution**: Check image priority order and validate URLs/hashes

#### Translation Missing

- **Problem**: Content falling back to English
- **Solution**: Verify language-specific file exists and front matter is correct

### Debug Commands

```bash
# Check Hugo configuration
hugo config

# Validate content with drafts
hugo serve -D --verbose

# Build and check for errors
hugo --verbose
```

## Best Practices

### Content Organization

1. **Consistent Structure**: Maintain same organization across all languages
2. **Regular Updates**: Keep all language versions synchronized
3. **Version Control**: Use descriptive commit messages for content changes
4. **Collaborative Review**: Have content reviewed by subject matter experts

### Attribution Management

1. **Accurate Information**: Verify all profile links and contact information
2. **Permission**: Ensure consent before adding someone's attribution
3. **Regular Updates**: Keep profile information current
4. **Consistent Formatting**: Follow established patterns for all attributions

### Performance Optimization

1. **Image Optimization**: Use appropriate image sizes and formats
2. **Content Length**: Balance comprehensive coverage with page load performance
3. **Link Validation**: Regularly check for broken internal and external links
4. **SEO Maintenance**: Monitor and update meta information as needed

---

🔙 **Back to**: [Documentation Home](./README.md)  
➡️ **Next**: [Development Guide](./development.md) | [Configuration Reference](./configuration.md)

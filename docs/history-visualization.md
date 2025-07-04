# History Visualization System

This document explains how the history visualization system works for the Open Guide to Kanban project.

## Overview

The history system provides a visual timeline that shows:

- **Fork relationships** between guides (e.g., Open Guide forked from Kanban Guide)
- **Chronological evolution** of each guide
- **Clear visual indicators** for current vs. historical versions
- **Interactive elements** to navigate between versions

## Architecture

### Front Matter Parameters

Each guide's `latest/index.md` can include:

```yaml
forked_from: kanban-guide/latest # Indicates this guide is forked from another
version: 2025.7 # Version identifier
date: 2025-07-02T09:00:00Z # Date of this version
```

### Directory Structure

```text
site/content/
├── kanban-guide/
│   ├── latest/index.md           # Current Kanban Guide
│   └── history/
│       ├── 2020-07/index.md     # Historical versions
│       ├── 2020-12/index.md
│       └── _index.md             # History page
└── open-guide-for-kanban/
    ├── latest/index.md           # Current Open Guide (forked_from: kanban-guide/latest)
    └── history/
        └── _index.md             # History page
```

## Visual Timeline

The history page displays a vertical timeline showing:

1. **Fork Source History** (if applicable) - Historical versions of the source guide
2. **Fork Point** - The version that was forked, with visual branching indicator
3. **Current Version** - The active version with primary styling
4. **Historical Versions** - Previous versions in reverse chronological order

### Timeline Elements

- **Icons**: Different icons for current (★), historical (🗂️), and fork (⚡) versions
- **Color Coding**:
  - Primary blue for current versions
  - Secondary gray for historical versions
  - Warning yellow for fork points
- **Action Buttons**: Links to read current guide or view archived versions

## Helper Functions

### `get-history-chain.html`

Located at `site/layouts/_partials/functions/get-history-chain.html`, this function:

- Analyzes the current page to determine its guide type
- Retrieves the complete history chain including fork relationships
- Returns a structured object with current, history, forkSource, and forkHistory data

### Usage Example

```html
{{- $historyChain := partial "functions/get-history-chain.html" . }} {{- if $historyChain.forkSource }}
<!-- Display fork relationship -->
{{- end }}
```

## Creating Historical Versions

Use the PowerShell script to create historical versions:

```powershell
# Create a new historical version
.\scripts\Create-HistoricalVersion.ps1 -Guide "open-guide-for-kanban" -Version "2025-07"

# With specific date
.\scripts\Create-HistoricalVersion.ps1 -Guide "kanban-guide" -Version "2025.5.1" -Date "2025-05-15"

# Force overwrite existing
.\scripts\Create-HistoricalVersion.ps1 -Guide "open-guide-for-kanban" -Version "2025-07" -Force
```

### What the Script Does

1. **Copies** current `latest/` content to `history/{version}/`
2. **Updates metadata** including title with version date, version number
3. **Handles translations** automatically
4. **Preserves** all content and assets
5. **Validates** the structure

## Styling

### CSS Classes

The timeline uses these key CSS classes:

- `.timeline-container` - Main timeline wrapper
- `.timeline-item` - Individual timeline entries
- `.timeline-icon` - Circular icons for each entry
- `.timeline-connector` - Lines and arrows between entries

### Responsive Design

The timeline automatically adapts for mobile devices:

- Stacks vertically on small screens
- Adjusts icon positioning
- Maintains readability

## Version Card Integration

Each version displays:

- **Fork information** - Shows if the guide was forked from another
- **Action buttons** - Read current guide or view archived versions
- **Metadata** - Date, version, and description
- **Contributors** - Author and contributor information

## Future Enhancements

Potential improvements for the history system:

1. **Diff Visualization** - Show changes between versions
2. **Search & Filter** - Find specific versions or content
3. **Export Options** - Generate historical reports
4. **Analytics** - Track version usage and popularity
5. **Automation** - Automatic historical version creation on releases

## Troubleshooting

### Timeline Not Showing Fork Relationship

Check:

1. `forked_from` parameter is correctly set in the latest version's front matter
2. The referenced source guide exists and is accessible
3. Hugo site build is complete and cache is cleared

### Historical Versions Not Appearing

Verify:

1. Historical versions exist in the `history/` directory
2. Each historical version has proper front matter
3. Date formats are consistent (ISO 8601 recommended)

### Styling Issues

Ensure:

1. CSS file includes timeline styles
2. Bootstrap 5 classes are available
3. Font Awesome icons are loaded

## Technical Notes

- The system uses Hugo's page collections and site functions
- Timeline ordering is based on the `date` parameter in front matter
- Fork relationships are resolved at build time
- All visualizations are responsive and accessible

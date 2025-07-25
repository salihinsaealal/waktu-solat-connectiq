# 🕌 Waktu Solat ConnectIQ App - Customization Guide

> **Complete customization reference for fonts, positions, colors, and layout**

This guide shows you exactly where to modify the code to customize your Waktu Solat app. All line numbers are approximate and may shift as you make changes.

---

## 📱 Main View Customization
**File**: `/source/waktuSolatHomeAssistantView.mc`

### 🖼️ Logo Section (Lines 53-58)

```monkey-c
// Logo above title
var logo = WatchUi.loadResource(Rez.Drawables.AppLogo) as WatchUi.BitmapResource;
if (logo != null) {
    var logoWidth = logo.getWidth();
    dc.drawBitmap((width - logoWidth) / 2, 15 - _scrollOffset, logo);
}
```

**What you can change:**
- `15` = Logo Y position (higher number = lower on screen)
- `(width - logoWidth) / 2` = Horizontal centering formula
- Replace `Rez.Drawables.AppLogo` with different drawable resource

### 🎯 Header Section (Lines 60-70)

```monkey-c
// Title
dc.drawText(width/2, 50 - _scrollOffset, Graphics.FONT_TINY, "Waktu Solat", Graphics.TEXT_JUSTIFY_CENTER);

// Remaining time display
var nextPrayerTime = getRemainingTimeToNextPrayer();
dc.drawText(width / 2, 80, Graphics.FONT_TINY, "Next: " + nextPrayerTime, Graphics.TEXT_JUSTIFY_CENTER);

// Location display
dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
dc.drawText(width / 2, 120, Graphics.FONT_XTINY, _location, Graphics.TEXT_JUSTIFY_CENTER);
```

**What you can change:**
- `50` = Title Y position
- `80` = Remaining time Y position 
- `120` = Location Y position
- `Graphics.FONT_TINY` / `Graphics.FONT_XTINY` = Font sizes
- `"Next: "` = Text prefix for remaining time
- `Graphics.COLOR_GREEN` = Location text color

### 🎯 Prayer List Layout (Lines 72-78)

```monkey-c
// Calculate centered content area with wider margins
var contentWidth = width - 80; // Leave 40px margin on each side
var contentStartX = 40; // Start 40px from left edge

// Prayer times list - centered overall layout with left-aligned text
var startY = 140; // Starting position for prayer list
var lineHeight = 30; // Space between each prayer line
```

**What you can change:**
- `80` = Total horizontal margin (smaller number = wider content)
- `40` = Left margin (adjust left/right position of content)
- `140` = Starting Y position for prayer list (higher = lower on screen)
- `30` = Space between each prayer line (bigger = more spacing)

### 🎯 Prayer Text Positioning (Lines 95-100)

```monkey-c
// Prayer name - left aligned within centered content area
dc.drawText(contentStartX + 5, currentY + 5, Graphics.FONT_XTINY, prayer, Graphics.TEXT_JUSTIFY_LEFT);

// Prayer time - right aligned within centered content area  
dc.drawText(contentStartX + contentWidth - 5, currentY + 5, Graphics.FONT_XTINY, time, Graphics.TEXT_JUSTIFY_RIGHT);
```

**What you can change:**
- `+ 5` = Left padding for prayer names
- `- 5` = Right padding for prayer times
- `+ 5` = Vertical text position within each line
- `Graphics.FONT_XTINY` = Font size for prayers

### 🎯 Color Settings (Lines 77-92)

```monkey-c
// Determine prayer colors: Green for current period, Yellow for next prayer
var prayerColor = Graphics.COLOR_LT_GRAY; // Default color
var timeColor = Graphics.COLOR_WHITE; // Default time color

if (prayer.equals(_nextPrayer)) {
    prayerColor = Graphics.COLOR_YELLOW; // Next prayer in yellow
    timeColor = Graphics.COLOR_YELLOW;
}

// Check if this is the current prayer period (previous prayer to next)
for (var j = 0; j < prayers.size(); j++) {
    if (prayers[j].equals(_nextPrayer) && j > 0 && prayers[j-1].equals(prayer)) {
        prayerColor = Graphics.COLOR_GREEN; // Current period in green
        timeColor = Graphics.COLOR_GREEN;
        break;
    }
}
```

**Color Logic:**
- **Green** = Current prayer period (the prayer time we're currently in)
- **Yellow** = Next upcoming prayer
- **Light Gray** = Other prayers

## 📱 Glance View Customization
**File**: `/source/waktuSolatGlanceView.mc`

### 🎯 Glance Text Positioning (Lines 29, 48)

```monkey-c
// First row: Current Prayer - left aligned
dc.drawText(10, startY, Graphics.FONT_XTINY, "Current Prayer - " + _currentPrayer, Graphics.TEXT_JUSTIFY_LEFT);

// Second row: Next Prayer info - left aligned with formatted time
dc.drawText(10, barY + 10, Graphics.FONT_XTINY, "Next Prayer in " + formattedTime, Graphics.TEXT_JUSTIFY_LEFT);
```

**What you can change:**
- `10` = Left margin for text
- `startY` and `barY + 10` = Vertical positions
- `Graphics.FONT_XTINY` = Font size

### 🎯 Progress Bar (Lines 32-43)

```monkey-c
// Progress bar between rows - with proper spacing
var barY = startY + 40; // Give more space after first row
var barWidth = width - 20;
var barHeight = 5;
var barX = 10;
```

**What you can change:**
- `40` = Space between first row and progress bar
- `20` = Progress bar margin (smaller = wider bar)
- `5` = Progress bar thickness
- `10` = Progress bar left position

## 🎨 Available Font Sizes

```monkey-c
Graphics.FONT_XTINY    // Smallest - current prayer list size
Graphics.FONT_TINY     // Slightly bigger
Graphics.FONT_SMALL    // Medium size - current top section size
Graphics.FONT_MEDIUM   // Larger
Graphics.FONT_LARGE    // Largest
```

## 🎨 Available Colors

```monkey-c
Graphics.COLOR_WHITE      // White
Graphics.COLOR_LT_GRAY    // Light Gray - default prayer text
Graphics.COLOR_DK_GRAY    // Dark Gray
Graphics.COLOR_GREEN      // Green - current prayer period
Graphics.COLOR_YELLOW     // Yellow - next prayer
Graphics.COLOR_RED        // Red
Graphics.COLOR_BLUE       // Blue
Graphics.COLOR_BLACK      // Black
Graphics.COLOR_TRANSPARENT // Transparent background
```

## 📐 Quick Layout Adjustments

### Make Content Wider
```monkey-c
var contentWidth = width - 10; // Change from 20 to 10
var contentStartX = 5;         // Change from 10 to 5
```

### Increase Prayer List Spacing
```monkey-c
var lineHeight = 35;           // Change from 30 to 35
```

### Move Prayer List Higher
```monkey-c
var startY = 45;              // Change from 55 to 45
```

### Make Prayer Text Bigger
```monkey-c
dc.drawText(..., Graphics.FONT_TINY, ...); // Change from FONT_XTINY to FONT_TINY
```

### Adjust Text Padding
```monkey-c
dc.drawText(contentStartX + 8, currentY + 8, ...); // Change from +5 to +8
```

## 🔧 Common Customizations

### Scenario 1: "Text is too small"
- Change `Graphics.FONT_XTINY` to `Graphics.FONT_TINY` or `Graphics.FONT_SMALL` on lines 95-100

### Scenario 2: "Need more space between prayers"
- Increase `lineHeight` from `30` to `35` or `40` on line 64

### Scenario 3: "Content too narrow"
- Decrease `contentWidth = width - 20` to `width - 10` on line 59
- Decrease `contentStartX = 10` to `5` on line 60

### Scenario 4: "Prayer list too low"
- Decrease `startY = 55` to `45` or `50` on line 63

### Scenario 5: "Want different colors"
- Change color values in lines 77-92 using available colors above

## 💡 Tips

1. **Test incrementally**: Make one change at a time and test
2. **Build after changes**: Run `monkeyc -f monkey.jungle -d epix2 -o bin/test_epix2_waktuSolatHomeAssistant.prg -y developer_key`
3. **Backup first**: Keep a copy of working code before major changes
4. **Font hierarchy**: XTINY < TINY < SMALL < MEDIUM < LARGE
5. **Positioning**: Higher Y values = lower on screen, Higher X values = more to the right

## 📱 Device Considerations

- **epix2 screen**: 454x454 pixels
- **Safe margins**: Keep content at least 10px from edges
- **Readability**: FONT_XTINY is very small, consider FONT_TINY for better readability
- **Color contrast**: Ensure good contrast between text and background colors

---

*This guide covers the main customization points. For advanced modifications, refer to the Garmin ConnectIQ documentation.*

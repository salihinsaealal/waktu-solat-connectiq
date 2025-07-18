import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.System;
import Toybox.Lang;
import Toybox.Math;

class waktuSolatHomeAssistantView extends WatchUi.View {
    private var _prayerTimes as Dictionary<String, String>;
    private var _currentTime as String = "";
    private var _nextPrayer as String = "";
    private var _location as String = "";
    private var _scrollOffset as Number;
    private var _maxScroll as Number;

    function initialize() {
        View.initialize();
        _scrollOffset = 0;
        _maxScroll = 0;
        
        // Mock prayer times data
        _prayerTimes = {
            "Subuh" => "05:58",
            "Isyraq" => "07:23",
            "Dhuha" => "07:26", 
            "Zohor" => "13:20",
            "Asar" => "16:44",
            "Maghrib" => "19:26",
            "Isyak" => "20:40"
        };
        
        // Mock location data
        _location = "Jasin";
        
        updateCurrentTimeAndNext();
    }

    function onLayout(dc as Dc) as Void {
        // Don't use XML layout, we'll draw everything custom
    }

    function onShow() as Void {
        updateCurrentTimeAndNext();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        // Logo above title
        var logo = WatchUi.loadResource(Rez.Drawables.AppLogo) as WatchUi.BitmapResource;
        if (logo != null) {
            var logoWidth = logo.getWidth();
            dc.drawBitmap((width - logoWidth) / 2, 20 - _scrollOffset, logo);
        }
        
        // Title - more compact
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width/2, 80 - _scrollOffset, Graphics.FONT_TINY, "Waktu Solat", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Next prayer time display in 12-hour format - centered
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var nextPrayerTime = getRemainingTimeToNextPrayer();
        dc.drawText(width / 2, 110, Graphics.FONT_XTINY, "Next in " + nextPrayerTime, Graphics.TEXT_JUSTIFY_CENTER);
        
        // Location display below next prayer time - in green color
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, 340, Graphics.FONT_XTINY, _location, Graphics.TEXT_JUSTIFY_CENTER);
        
        // Calculate centered content area with wider margins
        var contentWidth = width - 75; // Leave 10px margin on each side (wider content)
        var contentStartX = 45; // Start 10px from left edge
        
        // Prayer times list - centered overall layout with left-aligned text
        var startY = 120; // More top margin
        var lineHeight = 27; // Slightly larger line height for better spacing
        var prayers = ["Subuh", "Isyraq", "Dhuha", "Zohor", "Asar", "Maghrib", "Isyak"];
        
        for (var i = 0; i < prayers.size(); i++) {
            var prayer = prayers[i];
            var time = _prayerTimes[prayer];
            var currentY = startY + (i * lineHeight) - _scrollOffset;
            
            // Skip if not visible
            if (currentY < -lineHeight || currentY > height + lineHeight) {
                continue;
            }
            
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
            
            // Prayer name - left aligned within centered content area
            dc.setColor(prayerColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(contentStartX + 5, currentY + 5, Graphics.FONT_XTINY, prayer, Graphics.TEXT_JUSTIFY_LEFT);
            
            // Prayer time - right aligned within centered content area (12-hour format)
            dc.setColor(timeColor, Graphics.COLOR_TRANSPARENT);
            var time12Hour = convertTo12HourFormat(time);
            dc.drawText(contentStartX + contentWidth - 5, currentY + 5, Graphics.FONT_XTINY, time12Hour, Graphics.TEXT_JUSTIFY_RIGHT);
        }
        
        // Calculate max scroll
        _maxScroll = (prayers.size() * lineHeight + 60) - height;
        if (_maxScroll < 0) {
            _maxScroll = 0;
        }
    }

    function onHide() as Void {
    }
    
    private function updateCurrentTimeAndNext() as Void {
        var now = Time.now();
        var info = Time.Gregorian.info(now, Time.FORMAT_SHORT);
        _currentTime = Lang.format("$1$:$2$", [info.hour.format("%02d"), info.min.format("%02d")]);
        
        var currentHour = info.hour;
        var currentMin = info.min;
        var currentTimeInMin = currentHour * 60 + currentMin;
        
        // Get prayer names in order
        var prayers = ["Subuh", "Isyraq", "Dhuha", "Zohor", "Asar", "Maghrib", "Isyak"];
        
        // Convert prayer time strings to minutes dynamically
        var prayerTimesInMin = new [prayers.size()];
        for (var i = 0; i < prayers.size(); i++) {
            prayerTimesInMin[i] = convertTimeStringToMinutes(_prayerTimes[prayers[i]]);
        }
        
        // Find next prayer dynamically
        _nextPrayer = "Subuh"; // Default to next day Subuh
        
        for (var i = 0; i < prayerTimesInMin.size(); i++) {
            if (currentTimeInMin < prayerTimesInMin[i]) {
                _nextPrayer = prayers[i];
                break;
            }
        }
    }
    
    // Generic function to convert time string (HH:MM) to minutes from midnight
    private function convertTimeStringToMinutes(timeString as String) as Number {
        var colonIndex = timeString.find(":");
        if (colonIndex == null) {
            return 0; // Invalid format, return 0
        }
        
        var hourStr = timeString.substring(0, colonIndex);
        var minStr = timeString.substring(colonIndex + 1, timeString.length());
        
        var hour = hourStr.toNumber();
        var min = minStr.toNumber();
        
        return hour * 60 + min;
    }
    
    // Convert 24-hour time string to 12-hour format
    private function convertTo12HourFormat(timeString as String) as String {
        var colonIndex = timeString.find(":");
        if (colonIndex == null) {
            return timeString; // Invalid format, return as-is
        }
        
        var hourStr = timeString.substring(0, colonIndex);
        var minStr = timeString.substring(colonIndex + 1, timeString.length());
        
        var hour = hourStr.toNumber();
        var min = minStr.toNumber();
        
        var period = "AM";
        var displayHour = hour;
        
        if (hour == 0) {
            displayHour = 12;
        } else if (hour > 12) {
            displayHour = hour - 12;
            period = "PM";
        } else if (hour == 12) {
            period = "PM";
        }
        
        return Lang.format("$1$:$2$ $3$", [displayHour.format("%d"), min.format("%02d"), period]);
    }
    
    // Format minutes into readable time duration with proper pluralization
    private function formatTimeDuration(totalMinutes as Number) as String {
        if (totalMinutes < 60) {
            // Less than 1 hour - show only minutes
            if (totalMinutes == 1) {
                return "1 minute";
            } else {
                return totalMinutes.toString() + " minutes";
            }
        } else {
            // 1 hour or more - show hours and minutes
            var hours = totalMinutes / 60;
            var minutes = totalMinutes % 60;
            
            var result = "";
            
            // Add hours part
            if (hours == 1) {
                result = "1 hour";
            } else {
                result = hours.toString() + " hours";
            }
            
            // Add minutes part if there are any
            if (minutes > 0) {
                if (minutes == 1) {
                    result = result + " 1 minute";
                } else {
                    result = result + " " + minutes.toString() + " minutes";
                }
            }
            
            return result;
        }
    }
    
    // Calculate remaining time until next prayer in HH:MM format
    private function getRemainingTimeToNextPrayer() as String {
        var now = Time.now();
        var info = Time.Gregorian.info(now, Time.FORMAT_SHORT);
        var currentTimeInMin = info.hour * 60 + info.min;
        
        // Get prayer names in order
        var prayers = ["Subuh", "Isyraq", "Dhuha", "Zohor", "Asar", "Maghrib", "Isyak"];
        
        // Convert prayer time strings to minutes dynamically
        var prayerTimesInMin = new [prayers.size()];
        for (var i = 0; i < prayers.size(); i++) {
            prayerTimesInMin[i] = convertTimeStringToMinutes(_prayerTimes[prayers[i]]);
        }
        
        // Find next prayer time
        var nextTimeInMin = prayerTimesInMin[0] + 1440; // Default to next day Subuh
        
        for (var i = 0; i < prayerTimesInMin.size(); i++) {
            if (currentTimeInMin < prayerTimesInMin[i]) {
                nextTimeInMin = prayerTimesInMin[i];
                break;
            }
        }
        
        // Calculate remaining minutes
        var remainingMin = nextTimeInMin - currentTimeInMin;
        if (remainingMin < 0) {
            remainingMin = remainingMin + 1440; // Add 24 hours
        }
        
        // Convert remaining time to HH:MM format (24-hour duration)
        var hours = remainingMin / 60;
        var minutes = remainingMin % 60;
        
        return Lang.format("$1$:$2$", [hours.format("%02d"), minutes.format("%02d")]);
    }
    
    // Handle scrolling
    function onKeyPressed(keyEvent as WatchUi.KeyEvent) as Boolean {
        var key = keyEvent.getKey();
        
        if (key == WatchUi.KEY_UP) {
            return scrollUp();
        } else if (key == WatchUi.KEY_DOWN) {
            return scrollDown();
        }
        
        return false;
    }
    
    function scrollUp() as Boolean {
        _scrollOffset = _scrollOffset - 20;
        if (_scrollOffset < 0) {
            _scrollOffset = 0;
        }
        WatchUi.requestUpdate();
        return true;
    }
    
    function scrollDown() as Boolean {
        _scrollOffset = _scrollOffset + 20;
        if (_scrollOffset > _maxScroll) {
            _scrollOffset = _maxScroll;
        }
        WatchUi.requestUpdate();
        return true;
    }
    
    // Get data for glance view
    function getGlanceData() as Dictionary {
        updateCurrentTimeAndNext();
        var nextTime = _prayerTimes[_nextPrayer];
        
        return {
            "current" => _currentTime,
            "next" => _nextPrayer,
            "nextTime" => nextTime,
            "reminder" => "15 min"
        };
    }
}

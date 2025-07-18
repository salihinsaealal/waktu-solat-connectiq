import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Lang;

(:glance)
class waktuSolatGlanceView extends WatchUi.GlanceView {
    private var _currentPrayer as String = "";
    private var _minutesUntilNext as Number = 0;
    private var _progressPercent as Float = 0.0;

    function initialize() {
        GlanceView.initialize();
        updateGlanceData();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        // Center the content vertically
        var startY = (height - 80) / 2; // Total content height is about 50px
        
        // First row: Current Prayer - left aligned
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(10, startY, Graphics.FONT_XTINY, "Current Prayer - " + _currentPrayer, Graphics.TEXT_JUSTIFY_LEFT);
        
        // Progress bar between rows - with proper spacing
        var barY = startY + 40; // Give more space after first row
        var barWidth = width - 20;
        var barHeight = 5;
        var barX = 10;
        
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(barX, barY, barWidth, barHeight);
        
        // Progress bar fill
        var fillWidth = (barWidth * _progressPercent).toNumber();
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(barX, barY, fillWidth, barHeight);
        
        // Second row: Next Prayer info - left aligned with formatted time
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var formattedTime = formatTimeDuration(_minutesUntilNext);
        dc.drawText(10, barY + 10, Graphics.FONT_XTINY, "Next Prayer in " + formattedTime, Graphics.TEXT_JUSTIFY_LEFT);
    }
    
    private function updateGlanceData() as Void {
        var now = Time.now();
        var info = Time.Gregorian.info(now, Time.FORMAT_SHORT);
        
        var currentHour = info.hour;
        var currentMin = info.min;
        var currentTimeInMin = currentHour * 60 + currentMin;
        
        // Get prayer names in order
        var prayers = ["Subuh", "Isyraq", "Dhuha", "Zohor", "Asar", "Maghrib", "Isyak"];
        
        // Prayer times data (same as main view)
        var prayerTimes = {
            "Subuh" => "05:58",
            "Isyraq" => "07:23",
            "Dhuha" => "07:26", 
            "Zohor" => "13:20",
            "Asar" => "16:44",
            "Maghrib" => "19:26",
            "Isyak" => "20:40"
        };
        
        // Convert prayer time strings to minutes dynamically
        var prayerTimesInMin = new [prayers.size()];
        for (var i = 0; i < prayers.size(); i++) {
            prayerTimesInMin[i] = convertTimeStringToMinutes(prayerTimes[prayers[i]]);
        }
        
        // Find current prayer period and next prayer
        _currentPrayer = "After Isyak";
        var nextTimeInMin = prayerTimesInMin[0] + 1440; // Next day Subuh
        var currentPeriodStart = prayerTimesInMin[prayerTimesInMin.size()-1]; // After Isyak
        
        for (var i = 0; i < prayerTimesInMin.size(); i++) {
            if (currentTimeInMin < prayerTimesInMin[i]) {
                nextTimeInMin = prayerTimesInMin[i];
                
                // Determine current prayer period
                if (i == 0) {
                    _currentPrayer = "Before Subuh";
                    currentPeriodStart = 0;
                } else {
                    _currentPrayer = prayers[i-1];
                    currentPeriodStart = prayerTimesInMin[i-1];
                }
                break;
            }
        }
        
        // Calculate minutes until next prayer
        _minutesUntilNext = nextTimeInMin - currentTimeInMin;
        if (_minutesUntilNext < 0) {
            _minutesUntilNext = _minutesUntilNext + 1440; // Add 24 hours
        }
        
        // Calculate progress percentage
        var periodDuration = nextTimeInMin - currentPeriodStart;
        if (periodDuration <= 0) {
            periodDuration = 1440 - currentPeriodStart + nextTimeInMin; // Handle overnight period
        }
        var timeElapsed = currentTimeInMin - currentPeriodStart;
        if (timeElapsed < 0) {
            timeElapsed = timeElapsed + 1440; // Handle overnight
        }
        
        _progressPercent = timeElapsed.toFloat() / periodDuration.toFloat();
        if (_progressPercent > 1.0) {
            _progressPercent = 1.0;
        } else if (_progressPercent < 0.0) {
            _progressPercent = 0.0;
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
                result = "1 hr";
            } else {
                result = hours.toString() + " hrs";
            }
            
            // Add minutes part if there are any
            if (minutes > 0) {
                if (minutes == 1) {
                    result = result + " 1 min";
                } else {
                    result = result + " " + minutes.toString() + " mins";
                }
            }
            
            return result;
        }
    }
}

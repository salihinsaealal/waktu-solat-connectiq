import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class waktuSolatHomeAssistantApp extends Application.AppBase {
    private var _view as waktuSolatHomeAssistantView or Null;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        _view = new waktuSolatHomeAssistantView();
        return [ _view, new waktuSolatHomeAssistantDelegate(_view) ];
    }
    
    // Return the glance view
    function getGlanceView() as [GlanceView] or [GlanceView, GlanceViewDelegate] or Null {
        return [ new waktuSolatGlanceView() ];
    }

}

function getApp() as waktuSolatHomeAssistantApp {
    return Application.getApp() as waktuSolatHomeAssistantApp;
}
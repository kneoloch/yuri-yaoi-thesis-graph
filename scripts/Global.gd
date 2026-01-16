extends Node

@warning_ignore("unused_signal")
signal selectObject(target: MediaEntry) # from camera
@warning_ignore("unused_signal")
signal themeColor(theme: ThemeColor) # from world
@warning_ignore("unused_signal")
signal scaleAxis(multiplier: float) # emit to: media_entry
@warning_ignore("unused_signal")
signal flipSprite(dir: String)

enum ThemeColor {LIGHT, DARK, CUSTOM}
var curr_theme: ThemeColor = 0 as ThemeColor
var highlight_color: Color = Color.CYAN

extends Node

@warning_ignore("unused_signal")
signal selectObject(target: Node) # from camera
@warning_ignore("unused_signal")
signal themeColor(theme: ThemeColor) # from world
@warning_ignore("unused_signal")
signal scaleAxis(multiplier: float) # emit to: media_entry
@warning_ignore("unused_signal")
signal flipSprite(dir: String)
@warning_ignore("unused_signal")
signal filterHide(matches: Array[Node])
@warning_ignore("unused_signal")
signal initialize
@warning_ignore("unused_signal")
signal snapCameraPos(orthogonal: String)

enum ThemeColor {LIGHT, DARK, NINE_ELEVEN, CUSTOM}

var curr_theme: ThemeColor = 0 as ThemeColor
var highlight_color: Color = Color.CYAN
var init: bool = false
var animated_bg_visible: bool = false

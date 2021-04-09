module ui

import time
import sokol.sapp

//** move mode ***

enum CoordinateMode {
	relative
	drag // offset
}

fn offset_start(mut w Widget) {
	w.x += w.offset_x
	w.y += w.offset_y
}

fn offset_end(mut w Widget) {
	w.x -= w.offset_x
	w.y -= w.offset_y
}

//** Drag stuff ***//

/*
NB: would like external mechanism only depending on point_inside methods of Widgets
shift key (or other) to activate possible dragging
*/

fn drag_register(w Widget, ui &UI, e &MouseEvent) {
	if shift_key(e.mods) {
		$if drag ? {
			println('drag ${typeof(w).name}')
		}
		mut window := ui.window
		if window.drag_activated {
			if w.z_index > window.drag_widget.z_index {
				window.drag_widget = w
				window.drag_start_x = e.x - w.offset_x
				window.drag_start_y = e.y - w.offset_y
				// println('drag: ($e.x, $e.y, ${window.drag_start_x},${window.drag_start_y})')
				window.drag_pos_x = e.x
				window.drag_pos_y = e.y
				window.drag_time = time.now()
			}
		} else {
			window.drag_activated = true
			window.drag_widget = w
			window.drag_start_x = e.x - w.offset_x
			window.drag_start_y = e.y - w.offset_y
			// println('drag: ($e.x, $e.y, ${window.drag_start_x},${window.drag_start_y})')
			window.drag_pos_x = e.x
			window.drag_pos_y = e.y
			window.drag_time = time.now()
		}
	}
}

fn drag_child(mut window Window, x f64, y f64) {
	mut w := window.drag_widget
	sapp.show_mouse(false)
	$if speed ? {
		t := time.now()
		speed := 0.1
		dt := (t - window.drag_time).milliseconds() * speed
		window.drag_time = t

		dx := (x - window.drag_pos_x) / dt
		dy := (y - window.drag_pos_y) / dt
		// println("dt=$dt dx=$dx dy=$dy")

		w.offset_x = int(x + dx - window.drag_start_x)
		w.offset_y = int(y + dy - window.drag_start_y)

		window.drag_pos_x = x
		window.drag_pos_y = y
	} $else {
		w.offset_x = int(x - window.drag_start_x)
		w.offset_y = int(y - window.drag_start_y)
	}
}

fn drop_child(mut window Window) {
	$if drag ? {
		w := window.drag_widget
		println('drop $w.type_name()')
	}
	sapp.show_mouse(true)
	window.drag_activated = false
}

//**** offset ****

// set offset_x and offset_y for Widget
pub fn set_offset(mut w Widget, ox int, oy int) {
	w.offset_x, w.offset_y = ox, oy
	if mut w is Stack {
		for mut child in w.children {
			set_offset(mut child, ox, oy)
		}
	} else if mut w is Group {
		for mut child in w.children {
			set_offset(mut child, ox, oy)
		}
	} else if mut w is CanvasLayout {
		for mut child in w.children {
			set_offset(mut child, ox, oy)
		}
	}
}

pub struct At {
	x      int
	y      int
	widget Widget
}

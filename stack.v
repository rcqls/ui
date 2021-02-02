// Copyright (c) 2020 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by a GPL license
// that can be found in the LICENSE file.
module ui

import gx

import eventbus

enum Direction {
	row
	column
}

struct StackConfig {
	width                int
	height               int
	vertical_alignment   VerticalAlignment
	horizontal_alignment HorizontalAlignment
	spacing              int
	stretch              bool
	direction            Direction
	margin               MarginConfig
}

struct Stack {
mut:
	x                    int
	y                    int
	width                int
	height               int
	children             []Widget
	parent               Layout
	ui                   &UI
	vertical_alignment   VerticalAlignment
	horizontal_alignment HorizontalAlignment
	spacing              int
	stretch              bool
	direction            Direction
	margin               MarginConfig
	child_width       int
	child_height      int
}

/*
Column & Row are identical except everything is reversed:
   Row is treated like a column turned by 90 degrees, so values for row are reversed.
   Width  -> Height
   Height -> Width
   X -> Y
   Y -> X
*/
fn (mut s Stack) init(parent Layout) {
	s.parent = parent
	mut ui := parent.get_ui()
	s.ui = ui
	//Not this since parent size is initialized at last position since potentially depending on children layout's sizes
	//parent_width, parent_height := parent.size()
	//parent.height and parent.width are first only depending on 
	if s.stretch {
		s.height = parent.height
		s.width = parent.width
	} else {
		if s.direction == .column {
			s.height = parent.height
		} else {
			s.width = parent.width
		}
	}
	s.height -= s.margin.top + s.margin.bottom
	s.width -= s.margin.left + s.margin.right
	s.set_pos(s.x, ui.y_offset + s.y)
	// Init all children recursively
	for mut child in s.children {
		child.init(s)
	}

	// Before setting children's positions, first set the size recursively for stack children without stack children
	s.set_child_size()

	// Set all children's positions recursively
	s.set_children_pos()
	for mut child in s.children {
		if child is Stack {
			child.set_children_pos()
		}
	}
}

fn (mut s Stack) set_children_pos() {
	mut ui := s.parent.get_ui()
	_, parent_height := s.parent.size()
	mut x := s.x
	mut y := s.y
	for mut child in s.children {
		child_width, child_height := child.size()
		ui.y_offset = y
		if s.vertical_alignment == .bottom {
			child.set_pos(x, parent_height - s.height)
		} else {
			child.set_pos(x, y)
		}
		if s.direction == .row {
			width := s.width / s.children.len
			child.propose_size(width - s.spacing / 2, s.height)
			x += child_width + s.spacing
		} else {
			y += child_height + s.spacing
		}
		if child is Stack {
			child.set_children_pos()
		}
	}
}

fn (mut s Stack) set_child_size() {
	mut h := 0
	mut w := 0
	for mut child in s.children {
		if child is Stack  {
			if child.child_width == 0 {
				child.set_child_size()
			}
		}
		child_width, child_height := child.size()
		if s.direction == .column {
			h += child_height
			if child_width > w {
				w = child_width
			}
		} else {
			w += child_width
			if child_height > h {
				h = child_height
			}
		}
	}
	if s.direction == .column {
		h += (s.children.len - 1) * s.spacing
	} else {
		w += (s.children.len - 1) * s.spacing
	}
	s.child_width = w
	s.child_height = h
}

fn stack(c StackConfig, children []Widget) &Stack {
	mut s := &Stack{
		height: c.height
		width: c.width
		vertical_alignment: c.vertical_alignment
		horizontal_alignment: c.horizontal_alignment
		spacing: c.spacing
		stretch: c.stretch
		direction: c.direction
		margin: c.margin
		children: children
		ui: 0
	}
	return s
}

fn (mut s Stack) set_pos(x int, y int) {
	s.x = x + s.margin.left
	s.y = y + s.margin.top
}

fn (s &Stack) get_subscriber() &eventbus.Subscriber {
	parent := s.parent
	return parent.get_subscriber()
}

fn (mut s Stack) propose_size(w int, h int) (int, int) {
	if s.stretch {
		s.width = w
		if s.height == 0 {
			s.height = h
		}
	}
	return s.width, s.height
}

fn (s &Stack) size() (int, int) {
	mut w := s.width
	mut h := s.height
	if s.width < s.child_width {
		w = s.child_width
	}
	if s.height < s.child_height {
		h = s.child_height
	}
	w += s.margin.left + s.margin.right
	h += s.margin.top + s.margin.bottom
	return w, h
}

fn (mut s Stack) draw() {
	// child_len := s.children.len
	// total_spacing := (child_len - 1) * s.spacing
	mut pos_y := s.y
	if s.vertical_alignment == .bottom {
		// Move the stack to the bottom. First find the biggest height.
		_, parent_height := s.parent.size()
		// println('parent_height=$parent_height s.height= $s.height')
		pos_y = parent_height - s.height
	}
	for child in s.children {
		child.draw()
	}
	s.draw_bb()
}

fn (s &Stack) draw_bb() {
	mut col := gx.red
	if s.direction == .row {
		col = gx.green
	}
	w,h:=s.size()
	s.ui.gg.draw_empty_rect(s.x - s.margin.left, s.y  - s.margin.top, w, h,col)
	s.ui.gg.draw_empty_rect(s.x, s.y, w - s.margin.left - s.margin.right, s.child_height - s.margin.top - s.margin.bottom,col)


}

fn (s &Stack) get_ui() &UI {
	return s.ui
}

fn (s &Stack) unfocus_all() {
	for child in s.children {
		child.unfocus()
	}
}

fn (s &Stack) get_state() voidptr {
	parent := s.parent
	return parent.get_state()
}

fn (s &Stack) point_inside(x f64, y f64) bool {
	return false // x >= s.x && x <= s.x + s.width && y >= s.y && y <= s.y + s.height
}

fn (mut s Stack) focus() {
	// s.is_focused = true
	// println('')
}

fn (mut s Stack) unfocus() {
	s.unfocus_all()
	// s.is_focused = false
	// println('')
}

fn (s &Stack) is_focused() bool {
	return false // s.is_focused
}

fn (s &Stack) resize(width int, height int) {
}

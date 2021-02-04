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
	width                f32	// No more int to 
	height               f32
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
	adj_width            int
	adj_height           int
	spacings             []int
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

	parent_width, parent_height := parent.size()
	println("init parent $parent_width, $parent_height $s.width $s.height")
	
	// Decode width and height to extend relative
	s.decode_size(parent)

	println("init2 parent $parent_width, $parent_height")
	
	s.set_pos(s.x, s.y)
	// Init all children recursively
	for mut child in s.children {
		child.init(s)
	}

	// Before setting children's positions, first set the size recursively for stack children without stack children
	//s.set_adjusted_size()

	// if s.direction == .column {
		if s.height == 0 {
			//println("stack adjusted height")
			s.height = s.adj_height
			println("stack adjusted height $s.adj_height $s.adj_width ($parent_width, $parent_height)")
		} else {
			s.height -= s.margin.top + s.margin.bottom
		}
	// } else {
		if s.width == 0 {
			//println("stack adjusted width")
			s.width = s.adj_width
			println("stack adjusted width $s.adj_width")
		} else {
			s.width -= s.margin.left + s.margin.right
		}
	// }
	println("stack size $s.width $s.height")


	//println("stack size2 $s.width $s.height")

	// Set all children's positions recursively
	s.set_children_pos()
	for mut child in s.children {
		if child is Stack {
			child.set_children_pos()
		}
	}
}

fn (mut s Stack) set_children_pos() {
	//mut ui := s.parent.get_ui()
	//_, parent_height := s.parent.size()
	mut x := s.x
	mut y := s.y
	for mut child in s.children {
		child_width, child_height := child.size()
		// ui.x_offset = x
		// ui.y_offset = y
		// if s.vertical_alignment == .bottom {
		// 	child.set_pos(x, parent_height - s.height)
		// } else {
			//child.set_pos(x, y)
			s.set_child_pos(child, x, y)
		// }
		if s.direction == .row {
			// Commented the two lines below because not required imho
			// Rmk: this is weird because this has to be an option: equally sized provided as an option
			// But also it would be better placed in some function dedicated to communication between children and parent to determine their sizes
			// width := (s.width - s.total_spacing())/ s.children.len
			// child.propose_size(width, s.height)
			x += child_width + s.spacing
		} else {
			y += child_height + s.spacing
		}
		if child is Stack {
			child.set_children_pos()
		}
	}
}

fn (s &Stack) set_child_pos(mut child Widget, x int, y int) {
	// Only alignment along the opposite direction (ex: .row if direction is .column and vice-versa) is considered
	// TODO: alignment in the direct direction
	// (for these different cases, container size in the direct direction is more complicated to compute)
	
	child_width, child_height := child.size()
	if s.direction == .column {
		container_width := s.width
		mut x_offset := 0
		match s.horizontal_alignment {
			.left {
				x_offset = 0
			}	
		 	.center {
				 if container_width > child_width {
					 x_offset = (container_width - child_width) / 2
				 } else {
					 x_offset = 0
				 }
			}
			.right {
				if container_width > child_width {
					 x_offset = (container_width - child_width)
				 } else {
					x_offset = 0
				 }
			}
		}
		println("x_offset $x_offset $container_width $child_width")
		child.set_pos(x + x_offset, y)
	} else {
		container_height := s.height
		mut y_offset := 0
		match s.vertical_alignment {
			.top {
				y_offset = 0
			}	
		 	.center {
				 if container_height > child_height {
					 y_offset = (container_height - child_height) / 2
				 } else {
					 y_offset = 0
				 }
			}
			.bottom {
				if container_height > child_height {
					 y_offset = container_height - child_height
				 } else {
					 y_offset = 0
				 }
			}
		}
		println("y_offset $y_offset $container_height $child_height")
		child.set_pos(x , y + y_offset)
	}
	// Keep it for general alignment
	// mut x_offset := 0
	// mut y_offset := 0
	// mut container_width := s.width
	// mut container_height := s.height
	// Keep it here, for more general alignment
	// if s.vertical_alignment == .top {
	// 	if s.horizontal_alignment == .left {
	// 		child.set_pos(x, y)
	// 	} else if s.horizontal_alignment == .center {
	// 		x_offset = s.width
	// 		child.set_pos()
	// 	} else {
			
	// 	}
	// } else if s.vertical_alignment == .center {
	// 	if s.horizontal_alignment == .left {
	// 		child.set_pos(x, y)
	// 	} else if s.horizontal_alignment == .center {

	// 	} else {
			
	// 	}
	// } else {
	// 	if s.horizontal_alignment == .left {
	// 		child.set_pos(x, y)
	// 	} else if s.horizontal_alignment == .center {

	// 	} else {
			
	// 	}
	// }
	
}

fn (mut s Stack) decode_size(parent Layout) {
	println("init layout $s.width $s.height")
	parent_width, parent_height := parent.size()
	println("parent $parent_width, $parent_height")
	if s.stretch {
		// I think this is bad because parent has many children
		s.height = parent_height
		s.width = parent_width
	} else {
		children_spacing := if ((s.width < 0 && s.direction == .row) || (s.height < 0 && s.direction == .column)) && s.parent is Stack {
			(s.parent.get_children().len - 1) * s.parent.spacing
		} else {
			0
		}
		println("neg width: $s.width neg height: $s.height")
		s.width = relative_size_from_parent(s.width, parent_width, children_spacing)
		s.height = relative_size_from_parent(s.height, parent_height, children_spacing)
		println("neg2 width: $s.width neg height: $s.height")
	}
}

fn (mut s Stack) set_adjusted_size(i int, ui &UI) {
	mut h := 0
	mut w := 0
	for mut child in s.children {
		mut child_width, mut child_height := 0, 0
		if child is Stack  {
			if child.adj_width == 0 {
				child.set_adjusted_size(i + 1, ui)
			}
			child_width, child_height = child.adj_width + child.margin.left + child.margin.right, child.adj_height + child.margin.top + child.margin.bottom
		} else {
			if child is Label {
				child.set_ui(ui)
			}
			child_width, child_height = child.size()
		}
		println("$i => child_width, child_height: $child_width, $child_height")
		//child_width, child_height := child.size()
		//child_width, child_height := child.adj_width, child.adj_height
		if s.direction == .column {
			h += child_height    // height of vertical stack means adding children's height
			if child_width > w { // width of vertical stack means greatest children's width
				w = child_width
			}
		} else {
			w += child_width      // width of horizontal stack means adding children's width
			if child_height > h { // height of horizontal stack means greatest children's height
				h = child_height
			}
		}
	}
	// adding total spacing between children
	if s.direction == .column {
		h += s.total_spacing()
	} else {
		w += s.total_spacing()
	}
	s.adj_width = w
	s.adj_height = h
}

fn stack(c StackConfig, children []Widget) &Stack {
	w, h := convert_size_f32_to_int(c.width, c.height)
	mut s := &Stack{
		height: h
		width: w
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
	if s.width < s.adj_width {
		w = s.adj_width
	}
	if s.height < s.adj_height {
		h = s.adj_height
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
	s.ui.gg.draw_empty_rect(s.x, s.y, w - s.margin.left - s.margin.right, h - s.margin.top - s.margin.bottom,col)
}

fn (s &Stack) total_spacing() int {
	total_spacing := (s.children.len - 1) * s.spacing
	return total_spacing
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

fn (s &Stack) get_children() []Widget {
	return s.children
}

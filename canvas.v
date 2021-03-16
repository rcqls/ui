// Copyright (c) 2020-2021 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by a GPL license
// that can be found in the LICENSE file.
module ui

import gg

pub type DrawFn = fn (ctx &gg.Context, state voidptr, c &Canvas) // x_offset int, y_offset int)

pub struct Canvas {
pub mut:
	width    int
	height   int
	x        int
	y        int
	offset_x int
	offset_y int
	z_index  int
	ui       &UI = 0
	hidden   bool
mut:
	parent  Layout
	draw_fn DrawFn      = voidptr(0)
	gg      &gg.Context = 0
}

pub struct CanvasConfig {
	width   int
	height  int
	z_index int
	text    string
	draw_fn DrawFn = voidptr(0)
}

fn (mut c Canvas) init(parent Layout) {
	c.parent = parent
	c.gg = parent.get_ui().gg
}

pub fn canvas(c CanvasConfig) &Canvas {
	mut canvas := &Canvas{
		width: c.width
		height: c.height
		z_index: c.z_index
		draw_fn: c.draw_fn
	}
	return canvas
}

fn (mut c Canvas) set_pos(x int, y int) {
	c.x = x
	c.y = y
}

fn (mut c Canvas) size() (int, int) {
	return c.width, c.height
}

fn (mut c Canvas) propose_size(w int, h int) (int, int) {
	c.width = w
	c.height = h
	return c.width, c.height
}

fn (mut c Canvas) draw() {
	draw_start(mut c)
	parent := c.parent
	state := parent.get_state()
	if c.draw_fn != voidptr(0) {
		c.draw_fn(c.gg, state, c)
	}
	draw_end(mut c)
}

fn (mut c Canvas) set_visible(state bool) {
	c.hidden = state
}

fn (c &Canvas) focus() {
}

fn (c &Canvas) is_focused() bool {
	return false
}

fn (c &Canvas) unfocus() {
}

fn (c &Canvas) point_inside(x f64, y f64) bool {
	return point_inside<Canvas>(c, x, y)
}

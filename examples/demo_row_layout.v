import ui
import gx

const (
	win_width  = 1200
	win_height = 500
	btn_width  = 200
	btn_height = 30
	port       = 1337
	lb_height  = 0
)

struct App {
mut:
	window ui.Window
	sizes  map[string]f64
}

fn main() {
	mut app := &App{}
	app.sizes = map{
		'100':            100.
		'20':             20.
		'.3':             .3
		'ui.stretch':     ui.stretch
		'1.5*ui.stretch': 1.5 * ui.stretch
		'2*ui.stretch':   2 * ui.stretch
		'3*ui.stretch':   3 * ui.stretch
	}
	app.window = ui.window({
		width: win_width
		height: win_height
		title: 'Stack widths and heights management'
		state: app
		mode: .resizable
		on_resize: win_resize
		on_init: win_init
	}, [
		ui.column({
			heights: [ui.compact, ui.compact, ui.stretch]
			spacing: .01
		}, [
			ui.row({
			widths: ui.compact
			heights: ui.compact
			margin_: 5
			spacing: .03
		}, [
			ui.row({
				id: 'row_btn1'
				title: 'btn1'
				margin_: .05
				spacing: .1
				widths: ui.compact
				heights: ui.compact
			}, [
				ui.listbox({
					id: 'lb1w'
					height: lb_height
					selection: 0
					on_change: lb_change
				}, map{
					'.3':             '.3'
					'100':            '100'
					'ui.stretch':     'ui.stretch'
					'ui.compact':     'ui.compact'
					'1.5*ui.stretch': '1.5 * ui.stretch'
					'2*ui.stretch':   '2 * ui.stretch'
					'3*ui.stretch':   '3 * ui.stretch'
				}),
				ui.listbox({
					id: 'lb1h'
					height: lb_height
					selection: 0
					on_change: lb_change
				}, map{
					'.3':         '.3'
					'20':         '20'
					'ui.stretch': 'ui.stretch'
					'ui.compact': 'ui.compact'
				}),
			]),
			ui.row({
				id: 'row_btn2'
				title: 'btn2'
				margin_: .05
				spacing: .1
				widths: ui.compact
				heights: ui.compact
			}, [
				ui.listbox({
					id: 'lb2w'
					height: lb_height
					selection: 1
					on_change: lb_change
				}, map{
					'.3':             '.3'
					'100':            '100'
					'ui.stretch':     'ui.stretch'
					'ui.compact':     'ui.compact'
					'1.5*ui.stretch': '1.5 * ui.stretch'
					'2*ui.stretch':   '2 * ui.stretch'
					'3*ui.stretch':   '3 * ui.stretch'
				}),
				ui.listbox({
					id: 'lb2h'
					height: lb_height
					selection: 1
					on_change: lb_change
				}, map{
					'.3':         '.3'
					'20':         '20'
					'ui.stretch': 'ui.stretch'
					'ui.compact': 'ui.compact'
				}),
			]),
		]),
			ui.column({
				margin: {
					right: .05
					left: .05
				}
				spacing: .01
				widths: ui.stretch
				bg_color: gx.Color{255, 255, 255, 128}
			}, [
				ui.label(
					id: 'l_btns_sizes'
					height: 25
					text: 'Button 1 & 2 declaration: ui.button({width: 200, height: 30, ...})'
				),
				ui.label(
					id: 'l_stack_sizes'
					height: 25
					text: 'Row (Stack) declaration:  ui.row({ widths: [.3, 100], heights: [.3, ui.compact]})'
				),
			]),
			ui.row({
				id: 'row'
				widths: [
					.3,
					100,
				]
				heights: [
					.3,
					ui.compact,
				]
				margin_: .1
				spacing: .1
				bg_color: gx.Color{50, 100, 0, 50}
			}, [
				ui.button(
					id: 'btn1'
					width: 200
					height: 30
					text: 'Button 1'
				),
				ui.button(
					id: 'btn2'
					width: 200
					height: 30
					text: 'Button 2'
				),
			]),
		]),
	])
	ui.run(app.window)
}

fn lb_change(app &App, lb &ui.ListBox) {
	key, _ := lb.selected() or { '100', '' }

	// mut sw, mut sh := lb.size()
	// println('lb_change: ($sw, $sh)')
	win := lb.ui.window

	/*
	row1 := win.stack("row_btn1")
	sw, sh = row1.size()
	print("row_btn1: ($sw, $sh) and ")
	row2 := win.stack("row_btn2")
	sw, sh = row2.size()
	println("row_btn1: ($sw, $sh)")*/

	mut iw, mut ih := -1, -1
	match lb.id {
		'lb1w' {
			iw = 0
		}
		'lb2w' {
			iw = 1
		}
		'lb1h' {
			ih = 0
		}
		'lb2h' {
			ih = 1
		}
		else {}
	}

	mut s := win.stack('row')
	// if mut s is ui.Stack {
	if iw >= 0 {
		if key == 'ui.compact' {
			s.widths[iw] = f32(btn_width)
		} else {
			s.widths[iw] = f32(app.sizes[key])
		}
	}
	if ih >= 0 {
		if key == 'ui.compact' {
			s.heights[ih] = f32(btn_height)
		} else {
			s.heights[ih] = f32(app.sizes[key])
		}
	}
	set_output_label(win)
	win.update_layout()
	set_sizes_labels(win)
	// } else {
	// 	println('$s.type_name()')
	// }
}

fn set_output_label(win &ui.Window) {
	lb1w, lb1h, lb2w, lb2h := win.listbox('lb1w'), win.listbox('lb1h'), win.listbox('lb2w'), win.listbox('lb2h')
	mut w1, mut w2, mut h1, mut h2 := '', '', '', ''
	_, w1 = lb1w.selected() or { '100', '' }
	_, w2 = lb2w.selected() or { '100', '' }
	_, h1 = lb1h.selected() or { '100', '' }
	_, h2 = lb2h.selected() or { '100', '' }
	mut lss := win.label('l_stack_sizes')
	lss.set_text('Row (Stack) declaration: ui.row({ margin_: .1, spacing: .1, widths: [$w1, $w2], heights: [$h1, $h2]})')
}

fn set_sizes_labels(win &ui.Window) {
	mut btn1 := win.button('btn1')
	mut row_btn1 := win.stack('row_btn1')
	mut w, mut h := btn1.size()
	row_btn1.title = 'Btn1: ($w, $h)'

	mut row_btn2 := win.stack('row_btn2')
	mut btn2 := win.button('btn2')
	w, h = btn2.size()
	row_btn2.title = 'Btn2: ($w, $h)'
}

fn win_resize(w int, h int, win &ui.Window) {
	set_sizes_labels(win)
}

fn win_init(win &ui.Window) {
	set_sizes_labels(win)
	mut lb := win.listbox('lb1w')
	sw, sh := lb.size()
	// mut  row1 := win.stack("ui_row_1")
	// mut  row2 := win.stack("ui_row_2")
	// if mut row1 is ui.Stack { if mut row2 is ui.Stack {
	// row1.widths = [f32(100.)].repeat(4) //row2.widths
	// }}
	// win.update_layout()
	println('win init ($sw, $sh)')
}

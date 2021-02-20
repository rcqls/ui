module ui

import gx

pub type TextCfg = gx.TextCfg | int

fn (t TextCfg) is_empty() bool {
	return match t {
		int {
			t == 0
		}
		gx.TextCfg {
			false
		}
	}
}

fn (t TextCfg) as_text_cfg() gx.TextCfg {
	return match t {
		int {
			gx.TextCfg{
				size: t
			}
		}
		gx.TextCfg {
			t
		}
	}
}

// From now since experimental, put the draw_text methods here!
//  Later if adopted, put it in the associated v files.
fn (b &Button) draw_text(x int, y int, text_ string) {
	window := b.ui.window
	tc := b.text_cfg.as_text_cfg()
	if b.fixed_text {
		b.ui.gg.draw_text(x, y, text_, tc)
	} else {
		// println("draw_text: ${int(tc.size * window.text_scale)} ${tc.size} ${window.text_scale}")
		b.ui.gg.draw_text(x, y, text_, gx.TextCfg{
			...tc
			size: int(tc.size * window.text_scale)
		})
	}
}
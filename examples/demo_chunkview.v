import ui
import gx

fn main() {
	mut cv := ui.chunkview(
		id: 'cv'
		chunks: [
			ui.parachunk(
				y: 20
				margin: 5
				content: ['|h2|TextChunk']
			),
			ui.textchunk(x: 0, y: 60, text: 'toto titi', style: 'red'),
			ui.textchunk(x: 0, y: 80, text: 'toto titi', style: 'blue'),
			ui.textchunk(
				x: 0
				y: 100
				text: '😻🥰 😬🧿 🫥😴  ✔️💾'
				style: 'emoji'
			),
			ui.parachunk(
				y: 200
				margin: 5
				content: ['|h2|ParaChunk']
			),
			// ui.parachunk(
			// 	y: 240
			// 	indent: 20
			// 	content: ['|red|toto titi tata toto titi tata ', '||tutu tete ',
			// 		'|blue|toto titi tata toto titi tata toto titi tata ',
			// 		'|emoji|😻🥰😬 🧿🫥😴  ✔️💾', 'br', 'br',
			// 		'|red|toto2 titi tata toto titi tata ', '||tutu2 tete ',
			// 		'|blue|toto2 titi tata toto titi tata toto titi tata ',
			// 		'|emoji|😻🥰😬 🧿🫥😴  ✔️💾']
			// ),
			ui.rowchunk(
				x: 0 // 30
				y: 240
				spacing: 10
				bg_color: gx.black
				// bg_radius: 10
				chunks: [
					ui.parachunk(
						indent: 20
						content: ['|red|toto titi tata toto titi tata ', '||tutu tete ',
							'|blue|toto titi tata toto titi tata toto titi tata ',
							'|emoji|😻🥰😬 🧿🫥😴  ✔️💾', 'br', 'br',
							'|red|toto2 titi tata toto titi tata ', '||tutu2 tete ',
							'|blue|toto2 titi tata toto titi tata toto titi tata ',
							'|emoji|😻🥰😬 🧿🫥😴  ✔️💾']
					),
					ui.textchunk(text: 'toto titi', style: 'red'),
				]
			),
		]
	)
	mut window := ui.window(
		width: 800
		height: 600
		title: 'V UI: ChunkView'
		layout: ui.column(
			heights: [ui.compact, ui.stretch]
			children: [
				ui.rectangle(
					height: 30
					color: gx.rgb(255, 100, 100)
				),
				ui.row(
					children: [
						ui.rectangle(
							width: 30
							color: gx.rgb(255, 100, 100)
						),
						cv,
						ui.rectangle(
							width: 30
							color: gx.rgb(255, 100, 100)
						),
					]
				),
				ui.rectangle(
					height: 30
					color: gx.rgb(255, 100, 100)
				),
			]
		)
	)
	// add DrawTextWidget specific style
	mut dtw := ui.DrawTextWidget(cv)
	dtw.add_style(
		id: 'red'
		size: 20
		font_name: 'fixed_bold'
		color: gx.red
	)
	// Add global style
	window.add_style(
		id: 'blue'
		size: 30
		font_name: 'system'
		color: gx.blue
	)
	// Add global style
	window.add_style(
		id: 'h2'
		size: 40
		font_name: 'fixed_bold_italic'
	)
	// emoji
	window.add_style(
		id: 'emoji'
		size: 20
		font_name: 'noto_emoji'
		mono: false
	)
	ui.run(window)
}

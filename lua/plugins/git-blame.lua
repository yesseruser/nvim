return {
	"f-person/git-blame.nvim",
	event = "VeryLazy",
	opts = {
		enabled = false, -- if you want to enable the plugin
		message_template = "\t<committer> • <summary> • <date> • <<sha>>",
		date_format = "%d-%m-%y %H:%M",
		virtual_text_column = 60,
		virtual_text = true,
		delay = 1000,
		max_commit_summary_length = 40,
	},
}

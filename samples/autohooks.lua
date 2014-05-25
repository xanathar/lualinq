
autohook =
{
	party =
	{
		onPickUpItem = function(self, item)
			print("onPickUpItem")
		end,

		onMove = function(self, direction)
			print("onMove")
		end,

		onTurn = function(self, direction)
			print("onTurn")
		end,
	}
}


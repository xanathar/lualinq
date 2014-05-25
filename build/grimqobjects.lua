
__itemstoautomate = { "dungeon_alcove", "temple_alcove", "prison_alcove", "altar", "torch_holder" }

for _, item in ipairs(__itemstoautomate) do
	cloneObject({name = "auto_" .. item, baseObject = item	})
end


defineObject{
	name = "auto_printer",
	class = "Item",
	uiName = "",
	model = "assets/models/items/scroll.fbx",
	gfxIndex = 112,
	scroll = true,
	weight = 0.3,
	editorIcon = 28,
}




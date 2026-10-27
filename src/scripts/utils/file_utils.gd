class_name FileUtils

# Save Loading
#Example Path
#"user://settings.json"
# Look at DirAccess.make_dir_recursive() and DirAccess.make_dir_recursive_absolute() to make folders if needed
static func save_json(path : String, content : String):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_line(content)
	file.close()

static func save_json_by_dict(path : String, dict : Dictionary):
	save_json(path, JSON.stringify(dict))

static func load_json(path : String): #For loading json inside the res:// folder.  Use separate function for outside
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return
	var json_dict = JSON.parse_string(file.get_as_text())
	file.close()
	return json_dict

# # # # # # # # # # # # # # # # # # # # # # # # # # #
# Files
static func get_files(path, valid_extensions : Array[String], max_depth : int = 1, current_depth : int = 0) -> Dictionary:
	var files_dict : Dictionary = {}
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name : String = dir.get_next()
		while file_name != "":
			var full_path : String = path + "/" + file_name
			
			# Is Folder
			if dir.current_is_dir():
				if current_depth < max_depth:
					var result : Dictionary = get_files(full_path, valid_extensions, max_depth, current_depth + 1)
					var basename : String = file_name.get_basename()
					files_dict[basename] = result
			# Is File
			else:
				var extension : String = file_name.get_extension()
				if extension in valid_extensions:
					var basename : String = file_name.get_basename()
					files_dict[basename] = full_path
				
			file_name = dir.get_next()
	return files_dict

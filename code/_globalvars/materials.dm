GLOBAL_LIST_INIT(materials, init_materials())
GLOBAL_LIST_EMPTY(material_comp_cache)

/proc/init_materials()
	var/list/mat_list = list()
	for(var/type in typesof(/datum/material))
		if(is_abstract(type))
			continue
		mat_list[type] = new type()
	return mat_list

/proc/get_material_list_cache(list/materials)
	if(!materials)
		return
	var/list/string_list = list()
	for(var/type in materials)
		string_list += "[type][materials[type]]"
	sortTim(string_list, /proc/cmp_text_asc)
	var/key = string_list.Join()
	if(!GLOB.material_comp_cache[key])
		GLOB.material_comp_cache[key] = materials.Copy()
	return GLOB.material_comp_cache[key]

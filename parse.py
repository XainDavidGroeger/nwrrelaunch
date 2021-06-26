import pprint
import re
pp = pprint.PrettyPrinter(depth=4)

class KVParser():

	def __init__(self):
		self.__intend_char = "\t"
		self.__new_line_char = "new_line"

	def __parse_kv__(self, kv_string):
		temp_key = None
		temp_string = None
		result = {}

		recursion = False
		recursion_queue = []
		recursion_start = -1

		for num, char in enumerate(kv_string, 0):
			if not recursion:
				if char == "\"":
					if temp_string is None:
						temp_string = ""
					elif temp_key is None:
						temp_key = temp_string
						temp_string = None
					elif temp_key is not None:
						if temp_key in result.keys():
							if type(result[temp_key]) == type(""):
								result[temp_key] = [result[temp_key], temp_string]
							elif type(result[temp_key]) == type([]):
								result[temp_key].append(temp_string)
						else:
							result.update({temp_key: temp_string})\
						# print(f"KV appended {temp_key} - {temp_string}")
						temp_key = None
						temp_string = None

				elif char == "#":
					temp_string = "#"

				elif char == ' ' and temp_string is not None and temp_string[0] == "#":
					temp_key = temp_string
					temp_string = None
						

				elif char == "{":
					recursion = True
					recursion_queue.append('{')
					recursion_start = num+1
				
				else:
					if temp_string is not None:
						temp_string += char

			else:
				if char == '{':
					recursion_queue.append('{')
				elif char == '}':
					recursion_queue.pop()
					if len(recursion_queue) == 0:
						recursion = False
						result[temp_key] = self.__parse_kv__(kv_string[recursion_start:num-1])
						# print(f"OB appended {temp_key} ...")
						temp_key = None

			
		return result

	def parse_string(self, string):
		return self.__parse_kv__(string)

	def __dump_multistring__(self, mstring, level, indent):
		return "\n {0} {{ \n {1} \n {0} }} \n".format(indent*level, mstring)

	def __dump_one_line__(self, string, level, indent):
		return "{0} \"{1}\" \n".format(level*indent, string)

	def dump_dict(self, object, level=0, indent="\t"):
		result = ""
		for key, value in object.items():
			if not type(key) == type(""):
				raise Exception(f"Unknown key type when dumping:\n Value - {key}, type: {type(key)}")

			if not (type(value) == type(dict()) or type(value) == type("")):
				raise Exception(f"Unknown value type when dumping:\n Value - {value}, type: {type(value)}")
			
			result += "{0} \"{1}\"".format(indent*level, key)
			if type(value) == type(dict()):
				result += self.__dump_multistring__(self.dump_dict(value, level+1, indent=indent), level, indent=indent)

			elif type(value) == type(""):
				result += "\t \"{0}\" \n".format(value)

		return result


class DOTAArcadeHelper():

	def __init__(self):
		self.parser = KVParser()
		self.abilities_file_path = "game/dota_addons/nwrrelaunch/scripts/npc/npc_abilities_custom.txt"
		self.vscritps_path = '/'.join(self.abilities_file_path.split('/')[:-2]) + "/vscripts/"
		self.abilities_file = None
		self.abilities_file_parsed = None
		self.abilities_kv = {}
		self.abilities_lua = {}

		self.script_files_list = []

	def parse_recursively(self, file_path):
		abilities_file = open(file_path)
		file_dir = '/'.join(file_path.split('/')[:-1]) + "/"

		result = self.parser.parse_string(abilities_file.read())
		if "DOTAAbilities" not in result.keys():
			result["DOTAAbilities"] = {}
		temp_result = {}
		for key, value in result.items():
			if key == "#base":
				if type(value) == type([]):
					for fpath in value:
						base_file_parsed = self.parse_recursively(file_dir + fpath)
						temp_result.update(base_file_parsed["DOTAAbilities"])

				elif type(value) == type(""):
					base_file_parsed = self.parse_recursively(file_dir + value)
					temp_result.update(base_file_parsed["DOTAAbilities"])

		
		result["DOTAAbilities"].update(temp_result)
		if "#base" in result.keys():
			result.pop('#base')

		abilities_file.close()
		return result

	def gather_modifier_kv(self, parsed_abilities):
		result = {}
		for key, value in parsed_abilities.items():
			if type(value) == type({}):
				if key == "Modifiers":
					for mod_name, mod_value in value.items():
						if "IsHidden" in mod_value.keys():
							result[mod_name] = {"IsHidden" : True if mod_value["IsHidden"] == '1' else False}
						else:
							result[mod_name] = {"IsHidden": False}

					# result.append(value)
				elif key not in ["AbilitySpecial", "precache"]:
					result = result | self.gather_modifier_kv(value)
			else:
				pass
		
		return result

	def gather_modifiers_lua(self, parsed_abilities):
		result = {}
		for key, value in parsed_abilities.items():
			lua_file_path = self.vscritps_path + value["ScriptFile"]
			lua_file_content = open(lua_file_path).read()
			modifier_list = re.findall('LinkLuaModifier\("(\S*)",\s?"(\S*)",\s?[A-Z_]*\)', lua_file_content)
			print(modifier_list)
			for modifier_name, modifier_file_path in modifier_list:
				modifier_file_full_path = self.vscritps_path + modifier_file_path
				modifier_file_full_path = modifier_file_full_path if modifier_file_full_path.endswith('.lua') else modifier_file_full_path + '.lua'
				if modifier_file_full_path == lua_file_path:
					modifier_file_content = lua_file_content
				else:
					with open(modifier_file_full_path) as f:
						modifier_file_content = f.read()
				is_hidden = re.match(
					f"{modifier_name}:IsHidden\(\)\s*return\s*(true|false)\s*end", 
					modifier_file_content)
				is_hidden = is_hidden.group(1) if is_hidden is not None else 'false'
				result = result | {modifier_name: {"IsHidden": True if is_hidden == 'true' else False}}
		lua_file_content.close()
		return result



	def main(self):
		# Parsing abilities recursively (including #base)
		self.abilities_file_parsed = self.parse_recursively(self.abilities_file_path)
		# Dividing abilities into KV and Lua
		for key,value in self.abilities_file_parsed["DOTAAbilities"].items():
			if type(value) == type({}):
				if "ScriptFile" in value.keys():
					self.abilities_lua = self.abilities_lua | {key: value}
				else:
					self.abilities_kv = self.abilities_kv | {key: value}

if __name__ == "__main__":
	helper = DOTAArcadeHelper()
	helper.main()
	result = helper.gather_modifier_kv(helper.abilities_kv)
	result = helper.gather_modifiers_lua(helper.abilities_lua)

	
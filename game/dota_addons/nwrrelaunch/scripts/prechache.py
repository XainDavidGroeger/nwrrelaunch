import re

f = open("npc/abilities/anko/anko_giant_snake.txt")

# Dump KV into dict object

dump = {}

def dump_list(string):
    pass

def clear_string(string):
    return re.sub(r"[ \t]*", "", string)

strn = """
aaaaaaa        bbbbbbbbbbb \t\t \t cccccccc
ddddd eeeeee fffff
"""

print(clear_string(f.read()))
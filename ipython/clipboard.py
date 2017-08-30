from IPython.core.magic import register_line_magic


@register_line_magic
def clip(line):
    global_dict = globals()
    if line not in global_dict:
        return
    value = global_dict[line]
    import os
    os.system("echo '%s' | tr -d '\n' | pbcopy" % str(value))


del clip

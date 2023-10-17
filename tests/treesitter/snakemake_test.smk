rule all:
    input:
        "b.txt"
    output:
        "c.txt"
    shell:
        "ls -la > {output}"

def f():
    pass

var = 'hi'

# make
Makefile
form `https://makefiletutorial.com`

## Examples
```Makefile
targets: prerequisites
   command
   command
   command
```

## Separator
Only `tabs` are allowed.

## Beginner Examples
* Make is given blah as the target, so it first searches for this target
* blah requires blah.o, so make searches for the blah.o target
* blah.o requires blah.c, so make searches for the blah.c target
* blah.c has no dependencies, so the echo command is run
* The cc -c command is then run, because all of the blah.o dependencies are finished
* The top cc command is run, because all the blah dependencies are finished
* That's it: blah is a compiled c program
```Makefile
blah: blah.o
	cc blah.o -o blah # Runs third

blah.o: blah.c
	cc -c blah.c -o blah.o # Runs second

blah.c:
	echo "int main() { return 0; }" > blah.c # Runs first
```

## Make `some_file`
```Makefile
some_file:
	echo "This line will always print"
```

```Makefile
some_file:
	echo "This line will only print once"
	touch some_file
```

## Make `some_file` and `other_file`
```Makefile
some_file: other_file
	echo "This will run second, because it depends on other_file"
	touch some_file

other_file:
	echo "This will run first"
	touch other_file
```

## Make clean
```Makefile
some_file: 
	touch some_file

clean:
	rm -f some_file
```

# Variables
Variables can only be strings.
```Makefile
files = file1 file2
some_file: $(files)
    echo "Look at this variable: " $(files)
    touch some_file

file1:
    touch file1
file2:
    touch file2

clean:
    rm -f file1 file2 some_file
```
## Reference the variables
```Makefile
x = dude

all:
	echo $(x)
	echo ${x}

	# Bad practice, but works
	echo $x
```
# Targets
## Run them `all`
```Makefile
all: one two three

one:
    touch one
two:
    touch two
three:
    touch three

clean:
    rm -f one two three
```
## Multiple targets
```Makefile
all: f1.o f2.o

f1.o f2.o:
    echo $@
# Equivalent to:
# f1.o
#     echo $@
# f2.o
#     echo $@
```

# Automatic Variables and Wildcards
## `*` Wildcard
`*` searches your filesystem for matching filenames.
Always use `wildcard` function.
```Makefile
# Print out file information about every .c file
print: $(wildcard *.md)
    ls -la  $?
```
Pitfalls of `*`:
```Makefile
thing_wrong := *.o # Don't do this! '*' will not get expanded
thing_right := $(wildcard *.o)

all: one two three four

# Fails, because $(thing_wrong) is the string "*.o"
one: $(thing_wrong)

# Stays as *.o if there are no files that match this pattern :(
two: *.o 

# Works as you would expect! In this case, it does nothing.
three: $(thing_right)

# Same as rule three
four: $(wildcard *.o)
```




# `=` vs `:=`:
```Makefile
x := foo
y := $(x) bar # y - foo bar
x := later

a = foo
b = $(a) bar # b - later bar
a = later

test:
	@echo x - $(x)
	@echo y - $(y)
	@echo a - $(a)
	@echo b - $(b)
```
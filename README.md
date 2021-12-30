# How to `make` it?
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

# Wildcards and Automatic Variables
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

## `%` Wildcard
`%` is really useful, but confusing, because has different modes:
* `matching` mode: Matches one or more characters in a string (called `stem`).
* `replacing` mode: It takes the `stem` that was matched and replaces that in a string.
* `%` most often used in rule definitions and in some specific functions.

### Confusing and very not clear examples:
#### Static Pattern Rules
<details>
	<summary>
		------------------
	</summary>
<p>
Static pattern rules are another way to write less in a Makefile, but I'd say are more useful and a bit less "magic". Here's their syntax:

```Makefile
targets...: target-pattern: prereq-patterns ...
	commands
```

The essence is that the given target is matched by the target-pattern (via a % wildcard). Whatever was matched is called the stem. The stem is then substituted into the prereq-pattern, to generate the target's prereqs.

A typical use case is to compile .c files into .o files. Here's the manual way:
```Makefile
objects = foo.o bar.o all.o
all: $(objects)

# These files compile via implicit rules
foo.o: foo.c
bar.o: bar.c
all.o: all.c

all.c:
	echo "int main() { return 0; }" > all.c

%.c:
	touch $@

clean:
	rm -f *.c *.o all
```
Here's the more efficient way, using a static pattern rule:
```Makefile
objects = foo.o bar.o all.o
all: $(objects)

# These files compile via implicit rules
# Syntax - targets ...: target-pattern: prereq-patterns ...
# In the case of the first target, foo.o, the target-pattern matches foo.o and sets the "stem" to be "foo".
# It then replaces the '%' in prereq-patterns with that stem
$(objects): %.o: %.c

all.c:
	echo "int main() { return 0; }" > all.c

%.c:
	touch $@

clean:
	rm -f *.c *.o all
```

</p>
</details>

#### Pattern Rules
<details>
	<summary>
		------------------
	</summary>
Pattern rules are often used but quite confusing. You can look at them as two ways:
* A way to define your own implicit rules
* A simpler form of static pattern rules
Let's start with an example first:

```Makefile
# Define a pattern rule that compiles every .c file into a .o file
%.o : %.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
```
Pattern rules contain a '%' in the target. This '%' matches any nonempty string, and the other characters match themselves. ‘%’ in a prerequisite of a pattern rule stands for the same stem that was matched by the ‘%’ in the target.

Here's another example:

```Makefile
# Define a pattern rule that has no pattern in the prerequisites.
# This just creates empty .c files when needed.
%.c:
   touch $@
```

</p>
</details>

#### String Substitution
<details>
	<summary>
		------------------
	</summary>
<p>
$(patsubst pattern,replacement,text) does the following:

"Finds whitespace-separated words in text that match pattern and replaces them with replacement. Here pattern may contain a ‘%’ which acts as a wildcard, matching any number of any characters within a word. If replacement also contains a ‘%’, the ‘%’ is replaced by the text that matched the ‘%’ in pattern. Only the first ‘%’ in the pattern and replacement is treated this way; any subsequent ‘%’ is unchanged."

The substitution reference $(text:pattern=replacement) is a shorthand for this.

There's another shorthand that that replaces only suffixes: $(text:suffix=replacement). No % wildcard is used here.

Note: don't add extra spaces for this shorthand. It will be seen as a search or replacement term.

```Makefile
# String Substitution
foo := a.o b.o l.a c.o
one := $(patsubst %.o,%.c,$(foo))
# This is a shorthand for the above
two := $(foo:%.o=%.c)
# This is the suffix-only shorthand, and is also equivalent to the above.
three := $(foo:.o=.c)

all:
	echo $(one)
	echo $(two)
	echo $(three)
```
</p>
</details>

#### The `vpath` Directive
<details>
	<summary>
		------------------
	</summary>
<p>
Use `vpath` to specify where some set of prerequisites exist. 
The format is:
```Makefile
vpath pattern directories, space/colon separated
```

`pattern` can have a %, which matches any zero or more characters.
You can also do this globallyish with the variable `VPATH`

```Makefile
vpath %.h ../headers ../other-directory

some_binary: ../headers blah.h
	touch some_binary

../headers:
	mkdir ../headers

blah.h:
	touch ../headers/blah.h

clean:
	rm -rf ../headers
	rm -f some_binary
```
</p>
</details>

#### Make `.py` file:
<details>
	<summary>
		------------------
	</summary>
<p>
Make `.py` file:
```Makefile
%.py:
	touch $@
```
</p>
</details>


## Automatic Variables

There are many automatic variables, but often only a few show up:
```Makefile
hey: one two
	# Outputs "hey", since this is the first target
	echo $@

	# Outputs all prerequisites newer than the target
	echo $?

	# Outputs all prerequisites
	echo $^

	touch hey

one:
	touch one

two:
	touch two

clean:
	rm -f hey one two
```

# Fancy Rules
## Implicit Rules
Make loves c compilation. And every time it expresses its love, things get confusing. Perhaps the most confusing part of Make is the magic/automatic rules that are made. Make calls these "implicit" rules. I don't personally agree with this design decision, and I don't recommend using them, but they're often used and are thus useful to know. Here's a list of implicit rules:

* Compiling a C program: n.o is made automatically from n.c with a command of the form `$(CC) -c $(CPPFLAGS) $(CFLAGS)`
* Compiling a C++ program: n.o is made automatically from n.cc or n.cpp with a command of the form `$(CXX) -c $(CPPFLAGS) $(CXXFLAGS)`
* Linking a single object file: n is made automatically from n.o by running the command `$(CC) $(LDFLAGS) n.o $(LOADLIBES) $(LDLIBS)`

The important variables used by implicit rules are:
* `CC`: Program for compiling C programs; default cc
* `CXX`: Program for compiling C++ programs; default g++
* `CFLAGS`: Extra flags to give to the C compiler
* `CXXFLAGS`: Extra flags to give to the C++ compiler
* `CPPFLAGS`: Extra flags to give to the C preprocessor
* `LDFLAGS`: Extra flags to give to compilers when they are supposed to invoke the linker
```Makefile
CC = gcc # Flag for implicit rules
CFLAGS = -g # Flag for implicit rules. Turn on debug info

# Implicit rule #1: blah is built via the C linker implicit rule
# Implicit rule #2: blah.o is built via the C compilation implicit rule, because blah.c exists
blah: blah.o

blah.c:
	echo "int main() { return 0; }" > blah.c

clean:
	rm -f blah*
```
## Static Pattern Rules and Filter
While I introduce functions later on, I'll foreshadow what you can do with them. The filter function can be used in Static pattern rules to match the correct files. In this example, I made up the .raw and .result extensions.
```Makefile
obj_files = foo.result bar.o lose.o
src_files = foo.raw bar.c lose.c

.PHONY: all
all: $(obj_files)

$(filter %.o,$(obj_files)): %.o: %.c
	echo "target: $@ prereq: $<"
$(filter %.result,$(obj_files)): %.result: %.raw
	echo "target: $@ prereq: $<" 

%.c %.raw:
	touch $@

clean:
	rm -f $(src_files)
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

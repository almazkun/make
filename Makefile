x := foo
y := $(x) bar
x := later

a = foo
b = $(a) bar
a = later

test:
	@echo x - $(x)
	@echo y - $(y)
	@echo a - $(a)
	@echo b - $(b)
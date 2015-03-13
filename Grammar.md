# Introduction #
Sibil is a simple language designed to be EXTREMELY easy to read. It is ideal for instructional purposes.

# Grammar #

## Variables ##
There are currently two types of variables in the Sibil language:

  * Integers: They follow the naming rules in C/C++, e.g. `var`, `var1`.
  * Strings: They follow the naming rules in C/C++, but has a `$` (dollar sign) preceding them, e.g. `$var`, `$var1`.

## Expressions ##
Expressions are modeled after C.

Exceptions:
  * `mod`: equivalent to `%` in C.
  * `and` `or` `not`: equivalent to `&&` `||` `!` in C.
  * `is`: equivalent to `==` in C.
  * `is not`: equivalent to `!=` in C.

## Commands ##
Commands in Sibil are the following:

### Set variable ###
`var_name = value`

### Print ###
`print arg1 [, arg2...]`

  * `arg` can be expression, variable, or string.

### If-statement ###
`if expression then commands [else commands]` or
```
if expression:
    commands
[else:
    commands]
endif
```

### Loop ###
Not implemented.
# colas-bash-lib

This is the repository of the miscellaneous small bits of code and info I use in my bash scripts. My personal bash developer toolkit.

## Scripts (in bin/)

Standalone small bash scripts that do not deserve a separate repository (such as [cgibashopts](https://github.com/ColasNahaboo/cgibashopts), [rsync-incr](https://github.com/ColasNahaboo/rsync-incr), [tewiba](https://github.com/ColasNahaboo/tewiba), [irclogger](https://github.com/ColasNahaboo/irclogger), ...) can be found in `bin/`:
- [firefox-sessions-backups](bin/firefox-sessions-backups) Maintains backups of the Firefox previous sessions file.
- [function-names-allowed-chars](bin/function-names-allowed-chars) Lists the allowed chars in bash function names.

## Library (in src/)

My collection of various small **bash functions** I reuse often in my bash scripts. they expect a modern bash version, I guess version 5 at least, although most should work with bash 4.3+.
Fell free to copy and use in any of your projects or compilation of bash tools.

Bigger copy-pastable functions have their own repository, such as [bashoptions](https://github.com/ColasNahaboo/bashoptions).

I have tried to make them the **fastest** possible, by avoiding forking sub-shells or external commands, and benchmarking extensively to compare the possible way of coding them. Of course, I will gladly accept suggestions or code to make them faster. But it means that error checking is often terse and minimal, and readability of the code was not a priority.

I have a kind of «anti-npm» approach, in that I **copy** these functions into my scripts rather that using them as a true external library that I would load at runtime. It thus avoid installation issues, and the dependency problems that may arise from automated upgrades. Just keep the "`from:`" comment at the start to know where (url) to check for upgrades, and which version of the function this copy is.

Most of the files in the form `src/foo.sh` have many **versions** of the same functions. For a function named `foo`, you can find:

- **"functional forms"** `foo` that prints its result on **stdout**. This is the traditional way used in most scripts, so that's why I always provide it.
  E.g: `gee=$(foo bar)`
- **"set forms"** `set_foo` that sets the result into a **variable** that must be provided as first argument. This is my preferred way to use bash functions, as it is faster than the "normal" way above (often twice as fast), and it allows the function to access the main script variables, which is especially important with arrays as they cannot be passed as arguments. And it provides a simple way to return multiple values, by using more than one "set" variables. But the drawback is that they are cumbersome to use in recursive programs, as you must take care that the variable name is not the same as the name used for it inside the function. I prefix these internal variables with an underscore to try to minimize name clashes, but it is not foolproof.
  E.g: `set_foo gee bar`
- **"var forms"** `var_foo` modifies **in place** the contents of the variable given as argument, if it is a common use case. For instance, trimming space is often performed in place, so I provide `var_trim`, but not `var_regexp_quote`,  as using the same variable to hold a regexp or its quoted version could be error-prone.
  E.g: `var_foo gee`_is the same as `set_foo gee "$gee"`or `gee=$(foo "$gee")`
- **"samename forms"** `foo` is a simplified, and a tiny bit faster, form of set forms, where the function sets its return value to a variable of the **same name** of the function. But I rarely use this, as I think that the very small speed gain is not worth the potential confusion for readers that are not familiar that the same name can refer to a function or a variable.
  E.g: after calling `foo bar`, the result can be found in the shell variable `$foo`

All these functions duplicate their code so that they are standalone and can be **copied individually**, unless clearly specified. It is an «anti-framework» approach. It is expected you will only copy the functions and the forms you are actually using into your scripts rather than loading the whole file as is (but it can be done).

The non-trivial functions start with a `local -; set +xve`  line that removes the **trace mode** when in the function, with nearly no speed penalty. Thus when debugging a script by `set -xv` your log is not polluted by the internal tracing of these function that can be quite long when iterating on strings for instance. It also disables the `set -e` flag, just to be sure that these functions do not trigger spurious errors if you run your script with this flag.

The functions pass `shellcheck`, and can be used with `set -u`.

### library files

Here is the user documentation for the library functions, in alphabetical order on the file names. More technical details can be found as comments in the files, and I only document here the "functional form", knowing that at least "set forms" are also provided for each functions. The list of available forms is given in a "Forms:" line.
E.g. you can use `variable=$(regexp_nocase expression)` (functional form) or `set_regexp_nocase variable expression` (set form) even if only `regexp_nocase` is documented below. And if the "Form:" line was listing "var", you could use `var_regexp_nocase variable`.

#### src/ascii.sh

- `i2a` *{integer}*
  Returns the character (string of length 1) of ascii code *{integer}*.
  E.g: `i2a 65` returns `A`
  
  Forms: functional, set

- `a2i` *{character}*
  Returns the decimal ascii code (integer) of the character (string of length 1) parameter.
  E.g: `a2i "A"` returns `65`
  
  Forms: functional, set

- `x2a`*{hexadecimal}* Returns the character (string of length 1) of ascii code *{hexadecimal}*. 
  E.g:`x2a 41`returns`A`
  
  Forms: functional, set

- `a2x` *{character}* Returns the hexadecimal ascii code (integer) of the character (string of length 1) parameter.
  E.g: `x2i "A"` returns `41` 
  
  Forms: functional, set

#### src/pptime.sh

- `pptime` *{integer}*
  Prints on its stdout a human-friendly form of the number of seconds as argument
  E.g: `pptime 57689243` prints `27d4h47m23s`, `pptime 666` prints `11m6s`
  The globals `pptimesep` and `ppformat` control the output format,
  E.g: with `pptimesep=' '`, `pptime 57689243` prints `27d 4h 47m 23s`, `pptime 666` prints `11 m6s`
  with `ppformat='02'`, `pptime 57689243` prints `27d04h47m23s`, `pptime 666` prints `11m06s`

#### src/regexp_nocase.sh

- `regexp_nocase` *{regular-expression}*
  Takes a regular expression (as used in `[[ =~ ]]`) as only parameter, and returns a modified version that matches in a case-insensitive way.
  E.g: `a` becomes `[aA]`, `a.b` becomes `[aA].[bB]`, `[a-c]` becomes `[a-cA-C]`, `[[:lower:]]` becomes `[[:alpha:]]`, etc...
  
  This is very useful when you want to match a regular expression with some parts matching with case, and others not, because bash lacks [inline regexp modifiers](https://www.rexegg.com/regex-modifiers.html) such as `(?i)`.
  
  Forms: functional, set.

#### src/regexp_quote.sh

- `regexp_quote` *{regular-expression}*
  
  Takes a regular expression (as used in `[[ =~ ]]`) as only parameter, and returns a modified version that quotes (or escape) special characters to make them match literally. A bit like `fgrep`.
  E.g: `a.b` becomes `a[.]b`, `x*[a-c]` becomes `x[*][[]a-c[]]`, etc...
  This is very useful when you want to match a regular expression with some parts matching literally, and other parts matching as regexps.
  
  Forms: functional, set.

- `regexp_quote_nocase` *{regular-expression}*
  
  As `regexp_quote` above, but the returned regular expression is made case-independent.
  E.g: `a.b` becomes`[aA][.][bB]`,` x*[a-c]`becomes`[xX][*][[][aA]-[xX][cC][]]`, etc...
  
  Forms: functional, set.

Only in "set" form:

- `add_regexp_quote` *{variable} {expression}*
  As `set_regexp_quote`, but the quoted regular expression is appended to the string already in *variable*._Convenient when building a regular expression piece by piece.
- `add_regexp_quot_nocase`*{variable} {expression}* 
  As`add_regexp_quote` above, but the appended regular expression is made case-independent.

#### src/trim.sh

- `trim` *{string}*
  Removes the spaces or tabs at the start and end of the *{string}* argument and returns it
  
  Forms: functional, set, var.

### Library test suite (in tests/)

A test suite for the library function is available in `test/`, based on [Tewiba (TEsting WIth BAsh)](https://github.com/ColasNahaboo/tewiba), (provided). It can be useful to run it by `cd tests; ./tewiba` or `tests/RUN_ALL_TESTS`on non-standard linux installation to check that the functions can be used without problems.

## Useful links

These are the web sites I have found useful for my bash programming needs:

Info:

- The [Bash Reference Manual](https://www.gnu.org/software/bash/manual/bash.html)
- Greycat's [Bash FAQ](http://mywiki.wooledge.org/BashFAQ) as well as [Chet Ramey FAQ](http://tiswww.case.edu/php/chet/bash/FAQ)
- [Features of bash versions](https://mywiki.wooledge.org/BashFAQ/061), a useful summary of when a feature appeared in bash versions, a part of Greycat FAQ.
- [Bash style guides for Google projects](https://google.github.io/styleguide/shellguide.html)
- [Bash Unofficial Strict Mode](http://redsymbol.net/articles/unofficial-bash-strict-mode/) A set of conventions to minimize hard to find bugs
- [The Bash Hackers Wiki](https://wiki.bash-hackers.org/start)
- [A Complete Guide on How To Use Bash Arrays](https://www.shell-tips.com/bash/arrays/)
- https://tldp.org/LDP/abs/html/ (a bit old)
- [Nick Sweeting's reading list](https://github.innominds.com/pirate/bash-utils#reading-list) a collection of useful bash links
- [Calex Xu curated list](https://unix-shell.zeef.com/caleb.xu) of shell utilities

Tools:

- [Shellcheck](https://www.shellcheck.net/), a "lint" for bash
- [Bashdb](http://bashdb.sourceforge.net/) a "gdb-like" debugger for bash
- [Tewiba (TEsting WIth BAsh)](https://github.com/ColasNahaboo/tewiba), my lightweight bash testing system. See also [dodie's Bash test framework comparison](https://github.com/dodie/testing-in-bash) for a list of other test frameworks.
- [GitHub - zricethezav/gitleaks: Scan git repos (or files) for secrets using regex and entropy 🔑](https://github.com/zricethezav/gitleaks)
- https://github.com/progrium/go-basher

Libraries:

- [Top (Marco&rsquo;s Bash Functions Library)](http://marcomaggi.github.io/docs/mbfl.html/index.html#Top)
- [Stop Bashing Bash - Conjur](https://www.conjur.org/blog/stop-bashing-bash/)
- http://www.bashinator.org/
- https://github.innominds.com/topics/bash-library list of reporitories matching `bash-library` on GitHub

## History

High-level history of changes

- v1.0.0 (2022-02-04) First deployment, with modules: ascii, regexp_nocase, regexp_quote, trim

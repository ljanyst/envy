
Envy
====

In short, *Envy* is a small program that can be used in the shebang line of a
script as a replacement of `/usr/bin/env`.

What is a shebang line? From Wikipedia:

> In computing, a shebang is the character sequence consisting of the characters
> number sign and exclamation mark (#!) at the beginning of a script.
>
> In Unix-like operating systems, when a text file with a shebang is used as if
> it is an executable, the program loader parses the rest of the file's initial
> line as an interpreter directive; the specified interpreter program is
> executed, passing to it as an argument the path that was initially used when
> attempting to run the script, so that the program may use the file as input
> data. For example, if a script is named with the path path/to/script, and it
> starts with the following line, #!/bin/sh, then the program loader is
> instructed to run the program /bin/sh, passing path/to/script as the first
> argument.

The shebang line must contain an absolute path to the interpreter. However,
you may want to run different interpreters in different circumstances and not
want change the script. In such cases, you may say something like
`#!/usr/bin/env python`, and `env` will find your preferred python interpreter
depending on the `PATH` settings.

*Envy* is an extension of this mechanism in that it may load a shell script
setting the environment to your liking before it executes the interpreter
you want. Let's consider the following example:

```python
#!/home/jdoe/apps/bin/envy.sh python ai

import tensorflow
import sys

for arg in sys.argv:
    print(arg)
```

*Envy* will search for the `ai` environment definition in `~/.envyrc` and source
a shell script associated with it into the current environment. It will then
search for the `python` interpreter taking into account the new `PATH` settings,
and execute it.

The environment definitions in `~/.envyrc` are key-value pairs, each in a
separate line. The definition below associates a setup script with the
environment `ai`:

```bash
ENV_AI=/home/jdoe/apps/python/envs/ai/bin/activate
```

The names must consist of only numbers and/or uppercase Latin letters, the paths
must be absolute, and the bash scripts they are pointing to must exists.

When the `ENVY_DEBUG` environment variable is set, *Envy* will print diagnostics
to the standard error output. That's what you will see if you try to run the
above script:

    ]==> ENVY_DEBUG=1 ./test.py test1 test2 "test3 test4"
    [i] === Envy Diangostics ===
    [i] Username: jdoe
    [i] Home: /home/jdoe
    [i] Environment: AI
    [i] Sourcing /home/jdoe/.envyrc
    [i] Sourcing the configured environment file: /home/jdoe/apps/python/envs/ai/bin/activate
    [i] Interpreter: python
    [i] Script's commandline arguments: ./test.py test1 test2 test3 test4
    [i] Interpreter path: /home/jdoe/apps/python/envs/ai/bin/python
    ./test.py
    test1
    test2
    test3 test4

**When is it useful?** It helps when you need to run a program with custom
environment settings and do not have control over how the program is started. A
good use case is a shebang line of a CGI script running with Apache in a hosting
service to which you do have the admin access.

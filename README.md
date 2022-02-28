SupervisionTree
====

[![CI](https://github.com/georgiybykov/supervision_tree/actions/workflows/ci.yml/badge.svg)](https://github.com/georgiybykov/supervision_tree/actions)

This application includes supervisors and workers using different strategies for initialize and restart.
___

```bash
$ git clone git@github.com:georgiybykov/supervision_tree.git

$ cd supervision_tree

# Install and compile dependencies:
$ mix do deps.get, deps.compile

# Start IEx:
$ iex -S mix
```

___

### **For example, the Supervision Tree:**

![Supervision Tree](/priv/static/images/processes.jpg)

You can check it out by:

```bash
$ iex -S mix

iex(1)> :observer.start
```

And then go to the "Applications" tab (i.g. the screenshot is above).

___

### You can check and play with different strategies of Supervisor in IEx like:

```bash
$ iex -S mix

Erlang/OTP 24 [erts-12.1.5] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [jit]

Compiling 1 file (.ex)

21:47:07.498 [info]  main_worker_with_permanent_restart: is starting
21:47:07.501 [info]  main_worker_with_transient_restart: is starting
21:47:07.501 [info]  first_worker: is starting
21:47:07.501 [info]  second_worker: is starting
21:47:07.501 [info]  third_worker: is starting
21:47:07.501 [info]  fourth_worker: is starting
21:47:07.501 [info]  fifth_worker: is starting
21:47:07.501 [info]  sixth_worker: is starting
21:47:07.501 [info]  seventh_worker: is starting
21:47:07.501 [info]  eighth_worker: is starting
21:47:07.501 [info]  ninth_worker: is starting
21:47:07.501 [info]  sub_worker: is starting

# Let's try to terminate one of the workers right here:
iex(1)> SupervisionTree.Worker.stop(:seventh_worker)

# We can trace the behavior of workers below:
21:48:02.514 [info]  seventh_worker: is terminating
21:48:02.514 [info]  sub_worker: is terminating
21:48:02.514 [info]  ninth_worker: is terminating
21:48:02.514 [info]  eighth_worker: is terminating
21:48:02.514 [info]  seventh_worker: is starting
21:48:02.515 [info]  eighth_worker: is starting
21:48:02.515 [info]  ninth_worker: is starting
21:48:02.515 [info]  sub_worker: is starting

:ok

iex(2)> # Good luck! May the force be with you!
```

# Gremlin

My scripts for bootstrapping my system. This project is broken up into
two components:

1. Gremlin - the tool for managing the installation of various plans
   and its support scripts

2. Plans - these are custom plans which I have written for
   bootstrapping various systems of mine

## Quick Start

Replace `<plan>` below with a named plan, such as "personal", and
execute in a terminal.

``` shell
wget -nv -O- https://raw.githubusercontent.com/jmpage/gremlin/refs/heads/main/bootstrap | /usr/bin/env bash /dev/stdin <plan>
```

## File Structure

Directory | Description
-|-
`bin/` | Scripts related to development.
`core/` | Scripts for supporting the execution of gremlin to aid in plan execution.
`core/support/` | Support scripts for use in gremlin features.
`plans/` | Custom plans which use the gremlin "DSL" to bootstrap a system.
`features/` | Features which can be installed or setup by plans.

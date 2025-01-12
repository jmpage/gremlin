# Gremlin

My scripts for bootstrapping my system. This project is broken up into
two components:

1. Gremlin - the tool for managing the installation of various plans
   and its support scripts

2. Plans - these are custom plans which I have written for
   bootstrapping various systems of mine

## File Structure

Directory | Description
-|-
`gremlin/` | Scripts for supporting the execution of gremlin to aid in plan execution.
`plans/` | Custom plans which use the gremlin "DSL" to bootstrap a system.
`features/` | Features which can be installed or setup by plans.

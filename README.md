# Gremlin

An ansible playbook for setting up my development machine.

Clone this repo and run the playbook with:

``` shell
ansible-playbook -K -i inventory playbook.yml
```

or, on macOS:

``` shell
ansible-playbook -K -i inventory.darwin playbook.yml
```

If on macOS, follow the instructions on `POST_INSTALL.DARWIN.md` after
running the playbook.

# Building the Stack

The backend stack uses `docker compose`

## Running the stack

You can use the `run-pharmanthi-test` to deploy on test or `run-pharmanthi-prod` on prod as follows:

### Getting started

```bash
chmod +x run-pharmanthi-*

# deploy test
./run-pharmanthi-test

# or, deploy prod
./run-pharmanthi-prod
```

### Options

You can use the following options with the two scripts:

* `--build`: will rebuild the docker stack using the `--build` options of `docker compose`
* `--no-cache`: will add the `--no-cache` options to `docker compose`
* `--update`: if set, will first ensure to checkout into `main` branch, pull the latest changes, then build. If not set, the stack will be built using the current version of the code found inside the backend folder(regardless of the branch)
* `--clean` is used for a fresh build, without re-using existing images. Behind the scene, this option run the `docker image prune --all --force` command first.

## Bringing down the stack

* To put down the system, run the `./kill` script.

```bash
chmod +x kill
./kill
```bash
```

* To bring down the stack and kill the server

```bash
./kill --poweroff
```

## TAuxialiary Scripts

These are scripts used by either of the previously mentioned scripts

* `prepare-environment`: ensure the senvironment is ready to for bringing up the stack, i.e; env variables are set.

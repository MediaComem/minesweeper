# Minesweeper

A [minesweeper][minesweeper] game implemented with:

* The [Phoenix web framework][phoenix] written in [Elixir][elixir] (backend).
* The [Alpine.js JavaScript framework][alpinejs] (frontend).

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Requirements](#requirements)
- [Initial setup](#initial-setup)
- [(Optionally) run automated tests](#optionally-run-automated-tests)
- [(Optionally) run the application in development mode](#optionally-run-the-application-in-development-mode)
- [Run the application in production mode](#run-the-application-in-production-mode)
- [Instructions](#instructions)
- [Troubleshooting](#troubleshooting)
- [Notes](#notes)
- [Configuration](#configuration)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->



## Requirements

To run the application once it has been compiled, you will need:

* [Elixir][elixir] 1.12 or 1.13 compiled with [Erlang/OTP][erlang] 24
* [PostgreSQL][postgresql] 12, 13 or 14 and a database with the [uuid-ossp
  extension][postgresql-uuid-ossp]

Additionally, to compile the frontend application, you will need:

* [Node.js][node] 16



## Initial setup

* Create a PostgreSQL user named `minesweeper` for the application (**be sure to
  remember the password you type**, you will need it later):

  ```bash
  $> sudo -u postgres createuser --interactive --pwprompt minesweeper
  Enter password for new role:
  Enter it again:
  Shall the new role be a superuser? (y/n) n
  Shall the new role be allowed to create databases? (y/n) n
  Shall the new role be allowed to create more new roles? (y/n) n
  ```
* Create a PostgreSQL database named `minesweeper` and owned by the
  `minesweeper` user:

  ```bash
  $> sudo -u postgres createdb --owner minesweeper minesweeper
  ```
* Create the [uuid-ossp extension][postgresql-uuid-ossp] in the `minesweeper`
  database:

  ```bash
  $> sudo -u postgres psql -c 'CREATE EXTENSION "uuid-ossp";' minesweeper
  ```
* Clone the repository:

  ```bash
  $> git clone https://github.com/MediaComem/minesweeper.git
  ```
* Download dependencies:

  ```bash
  $> cd minesweeper
  $> mix deps.get
  ```
* Compile the application (*this might take a while*):

  ```bash
  $> mix compile
  ```
* Install frontend dependencies:

  ```bash
  $> mix frontend.install
  ```
* Create a local configuration file (which will be ignored by Git):

  ```bash
  cp config/local.sample.exs config/local.exs
  ```
* Edit `config/local.exs` with your favorite editor. Read the instructions it
  contains and fill in the database connection URL and web endpoint settings.

  > If you want to run the automated tests later, you will need two databases
  > and two database connection URLs: one for production and one for testing
  > (the databases could be named `minesweeper` and `minesweeper-test`, for
  > example).
* Migrate the production database:

  ```bash
  $> mix ecto.migrate
  ```



## (Optionally) run automated tests

* Create a separate PostgreSQL test database named `minesweeper-test` also owned
  by the `minesweeper` user:

  ```bash
  $> sudo -u postgres createdb --owner minesweeper minesweeper-test
  ```
* Create the [uuid-ossp extension][postgresql-uuid-ossp] in the
  `minesweeper-test` database:

  ```bash
  $> sudo -u postgres psql -c 'CREATE EXTENSION "uuid-ossp";' minesweeper-test
  ```
* Compile the application in test mode (*this might take a while*):

  ```bash
  $> MIX_ENV=test mix compile
  ```
* Migrate the test database:

  ```bash
  $> MIX_ENV=test mix ecto.migrate
  ```
* Run the automated tests:

  ```bash
  $> MIX_ENV=test mix test
  ```



## (Optionally) run the application in development mode

To check that the application is working at this point, you can run it in
development mode:

```bash
$> mix phx.server
```

The application runs on port 3000 by default. If that port is already in use,
you can use the `$MINESWEEPER_HTTP_PORT` environment variable to use another
port:

```bash
$> MINESWEEPER_HTTP_PORT=3001 mix phx.server
```

Visit `http://<your-server-address>:<port>` in your browser and you should see
the application running.

> Once you are done, you can stop the `mix phx.server` command running in your
> terminal by typing Ctrl-C twice.



## Run the application in production mode

* Compile the application in production mode (*this might take a while*):

  ```bash
  $> MIX_ENV=prod mix compile
  ```
* Build the frontend in production mode:

  ```bash
  $> MIX_ENV=prod mix do frontend.build, phx.digest
  ```
* Assemble a [mix release][mix-release] to run the application in production
  mode:

  ```bash
  $> MIX_ENV=prod mix release
  ```

You can run the production manually by executing the following command:

```bash
_build/prod/rel/minesweeper/bin/minesweeper start
```

Again, if port 3000 is already in use, you can use the `$MINESWEEPER_HTTP_PORT`
environment variable to use another port:

```bash
$> MINESWEEPER_HTTP_PORT=3001 _build/prod/rel/minesweeper/bin/minesweeper start
```

> To run the application with a process manager like [systemd][systemd], you can
> run the same command except that it should be an absolute path. For example:
>
> ```bash
> $> /path/to/minesweeper/_build/prod/rel/minesweeper/bin/minesweeper start
> ```
>
> (Replace `/path/to/minesweeper` with the path to the repository.)



## Configuration

| Environment variable          | Module config                                           | Default value                              | Description                                                                                                                                                 |
| :---------------------------- | :------------------------------------------------------ | :----------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `MINESWEEPER_DATABASE_URL`    | `url` property of `Minesweeper.Repo`                    | `ecto://minesweeper@localhost/minesweeper` | Database connection URL (format is `ecto://<username>[:<password>]@<host>[:<port>]/<database-name>`)                                                        |
| `MINESWEEPER_HTTP_PORT`       | `http.port` property of `MinesweeperWeb.Endpoint`       | `3000`                                     | The port the HTTP server will listen on.                                                                                                                    |
| `MINESWEEPER_SECRET_KEY_BASE` | `secret_key_base` property of `MinesweeperWeb.Endpoint` | -                                          | A secret key used as a base to generate secrets for encrypting and signing data (e.g. cookies & tokens). Use `mix phx.gen.secret` to generate a strong key. |



[alpinejs]: https://alpinejs.dev
[elixir]: https://elixir-lang.org
[erlang]: https://www.erlang.org
[minesweeper]: https://en.wikipedia.org/wiki/Minesweeper_(video_game)
[mix-release]: https://hexdocs.pm/mix/1.12/Mix.Tasks.Release.html
[node]: https://nodejs.org
[npm]: https://www.npmjs.com
[phoenix]: https://www.phoenixframework.org
[postgresql]: https://www.postgresql.org
[postgresql-uuid-ossp]: https://www.postgresql.org/docs/current/uuid-ossp.html
[systemd]: https://en.wikipedia.org/wiki/Systemd

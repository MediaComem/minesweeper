# Minesweeper

A [minesweeper][minesweeper] web application. The backend has been developed
with the [Phoenix web framework][phoenix] written in [Elixir][elixir]. The
frontend has been developed with the [Alpine.js JavaScript framework][alpinejs].

[![build](https://github.com/MediaComem/minesweeper/actions/workflows/build.yml/badge.svg)](https://github.com/MediaComem/minesweeper/actions/workflows/build.yml)
[![license](https://img.shields.io/github/license/MediaComem/minesweeper)](https://opensource.org/licenses/MIT)

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Requirements](#requirements)
- [Initial setup](#initial-setup)
- [Run the automated tests](#run-the-automated-tests)
- [Run the application in development mode](#run-the-application-in-development-mode)
- [Run the application in production mode](#run-the-application-in-production-mode)
- [Updating](#updating)
- [Configuration](#configuration)
  - [Environment variables](#environment-variables)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->



## Requirements

To run the application, you will need:

* [PostgreSQL][postgresql] 13-17 and a database with the [uuid-ossp
  extension][postgresql-uuid-ossp]

Additionally, to compile the backend and frontend, you will need:

* One of the following Elixir and Erlang/OTP combinations:
  * [Elixir][elixir] 1.17.x with [Erlang/OTP][erlang] 25-27
  * [Elixir][elixir] 1.16.3 with [Erlang/OTP][erlang] 25-26
  * [Elixir][elixir] 1.15.8 with [Erlang/OTP][erlang] 25-26
  * [Elixir][elixir] 1.14.5 with [Erlang/OTP][erlang] 25-26
* [Node.js][node] 18, 20 or 22



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

  > You should answer no to all questions. The `minesweeper` user does not need
  > any special privileges.
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
* Compile the application (*this might take a while the first time*):

  ```bash
  $> mix compile
  ```
* Install frontend dependencies:

  ```bash
  $> mix frontend.install
  ```
* Configure the application. **You can do this in one of two ways:**

  * Set any of the [documented environment variables](#environment-variables),
    for example:

    ```bash
    export MINESWEEPER_DATABASE_URL="ecto://minesweeper:mysecretpassword@localhost:5432/minesweeper"
    export MINESWEEPER_HTTP_PORT=3000
    export MINESWEEPER_SECRET_KEY_BASE="mysecretkey"
    ```
  * Create a local configuration file based on the provided sample:

    ```bash
    cp config/local.sample.exs config/local.exs
    ```

    Edit `config/local.exs` with your favorite editor:

    ```bash
    nano config/local.exs
    vim config/local.exs
    ```

    Read the instructions contained in the file and fill in the database
    connection URL and web endpoint settings.

    > The `config/local.exs` file will be ignored by Git.
    >
    > Configuration parameters provided this way will be bundled in the
    > compiled production release.

  > You can use both the local configuration file and environment variables, in
  > which case the environment variables specified at runtime will always
  > override the corresponding settings in the configuration file.
* Migrate the production database:

  ```bash
  $> mix ecto.migrate
  ```



## Run the automated tests

Follow these instructions to execute the project's [automated test
suite][automated-tests]:

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
* Compile the application in test mode (*this might take a while the first
  time*):

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

You should see no errors. Every green dot represents a passed test.

> For more information, read the [tests' source code in the `test`
> directory](./test).



## Run the application in development mode

You can run the application in development mode (with live reload) using the
following command:

```bash
$> mix phx.server
```

The application runs on port 3000 by default. If that port is already in use,
you can use the `http.port` parameter in the local configuration file or the
`$MINESWEEPER_HTTP_PORT` environment variable to switch to another port, for
example:

```bash
$> MINESWEEPER_HTTP_PORT=3001 mix phx.server
```

Visit `http://<your-server-address>:<port>` in your browser and you should see
the application running.

> Once you are done, you can stop the `mix phx.server` command running in your
> terminal by typing Ctrl-C twice.



## Run the application in production mode

* Compile the application in production mode (*this might take a while the first time*):

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

You can run the production manually by executing the following command from the
repository:

```bash
_build/prod/rel/minesweeper/bin/minesweeper start
```

Again, if port 3000 is already in use, you can use the `http.port` parameter in
the local configuration file or the `$MINESWEEPER_HTTP_PORT` environment
variable to switch to another port, for example:

```bash
$> MINESWEEPER_HTTP_PORT=3001 _build/prod/rel/minesweeper/bin/minesweeper start
```

> To run the application with a process manager like [systemd][systemd], you can
> run the same command except that it should be an absolute path. For example:
>
> ```bash
> $> /path/to/minesweeper/_build/prod/rel/minesweeper/bin/minesweeper start
> ```



## Updating

To update the application after getting the latest changes, execute the
following commands in the application's directory:

```bash
# Update backend & frontend dependencies, and migrate the database:
$> mix do deps.get, frontend.update

# Apply any pending database migrations.
$> MIX_ENV=prod mix ecto.migrate

# Rebuild the frontend in production mode and reassemble the Mix release:
$> MIX_ENV=prod mix do frontend.build, phx.digest, release --overwrite
```

You may then restart the application.



## Configuration

You can configure the application in two ways:

* Either create a `config/local.exs` file in the application's directory (see
  the `config/local.sample.exs` sample file).
* Or use the environment variables documented below.

You may also use both. The parameters in the local configuration file are
bundled in the compiled production release. Note that the environment variables,
if present at runtime, will always take precedence and override the
corresponding parameters from the configuration file.

### Environment variables

| Environment variable                         | Default value                              | Description                                                                                              |
| :------------------------------------------- | :----------------------------------------- | :------------------------------------------------------------------------------------------------------- |
| `MINESWEEPER_DATABASE_URL` or `DATABASE_URL` | `ecto://minesweeper@localhost/minesweeper` | Database connection URL (format is `ecto://<username>[:<password>]@<host>[:<port>]/<database-name>`)     |
| `MINESWEEPER_HTTP_PORT` or `PORT`            | `3000`                                     | The port the HTTP server listens on.                                                                     |
| `MINESWEEPER_SECRET_KEY_BASE`                | -                                          | A secret key used as a base to generate secrets for encrypting and signing data (e.g. cookies & tokens). |
| `MINESWEEPER_URL`                            | `http://localhost:3000`                    | The base URL at which the application is publicly available.                                             |

> You can generate a strong secret key base by running the `mix phx.gen.secret`
> command in the project's directory.



[alpinejs]: https://alpinejs.dev
[automated-tests]: https://en.wikipedia.org/wiki/Test_automation
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

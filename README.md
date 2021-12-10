# Minesweeper

A [minesweeper][minesweeper] game implemented with the [Phoenix web
framework][phoenix] in [Elixir][elixir].

## Requirements

* [Elixir][elixir] 1.12+
* [PostgreSQL][postgresql] 12+

## Setup

```bash
$> sudo apt install postgresql postgresql-contrib
$> sudo -u postgres createuser --interactive
Enter name of role to add: john_doe
Shall the new role be a superuser? (y/n) n
Shall the new role be allowed to create databases? (y/n) n
Shall the new role be allowed to create more new roles? (y/n) n
$> sudo -u postgres createuser --interactive --pwprompt
Enter name of role to add: john_doe
Enter password for new role:
Enter it again:
Shall the new role be a superuser? (y/n) y
$> sudo -u postgres createdb --owner john_doe minesweeper
$> sudo -u postgres psql -l
$> psql minesweeper
```

```bash
$> git clone https://github.com/MediaComem/minesweeper.git
$> cd minesweeper
$> mix deps.get
```

```bash
$> MIX_ENV=test mix compile
$> sudo -u postgres createdb --owner john_doe minesweeper-test
$> MIX_ENV=test mix reset
$> mix test
```

```bash
$> mix compile
$> sudo -u postgres createdb --owner simon_oulevay minesweeper
$> mix reset
$> cd assets
$> npm ci
$> cd ..
$> MINESWEEPER_HTTP_PORT=3001 mix phx.server
```

```bash
$> MIX_ENV=prod mix assets.deploy
$> MIX_ENV=prod mix release
$> cd assets
$> npm run build
$> cd ..
$> MIX_ENV=prod mix phoenix.digest
```

## Notes

```bash
$> sudo apt install inotify-tools
```

Save memory:

```bash
$> sudo systemctl stop mysql
$> sudo systemctl disable mysql
$> sudo systemctl stop gdm
$> sudo systemctl disable gdm
$> sudo apt remove snapd --purge
```

## Configuration

| Environment variable          | Module config                                           | Default value                              | Description                                                                                                                                                 |
| :---------------------------- | :------------------------------------------------------ | :----------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `MINESWEEPER_DATABASE_URL`    | `url` property of `Minesweeper.Repo`                    | `ecto://minesweeper@localhost/minesweeper` | Database connection URL (format is `ecto://<username>[:<password>]@<host>[:<port>]/<database-name>`)                                                        |
| `MINESWEEPER_HTTP_PORT`       | `http.port` property of `MinesweeperWeb.Endpoint`       | `3000`                                     | The port the HTTP server will listen on.                                                                                                                    |
| `MINESWEEPER_SECRET_KEY_BASE` | `secret_key_base` property of `MinesweeperWeb.Endpoint` | -                                          | A secret key used as a base to generate secrets for encrypting and signing data (e.g. cookies & tokens). Use `mix phx.gen.secret` to generate a strong key. |

[elixir]: https://elixir-lang.org
[minesweeper]: https://en.wikipedia.org/wiki/Minesweeper_(video_game)
[phoenix]: https://www.phoenixframework.org
[postgresql]: https://www.postgresql.org

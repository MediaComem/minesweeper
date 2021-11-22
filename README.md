# Minesweeper

A [minesweeper][minesweeper] game implemented with the [Phoenix web
framework][phoenix] in [Elixir][elixir].

## Requirements

* [Elixir][elixir] 1.12+
* [PostgreSQL][postgresql] 14+

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

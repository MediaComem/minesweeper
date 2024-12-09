defmodule Minesweeper.MixProject do
  use Mix.Project

  def project do
    [
      app: :minesweeper,
      version: "2.0.2",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      aliases: aliases(),
      deps: project_dependencies(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "reset.test": :test,
        "test.watch": :test
      ],
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Minesweeper.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp project_dependencies do
    [
      {:phoenix, "~> 1.7"},
      {:phoenix_ecto, "~> 4.6"},
      {:phoenix_html_helpers, "~> 1.0"},
      {:ecto_sql, "~> 3.12"},
      {:postgrex, "~> 0.19.2"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_view, "~> 1.0"},
      {:jason, "~> 1.4"},
      {:plug_cowboy, "~> 2.7"},
      # Development dependencies
      {:phoenix_live_reload, "~> 1.5", only: :dev},
      # Test dependencies
      {:assert_html, "~> 0.1.4", only: :test},
      {:excoveralls, "~> 0.18.3", only: :test},
      {:ex_machina, "~> 2.8", only: :test},
      {:mix_test_watch, "~> 1.2", only: :test, runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "cmd npm ci --prefix assets"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "frontend.build": ["cmd ./scripts/build-frontend.sh"],
      "frontend.install": ["cmd ./scripts/install-frontend.sh"],
      "frontend.update": ["cmd ./scripts/update-frontend.sh"],
      reset: ["ecto.drop", "ecto.setup"],
      "reset.test": ["reset"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end

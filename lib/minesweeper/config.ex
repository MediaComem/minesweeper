defmodule Minesweeper.Config do
  defmodule InvalidValue do
    defexception message: "Configuration is invalid."
  end

  defmodule MissingValue do
    defexception message: "Configuration is incomplete."
  end

  @app :minesweeper

  def database_url!() do
    env_config_value!(Minesweeper.Repo, :url, env: :database_url, desc: "Database connection URL")
  end

  def port!() do
    env_config_value!(MinesweeperWeb.Endpoint, [:http, :port],
      desc: "Server port",
      coerce: &parse_env_port/2
    )
  end

  def secret_key_base!() do
    env_config_value!(
      MinesweeperWeb.Endpoint,
      :secret_key_base,
      desc: "Secret key base"
    )
  end

  defp env_config_value!(module, key, opts)
       when is_list(opts) and is_atom(key) do
    env_config_value!(module, [key], opts)
  end

  defp env_config_value!(module, path, opts)
       when is_list(opts) and is_list(path) do
    description = Keyword.fetch!(opts, :desc)
    coerce = Keyword.get(opts, :coerce, &Function.identity(&1))

    env_var_suffix =
      Keyword.get(
        opts,
        :env,
        path |> Enum.map(&Atom.to_string/1) |> Enum.join("_") |> String.upcase()
      )

    env_var = "MINESWEEPER_#{env_var_suffix}"
    env_value = System.get_env(env_var)

    config_source = Application.fetch_env!(@app, module)
    config_value = get_in(config_source, path)

    case {env_value, config_value} do
      {value, _} when is_binary(value) ->
        coerce.(value, env_var)

      {nil, value} when not is_nil(value) ->
        value

      _ ->
        human_path = path |> Enum.map(&Atom.to_string/1) |> Enum.join(".")

        raise MissingValue, """
        #{description} is not set.

        Set the $#{env_var} environment variable or configure the
        #{human_path} key of {module} in config/local.exs (see sample file
        #config/local.sample.exs)
        """
    end
  end

  defp parse_env_port(value, env_var) when is_binary(value) and is_binary(env_var) do
    parse_env_integer(value, env_var, 1, 65_535)
  end

  defp parse_env_integer(value, env_var, min, max)
       when is_binary(value) and is_binary(env_var) and
              is_integer(min) and is_integer(max) do
    case Integer.parse(value) do
      {parsed, ""}
      when parsed >= min and parsed <= max ->
        parsed

      :error ->
        raise """
        Environment variable $#{env_var} must be an integer between #{min} and #{max}.
        """
    end
  end
end

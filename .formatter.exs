[
  import_deps: [:ecto, :phoenix],
  inputs: ["*.{ex,exs,heex}", "{config,lib,test}/**/*.{ex,exs,heex}", "priv/*/seeds.exs"],
  subdirectories: ["priv/*/migrations"]
]

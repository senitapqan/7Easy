[
  line_length: 120,
  import_deps: [:ecto, :ecto_sql, :phoenix],
  subdirectories: ["priv/*/migrations"],
  plugins: [Recode.FormatterPlugin],
  inputs: [
    "*.{ex,exs}",
    "playground/**/*.{ex,exs}",
    "{config,lib,test}/**/*.{ex,exs}",
    "priv/*/seeds.exs",
    ".scratchpad/**/*.{ex,exs}"
  ]
]

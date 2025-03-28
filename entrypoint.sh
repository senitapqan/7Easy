#!/bin/sh
set -e

echo "==> Running migrations..."
bin/seven_easy eval "Ecto.Migrator.with_repo(App.Repo, &Ecto.Migrator.run(&1, :up, all: true))"

echo "==> Running seeds..."
bin/seven_easy eval "Ecto.Migrator.with_repo(App.Repo, fn _ -> Code.eval_file(\"./priv/repo/seeds.exs\") end)"

echo "==> Starting Phoenix server..."
exec bin/seven_easy start

defmodule App.SchemaUtils do
  import Ecto.Changeset

  @doc """
  Converts an struct to a map.

  ## Example

    > instagram_media = %InstagramMedia{caption: "hello", influencer: %InstagramInfluencer{username: "helloworld"}}
    > attrs = to_map!(instagram_media)
    %{caption: "hello", influencer: %{username: "helloworld"}}

    > to_schema!(InstagramMedia, attrs)
    %InstagramMedia{caption: "hello", influencer: %InstagramInfluencer{username: "helloworld"}}

  """
  @spec to_map!(Ecto.Schema.t()) :: map()
  def to_map!(struct) when is_struct(struct) do
    struct_to_map(struct)
  end

  defp struct_to_map(%DateTime{} = datetime), do: datetime
  defp struct_to_map(%NaiveDateTime{} = naive_datetime), do: naive_datetime
  defp struct_to_map(%Date{} = date), do: date

  defp struct_to_map(struct) when is_struct(struct) do
    struct
    |> Map.from_struct()
    |> struct_to_map()
  end

  defp struct_to_map(map) when is_map(map) do
    for {key, value} <- map, key != :__meta__, into: %{} do
      {key, struct_to_map(value)}
    end
  end

  defp struct_to_map(list) when is_list(list) do
    Enum.map(list, &struct_to_map/1)
  end

  defp struct_to_map(value), do: value

  @doc """
  Convert map to schema

  ## Example
    instagram_media = %InstagramMedia{caption: "hello", influencer: %InstagramInfluencer{username: "helloworld"}}
    attrs = to_map!(instagram_media)
    to_schema!(InstagramMedia, attrs) # => %InstagramMedia{caption: "hello", influencer: %InstagramInfluencer{username: "helloworld"}}

  """
  @spec to_schema!(module(), map()) :: Ecto.Schema.t()
  def to_schema!(module, attrs) when is_atom(module) do
    module
    |> struct()
    |> changeset(attrs)
    |> apply_changes()
  end

  defp changeset(schema, attrs) do
    module = schema.__struct__
    fields = module.__schema__(:virtual_fields) ++ (module.__schema__(:fields) -- module.__schema__(:embeds))
    embeds = module.__schema__(:embeds)
    # NOTE: I'm using module.__changeset__() instead of module.__schema__(:associations) because
    #   the last one includes through assocs that can't be casted
    assocs = for {key, {:assoc, _}} <- module.__changeset__(), do: key

    schema
    |> cast(attrs, fields)
    |> cast_all_embeds(embeds)
    |> cast_all_assocs(assocs)
  end

  defp cast_all_embeds(changeset, embeds) do
    Enum.reduce(embeds, changeset, fn field, changeset ->
      cast_embed(changeset, field, with: &changeset/2)
    end)
  end

  defp cast_all_assocs(changeset, assocs) do
    Enum.reduce(assocs, changeset, fn field, changeset ->
      cast_assoc(changeset, field, with: &changeset/2)
    end)
  end
end

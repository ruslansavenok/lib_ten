defmodule LibTen.Products do
  @moduledoc """
  The Products context.
  """

  import Ecto.Query, warn: false
  alias LibTen.Repo

  alias LibTen.Products.{Product, ProductUse}

  @doc """
  Returns the list of products.

  ## Examples

      iex> list_products()
      [%Product{}, ...]

  """
  def list_products do
    Repo.all(products_query())
  end

  @doc """
  Gets a single product.

  Raises `Ecto.NoResultsError` if the Product does not exist.

  ## Examples

      iex> get_product!(123)
      %Product{}

      iex> get_product!(456)
      ** (Ecto.NoResultsError)

  """
  def get_product!(id) do
    query = from product in products_query(),
      where: product.id == ^id
    Repo.one!(query)
  end

  @doc """
  Creates a product.

  ## Examples

      iex> create_product(%{field: value})
      {:ok, %Product{}}

      iex> create_product(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_product(attrs \\ %{}) do
    case %Product{}
         |> Product.changeset(attrs)
         |> Repo.insert()
    do
      {:ok, product} -> broadcast_change("created", product)
      error -> error
    end
  end

  @doc """
  Updates a product.

  ## Examples

      iex> update_product(product, %{field: new_value})
      {:ok, %Product{}}

      iex> update_product(product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_product(%Product{} = product, attrs) do
    case product
         |> Product.changeset(attrs)
         |> Repo.update()
    do
      {:ok, product} -> broadcast_change("updated", product)
      error -> error
    end
  end

  @doc """
  Deletes a Product.

  ## Examples

      iex> delete_product(product)
      {:ok, %Product{}}

      iex> delete_product(product)
      {:error, %Ecto.Changeset{}}

  """
  def delete_product(%Product{} = product) do
    case Repo.delete(product) do
      {:ok, product} -> broadcast_change("deleted", product)
      error -> error
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product changes.

  ## Examples

      iex> change_product(product)
      %Ecto.Changeset{source: %Product{}}

  """
  def change_product(%Product{} = product) do
    Product.changeset(product, %{})
  end


  def take_product(product_id, user_id) do
    product = get_product!(product_id)
    product_use_attrs = %{product_id: product_id, user_id: user_id}

    case product
         |> Product.changeset(%{product_use: product_use_attrs})
         |> Repo.update()
    do
      {:ok, product} -> broadcast_change("updated", product)
      error -> error
    end
  end


  def return_product(product_id, user_id) do
    query = from product in Product,
      left_join: product_use in ProductUse,
        on: product_use.product_id == product.id,
        on: product_use.user_id == ^user_id,
        on: is_nil(product_use.ended_at),
      where: product.id == ^product_id,
      preload: [product_use: {product_use, :user}]

    product = Repo.one!(query)
    product_use_attrs = %{
      id: product.product_use.id,
      ended_at: DateTime.utc_now
    }

    case product
         |> Product.changeset(%{product_use: product_use_attrs})
         |> Repo.update()
    do
      {:ok, product} -> broadcast_change("updated", product)
      error -> error
    end
  end


  def to_json_map(%Product{} = product) do
    %{
      id: product.id,
      title: product.title,
      url: product.url,
      author: product.author,
      status: product.status,
      category_id: product.category_id,
      product_use:
        case product.product_use do
          {id, inserted_at, user} ->
            %{
              id: id,
              started_at: inserted_at,
              user_name: user.name
            }
          _ -> nil
        end
    }
  end


  def to_json_map(products) do
    Enum.map(products, &to_json_map/1)
  end


  defp products_query do
    from product in Product,
      left_join: product_use in ProductUse,
        on: product_use.product_id == product.id and is_nil(product_use.ended_at),
      preload: [product_use: {product_use, :user}]
  end


  defp broadcast_change(type, %Product{} = product) do
    LibTenWeb.Endpoint.broadcast!("products", type, to_json_map(product))
    {:ok, product}
  end
end

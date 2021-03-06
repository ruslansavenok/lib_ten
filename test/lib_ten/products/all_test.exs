defmodule LibTen.Products.AllTest do
  use LibTen.DataCase
  import LibTen.Factory
  alias LibTen.Products.{ProductUse}
  alias LibTen.Products.All

  test "list/0 returns products sorted by inserted_at" do
    user = insert(:user)

    product1 =
      insert(:product,
        inserted_at: ~N[2000-01-01 00:00:00.000000],
        requested_by_user: user,
        used_by: nil
      )

    product2 =
      insert(:product,
        inserted_at: ~N[2000-01-01 00:01:00.000000],
        requested_by_user: user,
        used_by: nil
      )

    assert All.list() == [product2, product1]
  end

  test "get/1 returns product" do
    product = insert(:product, requested_by_user: nil, used_by: nil)
    assert All.get(product.id) == product
  end

  test "create/2 creates record" do
    user = insert(:user)
    category = insert(:category)
    attrs = params_for(:product, category_id: category.id, status: "IN_LIBRARY")
    {:ok, product} = All.create(attrs, user.id)
    assert product.requested_by_user_id == user.id
    assert product.author == attrs.author
    assert product.title == attrs.title
    assert product.url == attrs.url
    assert product.status == attrs.status
  end

  describe "update" do
    test "update/3 returns nil in no product with given id" do
      assert All.update(-1, %{category_id: 1}) == nil
    end

    test "update/3 returns %Ecto.Changeset{} if record is invalid" do
      product = insert(:product, status: "ORDERED", category: insert(:category))
      {:error, %Ecto.Changeset{}} = All.update(product.id, %{url: ''})
    end

    test "with user role, update/3 updates product if it's present" do
      product = insert(:product)
      category = insert(:category)
      attrs = params_for(:product, category_id: category.id, status: "ORDERED")
      {:ok, updated_product} = All.update(product.id, attrs)
      assert updated_product.author == attrs.author
      assert updated_product.title == attrs.title
      assert updated_product.url == attrs.url
      assert updated_product.category_id == category.id
      assert updated_product.status == "ORDERED"
    end
  end

  describe "force_return/1" do
    test "returns error when can't find product with give id" do
      assert {:error, _} = All.force_return(0)
    end

    test "returns error when can't find ProductUse" do
      product = insert(:product)
      user = insert(:user)

      insert(:product_use,
        product_id: product.id,
        user_id: user.id,
        ended_at: DateTime.utc_now()
      )

      assert {:error, _} = All.force_return(product.id)
    end

    test "updates Product.used_by if it's valid" do
      product = insert(:product)
      user = insert(:user)

      product_use =
        insert(:product_use,
          product_id: product.id,
          user_id: user.id
        )

      assert All.get(product.id).used_by.id == product_use.id
      assert {:ok, %ProductUse{} = _} = All.force_return(product.id)
      assert All.get(product.id).used_by == nil

      updated_product_use =
        ProductUse
        |> where(product_id: ^product.id, user_id: ^user.id)
        |> Repo.one!()

      assert %ProductUse{ended_at: %NaiveDateTime{} = _} = updated_product_use
    end
  end
end

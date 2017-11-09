defmodule KuberaDB.User do
  @moduledoc """
  Ecto Schema representing users.
  """
  use Ecto.Schema
  import Ecto.{Changeset, Query}
  import KuberaDB.Validator
  alias Ecto.UUID
  alias KuberaDB.{Repo, AuthToken, Balance, User}

  @primary_key {:id, UUID, autogenerate: true}

  schema "user" do
    field :username, :string
    field :provider_user_id, :string
    field :metadata, :map
    has_many :balances, Balance
    has_many :auth_tokens, AuthToken

    timestamps()
  end

  @doc """
  Validates user data.
  """
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :provider_user_id, :metadata])
    |> validate_required([:username, :provider_user_id, :metadata])
    |> validate_immutable(:provider_user_id)
    |> unsafe_validate_unique(:username, Repo)
    |> unsafe_validate_unique(:provider_user_id, Repo)
    |> unique_constraint(:username)
    |> unique_constraint(:provider_user_id)
  end

  @doc """
  Retrieves a specific user.
  """
  def get(id) do
    User
    |> Repo.get(id)
    |> Repo.preload(:balances)
  end

  @doc """
  Retrieves a specific user from its provider_user_id.
  """
  def get_by_provider_user_id(provider_user_id) do
    Repo.get_by(User, provider_user_id: provider_user_id)
  end

  @doc """
  Creates a user.

  ## Examples

      iex> insert(%{field: value})
      {:ok, %User{}}

  Creates a user and their first balance.
  """
  def insert(attrs) do
    changeset = User.changeset(%User{}, attrs)

    case Repo.insert(changeset) do
      {:ok, user} ->
        {:ok, get(user.id)}
      result ->
        result
    end
  end

  @doc """
  Updates a user with the provided attributes.
  """
  def update(%User{} = user, attrs) do
    changeset = User.changeset(user, attrs)

    case Repo.update(changeset) do
      {:ok, user} ->
        {:ok, get(user.id)}
      result ->
        result
    end
  end

  @doc """
  Retrieve the main balance for a minted token. If not available,
  inserts a new one and return it.
  """
  def get_main_balance(user) do
    balances = Repo.all(from b in Balance, where: b.user_id == ^user.id)
    balance = List.first(balances)

    case balance do
      nil ->
        {:ok, balance} = insert_balance(user)
        balance
      balance ->
        balance
    end
  end

  defp insert_balance(%User{} = user) do
    %{user_id: user.id, metadata: nil} |> Balance.insert
  end
end

defmodule KuberaDB.MintedToken do
  @moduledoc """
  Ecto Schema representing minted tokens.
  """
  use Ecto.Schema
  import Ecto.{Changeset, Query}
  alias Ecto.UUID
  alias KuberaDB.{Repo, Account, Balance, MintedToken}

  @primary_key {:id, Ecto.UUID, autogenerate: true}

  schema "minted_token" do
    field :symbol, :string # "eur"
    field :iso_code, :string # "EUR"
    field :name, :string # "Euro"
    field :description, :string # Official currency of the European Union
    field :short_symbol, :string # "€"
    field :subunit, :string # "Cent"
    field :subunit_to_unit, KuberaDB.Types.Integer # 100
    field :symbol_first, :boolean # true
    field :html_entity, :string # "&#x20AC;"
    field :iso_numeric, :string # "978"
    field :smallest_denomination, :integer # 1
    field :locked, :boolean # false
    field :metadata, :map
    has_many :balances, Balance, foreign_key: :minted_token_id,
                                 references: :id
    belongs_to :account, Account, foreign_key: :account_id,
                                           references: :id,
                                           type: UUID
    timestamps()
  end

  @doc """
  Validates minted token data.

  ## Examples

      iex> changeset(%MintedToken{}, %{field: value})
      %MintedToken{}

  """
  def changeset(%MintedToken{} = minted_token, attrs) do
    minted_token
    |> cast(attrs, [
      :symbol, :iso_code, :name, :description, :short_symbol,
      :subunit, :subunit_to_unit, :symbol_first, :html_entity,
      :iso_numeric, :smallest_denomination, :locked, :account_id
    ])
    |> validate_required([
      :symbol, :name, :subunit_to_unit
    ])
    |> unique_constraint(:symbol)
    |> unique_constraint(:iso_code)
    |> unique_constraint(:name)
    |> unique_constraint(:short_symbol)
    |> unique_constraint(:iso_numeric)
    |> assoc_constraint(:account)
  end

  @doc """
  Returns all minted tokens in the system
  """
  def all do
    Repo.all(MintedToken)
  end

  @doc """
  Create a new minted token with the passed attributes.
  """
  def insert(attrs) do
    changeset = MintedToken.changeset(%MintedToken{}, attrs)

    case Repo.insert(changeset) do
      {:ok, minted_token} ->
        {:ok, get(minted_token.symbol)}
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Retrieve a minted token by symbol.
  """
  def get(symbol) do
    Repo.get_by(MintedToken, symbol: symbol)
  end

  @doc """
  Retrieve the main balance for a minted token. If not available,
  safely inserts a new one and return it.
  """
  def get_main_balance(minted_token) do
    balances = Repo.all(from b in Balance,
                        where: b.minted_token_id == ^minted_token.id)
    balance = List.first(balances)

    case balance do
      nil ->
        address = "master:#{minted_token.symbol}"
        {:ok, balance} = Balance.insert_without_conflict(address,
                                                         minted_token.id)
        balance
      balance ->
        balance
    end
  end
end

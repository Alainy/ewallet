defmodule Kubera.Transactions.BalanceLoaderTest do
  use ExUnit.Case
  import KuberaDB.Factory
  alias Kubera.{Transaction, Transactions.BalanceLoader}
  alias KuberaDB.{Repo, User, Account}
  alias Ecto.Adapters.SQL.Sandbox

  setup do
    :ok = Sandbox.checkout(Repo)
    {:ok, user} = User.insert(params_for(:user))
    {:ok, account} = Account.insert(params_for(:account))

    %{account: account, user: user}
  end

  describe "load/1" do
    test "loads the correct balances when credit", meta do
      {:ok, from, to} = BalanceLoader.load(meta.account, meta.user, Transaction.credit_type, nil)

      assert from == Account.get_primary_balance(meta.account)
      assert to == User.get_primary_balance(meta.user)
    end

    test "loads the correct balances when debit", meta do
      {:ok, from, to} = BalanceLoader.load(meta.account, meta.user, Transaction.debit_type, nil)

      assert from == User.get_primary_balance(meta.user)
      assert to == Account.get_primary_balance(meta.account)
    end

    test "loads the correct balances when debit and burn balance is specified", meta do
      {:ok, from, to} = BalanceLoader.load(meta.account, meta.user, Transaction.debit_type, "burn")

      assert from == User.get_primary_balance(meta.user)
      assert to == Account.get_default_burn_balance(meta.account)
    end

    test "returns an error if the given burn address is not found", meta do
      {res, code} = BalanceLoader.load(meta.account, meta.user, Transaction.debit_type, "burnz")

      assert res == :error
      assert code == :burn_balance_not_found
    end
  end
end

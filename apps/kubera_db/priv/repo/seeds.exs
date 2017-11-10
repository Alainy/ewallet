# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     KuberaDB.Repo.insert!(%KuberaDB.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

KuberaDB.MintedToken.insert(%{
  symbol: "OMG",
  name: "OmiseGO",
  subunit_to_unit: 10_000
})

KuberaDB.MintedToken.insert(%{
  symbol: "KNC",
  name: "Kyber",
  subunit_to_unit: 1000
})

KuberaDB.MintedToken.insert(%{
  symbol: "BTC",
  name: "Bitcoin",
  subunit_to_unit: 10_000
})

KuberaDB.MintedToken.insert(%{
  symbol: "MNT",
  name: "Mint",
  subunit_to_unit: 100
})

KuberaDB.MintedToken.insert(%{
  symbol: "ETH",
  name: "Ether",
  subunit_to_unit: 1_000_000_000_000_000_000
})

case KuberaDB.User.get_by_provider_user_id("123") do
  nil ->
    KuberaDB.User.insert(%{username: "john", provider_user_id: "123"})
  _ ->
    # credo:disable-for-next-line
    IO.inspect("User already in DB.")
end

# Use the following to create value out of nowhere.
#
# in IEX
# minted_token = KuberaDB.MintedToken.get("OMG")
# {:ok, genesis} = KuberaDB.Balance.genesis()
# data = KuberaMQ.Serializers.Transaction.serialize(%{
#   from: genesis,
#   to: KuberaDB.MintedToken.get_master_balance(minted_token),
#   minted_token: minted_token,
#   amount: 10000000,
#   metadata: %{}
# })
# KuberaMQ.Entry.genesis(data)

# This is the seeding script for access & secret keys.

seeds = [
  %{account: KuberaDB.Account.get_by_name("account01")},
  %{account: KuberaDB.Account.get_by_name("account02")},
  %{account: KuberaDB.Account.get_by_name("account03")},
  %{account: KuberaDB.Account.get_by_name("account04")},
]

KuberaDB.CLI.info("\nSeeding Access/Secret keys (always seed new ones)...")

Enum.each(seeds, fn(data) ->
  case KuberaDB.Key.insert(%{account_id: data.account.id}) do
    {:ok, key} ->
      KuberaDB.CLI.success("Access/Secret keys seeded for #{data.account.name}\n"
        <> "  Access key: #{key.access_key}\n"
        <> "  Secret key: #{key.secret_key}\n"
        <> "  Base64 (access:secret): " <> Base.encode64(key.access_key <> ":" <> key.secret_key))
    _ ->
      KuberaDB.CLI.error("Access/Secret Keys for #{data.account.name}"
        <> " could not be inserted due to error")
  end
end)

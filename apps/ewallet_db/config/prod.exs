use Mix.Config

config :ewallet_db, EWalletDB.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: {:system, "DATABASE_URL", "postgres://localhost/ewallet_prod"}

config :ewallet_db, base_url: {:system, "BASE_URL"}

# Cloak doesn't support {:system, ...}-style configuration so we
# have to set REPLACE_OS_VARS=yes when running the app release.
config :cloak, Salty.SecretBox.Cloak,
  tag: "SBX",
  default: true,
  keys: [
    %{
      tag: <<1>>,
      key: "${LOCAL_LEDGER_SECRET_KEY}",
      default: true
    }
  ]

config :ewallet_db, EWalletDB.Scheduler,
  global: true,
  jobs: [
    expire_requests: [
      schedule: "* * * * *",
      task: {EWalletDB.TransactionRequest, :expire_all, []},
      run_strategy: {Quantum.RunStrategy.Random, :cluster}
    ],
    expire_consumptions: [
      schedule: "* * * * *",
      task: {EWalletDB.TransactionConsumption, :expire_all, []},
      run_strategy: {Quantum.RunStrategy.Random, :cluster}
    ]
  ]

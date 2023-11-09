defmodule VoipstackClassicPanel.Repo do
  use Ecto.Repo,
    otp_app: :voipstack_classic_panel,
    adapter: Ecto.Adapters.SQLite3
end

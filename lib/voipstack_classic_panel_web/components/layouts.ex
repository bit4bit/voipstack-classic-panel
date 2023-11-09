defmodule VoipstackClassicPanelWeb.Layouts do
  @moduledoc false
  use VoipstackClassicPanelWeb, :html

  embed_templates "layouts/*"
  embed_sface "layouts/root.sface"
  embed_sface "layouts/app.sface"
end

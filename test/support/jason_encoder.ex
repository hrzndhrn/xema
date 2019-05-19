defimpl Jason.Encoder, for: URI do
  def encode(uri, _opts) do
    ~s|"#{URI.to_string(uri)}"|
  end
end

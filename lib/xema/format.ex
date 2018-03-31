defmodule Xema.Format do
  @moduledoc """
  TODO: add docs
  """

  @formats [:date_time, :email, :hostname, :ipv4, :ipv6, :uri]
  @type format :: :date_time | :email | :hostname | :ipv4 | :ipv6 | :uri

  defmacro __using__(_opts) do
    quote do
      alias Xema.Format
      require Format
    end
  end

  @spec supports(format) :: boolean
  defguard supports(format) when format in @formats

  @spec is?(format, any) :: boolean
  for fmt <- @formats do
    def is?(unquote(fmt), string) do
      unquote(:"is_#{Atom.to_string(fmt)}?")(string)
    end
  end

  @spec is_date_time?(any) :: boolean
  def is_date_time?(string) when is_binary(string) do
    regex = ~r/^
      (\d{4})-([01]\d)-([0-3]\d)T
      ([0-2]\d):([0-5]\d):([0-6]\d)(?:\.(\d+))?
      (?:Z|[-+](?:[01]\d|2[0-3]):(?:[0-5]\d|60))
    $/xi

    case Regex.run(regex, string) do
      nil ->
        false

      [_ | date] ->
        date
        |> Enum.map(&String.to_integer/1)
        |> is_date_time_valid?()
    end
  end

  def is_date_time?(_), do: false

  @spec is_date_time_valid?([integer]) :: boolean
  defp is_date_time_valid?([year, month, day, hour, min, sec]),
    do: is_date_time_valid?([year, month, day, hour, min, sec, 0])

  defp is_date_time_valid?([year, month, day, hour, min, sec, frac]) do
    case NaiveDateTime.new(year, month, day, hour, min, sec, frac) do
      {:ok, _} -> true
      _ -> false
    end
  end

  @spec is_hostname?(any) :: boolean
  def is_hostname?(string) when is_binary(string) do
    regex = ~r/
      (?(DEFINE)
        (?<sub_domain> (?:[a-z][-a-z\d]{0,62}) )
      )
      ^(?&sub_domain)(?:\.(?&sub_domain))*$
    /xi

    Regex.match?(regex, string)
  end

  def is_hostname?(_), do: false

  @spec is_ipv4?(any) :: boolean
  def is_ipv4?(string) when is_binary(string) do
    regex = ~r/
      (?(DEFINE)
        (?<dec_octet> (?:25[0-5]|2[0-4]\d|[0-1]?\d{1,2}) )
        (?<ipv4> (?:(?&dec_octet)(?:\.(?&dec_octet)){3}) )
      )
      ^(?&ipv4)$
    /x

    Regex.match?(regex, string)
  end

  def is_ipv4?(_), do: true

  @spec is_ipv6?(any) :: boolean
  def is_ipv6?(string) when is_binary(string) do
    regex = ~r/
      (?(DEFINE)
        (?<h16>(?:[[:xdigit:]]{1,4}) )
        (?<dec_octet> (?:25[0-5]|2[0-4]\d|[0-1]?\d{1,2}) )
        (?<ipv4> (?:(?&dec_octet)(?:\.(?&dec_octet)){3}) )
        (?<ls32> (?:(?:(?&h16):(?&h16))|(?&ipv4)) )
      )
      ^(?:
        (?:                                (?:(?&h16):){6}(?&ls32) )
        |(?:                             ::(?:(?&h16):){5}(?&ls32) )
        |(?:(?:                 (?&h16))?::(?:(?&h16):){4}(?&ls32) )
        |(?:(?:(?:(?&h16):){0,1}(?&h16))?::(?:(?&h16):){3}(?&ls32) )
        |(?:(?:(?:(?&h16):){0,2}(?&h16))?::(?:(?&h16):){2}(?&ls32) )
        |(?:(?:(?:(?&h16):){0,3}(?&h16))?::   (?&h16):    (?&ls32) )
        |(?:(?:(?:(?&h16):){0,4}(?&h16))?::               (?&ls32) )
        |(?:(?:(?:(?&h16):){0,5}(?&h16))?::                (?&h16) )
        |(?:(?:(?:(?&h16):){0,6}(?&h16))?::                        )
      )$
    /x

    Regex.match?(regex, string)
  end

  def is_ipv6?(_), do: true

  @spec is_email?(any) :: boolean
  def is_email?(string) when is_binary(string) do
    # The BNF rules from RFC 5322 transformed to PCRE by Nikita Popov and
    # described in the post
    # http://nikic.github.io/2012/06/15/The-true-power-of-regular-expressions.html.
    regex = ~r/
      (?(DEFINE)
        (?<addr_spec> (?&local_part) @ (?&domain) )
        (?<local_part> (?&dot_atom) | (?&quoted_string) | (?&obs_local_part) )
        (?<domain> (?&dot_atom) | (?&domain_literal) | (?&obs_domain) )
        (?<domain_literal> (?&CFWS)? \[ (?: (?&FWS)? (?&dtext) )* (?&FWS)? \] (?&CFWS)? )
        (?<dtext> [\x21-\x5a] | [\x5e-\x7e] | (?&obs_dtext) )
        (?<quoted_pair> \\ (?: (?&VCHAR) | (?&WSP) ) | (?&obs_qp) )
        (?<dot_atom> (?&CFWS)? (?&dot_atom_text) (?&CFWS)? )
        (?<dot_atom_text> (?&atext) (?: \. (?&atext) )* )
        (?<atext> [a-zA-Z0-9!#$%&'*+\/=?^_`{|}~-]+ )
        (?<atom> (?&CFWS)? (?&atext) (?&CFWS)? )
        (?<word> (?&atom) | (?&quoted_string) )
        (?<quoted_string> (?&CFWS)? " (?: (?&FWS)? (?&qcontent) )* (?&FWS)? " (?&CFWS)? )
        (?<qcontent> (?&qtext) | (?&quoted_pair) )
        (?<qtext> \x21 | [\x23-\x5b] | [\x5d-\x7e] | (?&obs_qtext) )
        # comments and whitespace
        (?<FWS> (?: (?&WSP)* \r\n )? (?&WSP)+ | (?&obs_FWS) )
        (?<CFWS> (?: (?&FWS)? (?&comment) )+ (?&FWS)? | (?&FWS) )
        (?<comment> \( (?: (?&FWS)? (?&ccontent) )* (?&FWS)? \) )
        (?<ccontent> (?&ctext) | (?&quoted_pair) | (?&comment) )
        (?<ctext> [\x21-\x27] | [\x2a-\x5b] | [\x5d-\x7e] | (?&obs_ctext) )
        # obsolete tokens
        (?<obs_domain> (?&atom) (?: \. (?&atom) )* )
        (?<obs_local_part> (?&word) (?: \. (?&word) )* )
        (?<obs_dtext> (?&obs_NO_WS_CTL) | (?&quoted_pair) )
        (?<obs_qp> \\ (?: \x00 | (?&obs_NO_WS_CTL) | \n | \r ) )
        (?<obs_FWS> (?&WSP)+ (?: \r\n (?&WSP)+ )* )
        (?<obs_ctext> (?&obs_NO_WS_CTL) )
        (?<obs_qtext> (?&obs_NO_WS_CTL) )
        (?<obs_NO_WS_CTL> [\x01-\x08] | \x0b | \x0c | [\x0e-\x1f] | \x7f )
        # character class definitions
        (?<VCHAR> [\x21-\x7E] )
        (?<WSP> [ \t] )
      )
      ^(?&addr_spec)$
    /x

    Regex.match?(regex, string)
  end

  @spec is_uri?(any) :: boolean
  def is_uri?(string) when is_binary(string), do: is_uri?(URI.parse(string))

  def is_uri?(%URI{scheme: nil}), do: false

  def is_uri?(%URI{scheme: "mailto", path: path}), do: is_email?(path)

  # credo:disable-for-next-line
  def is_uri?(%URI{} = uri) do
    (is_nil(uri.host) || is_host?(uri.host)) &&
      (is_nil(uri.userinfo) || is_uri_userinfo?(uri.userinfo)) &&
      (is_nil(uri.path) || is_uri_path?(uri.path)) &&
      (is_nil(uri.query) || is_uri_query?(uri.query)) &&
      (is_nil(uri.fragment) || is_uri_fragment?(uri.fragment))
  end

  @spec is_host?(any) :: boolean
  def is_host?(string) when is_binary(string) do
    is_ipv4?(string) || is_ipv6?(string) || is_hostname?(string)
  end

  def is_host?(_), do: false

  @spec is_uri_userinfo?(any) :: boolean
  def is_uri_userinfo?(string) when is_binary(string) do
    regex = ~r/
      (?(DEFINE)
        (?<pct_encoded> %[[:xdigit:]][[:xdigit:]] )
        (?<chars>  [-._~[:alnum:]!$&'()*+,;=:] )
      )
      ^(?:(?&chars)|(?&pct_encoded))*$
    /x

    Regex.match?(regex, string)
  end

  def is_uri_userinfo?(_), do: false

  @spec is_uri_path?(any) :: boolean
  def is_uri_path?(string) when is_binary(string) do
    regex = ~r/
      (?(DEFINE)
        (?<unreserved>  [-._~[:alnum:]] )
        (?<sub_delims>  [!$&'()*+,;=] )
        (?<pct_encoded> %[[:xdigit:]][[:xdigit:]] )
        (?<pchar>       @|(?&unreserved)|(?&pct_encoded)|(?&sub_delims) )
        (?<seg_nz_nc>   (?&pchar)+ )
        (?<seg_nz>      (?::|(?&pchar))+ )
        (?<seg>         (?::|(?&pchar))* )
        (?<rootless>    (?&seg_nz)(?:\/(?&seg))* )
        (?<noscheme>    (?&seg_nz_nc)(?:\/(?&seg)*) )
        (?<absolute>    \/(?:(?&seg_nz)(?:\/(?&seg))*)? )
        (?<abempty>     (?:\/(?&seg))* )
      )
      ^(?:(?&rootless)|(?&noscheme)|(?&absolute)|(?&abempty))$
    /x

    Regex.match?(regex, string)
  end

  def is_uri_path?(_), do: false

  @spec is_uri_query?(any) :: boolean
  def is_uri_query?(string) when is_binary(string) do
    regex = ~r/
      (?(DEFINE)
        (?<pct_encoded> %[[:xdigit:]][[:xdigit:]] )
        (?<chars>  [-._~[:alnum:]!$&'()*+,;=:@] )
        (?<pchar> (?:(?&chars)|(?&pct_encoded)) )
      )
      ^(?:(?&pchar)|[\/?])*$
    /x

    Regex.match?(regex, string)
  end

  def is_uri_query?(_), do: false

  @spec is_uri_fragment?(any) :: boolean
  def is_uri_fragment?(string) when is_binary(string), do: is_uri_query?(string)

  def is_uri_fragment?(_), do: false
end

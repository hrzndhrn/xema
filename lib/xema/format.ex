defmodule Xema.Format do
  @moduledoc """
  This module contains semantic validators for strings.
  """

  @formats [
    :date_time,
    :email,
    :hostname,
    :ipv4,
    :ipv6,
    :uri,
    :uri_fragment,
    :uri_path,
    :uri_query,
    :uri_userinfo
  ]
  @typedoc "The list of supported validators."
  @type format ::
          :date_time
          | :email
          | :hostname
          | :ipv4
          | :ipv6
          | :uri
          | :uri_fragment
          | :uri_path
          | :uri_query
          | :uri_userinfo

  defmacro __using__(_opts) do
    quote do
      alias Xema.Format
      require Format
    end
  end

  @doc """
  This function returns `true` for a valid format type, `false` otherwise.
  This function can be used in guards.
  """
  defguard supports(format) when format in @formats

  @doc """
  Checks if the value matches the given type.
  """
  @spec is?(format, any) :: boolean
  for fmt <- @formats do
    def is?(unquote(fmt), string) do
      unquote(:"is_#{Atom.to_string(fmt)}?")(string)
    end
  end

  @doc """
  Checks if the value is a valid date time.

  This function returns `true` if the value is a string and is formatted as
  defined by [RFC 3339](https://tools.ietf.org/html/rfc3339), `false` otherwise.
  """
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

  @doc """
  Checks if the value is a valid email.

  This function returns `true` if the value is a string and is formatted as
  defined by [RFC 5322](https://tools.ietf.org/html/rfc5322), `false` otherwise.
  """
  @spec is_email?(any) :: boolean
  def is_email?(string) when is_binary(string) do
    # The BNF rules from RFC 5322 transformed to PCRE by Nikita Popov and
    # described in the post
    # http://nikic.github.io/2012/06/15/The-true-power-of-regular-expressions.html.
    # credo:disable-for-previous-line
    regex = ~r/
      (?(DEFINE)
        (?<addr_spec> (?&local_part) @ (?&domain) )
        (?<local_part> (?&dot_atom) | (?&quoted_string) | (?&obs_local_part) )
        (?<domain> (?&dot_atom) | (?&domain_literal) | (?&obs_domain) )
        (?<domain_literal>
          (?&CFWS)? \[ (?: (?&FWS)? (?&dtext) )* (?&FWS)? \] (?&CFWS)? )
        (?<dtext> [\x21-\x5a] | [\x5e-\x7e] | (?&obs_dtext) )
        (?<quoted_pair> \\ (?: (?&VCHAR) | (?&WSP) ) | (?&obs_qp) )
        (?<dot_atom> (?&CFWS)? (?&dot_atom_text) (?&CFWS)? )
        (?<dot_atom_text> (?&atext) (?: \. (?&atext) )* )
        (?<atext> [a-zA-Z0-9!#$%&'*+\/=?^_`{|}~-]+ )
        (?<atom> (?&CFWS)? (?&atext) (?&CFWS)? )
        (?<word> (?&atom) | (?&quoted_string) )
        (?<quoted_string>
          (?&CFWS)? " (?: (?&FWS)? (?&qcontent) )* (?&FWS)? " (?&CFWS)? )
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

  @doc """
  Checks if the value is a valid host.

  This function returns `true` if the value is a valid IPv4 address, IPv6
  address, or a valid hostname, `false` otherwise.
  """
  @spec is_host?(any) :: boolean
  def is_host?(string) when is_binary(string) do
    is_ipv4?(string) || is_ipv6?(string) || is_hostname?(string)
  end

  def is_host?(_), do: false

  @doc """
  Checks if the value is a valid hostname.

  This function returns `true` if the value is a string and is formatted as
  defined by [RFC 1034](https://tools.ietf.org/html/rfc1034), `false` otherwise.
  """
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

  @doc """
  Checks if the value is a valid IPv4 address.

  This function returns `true` if the value is a string and is formatted as
  defined by [RFC 2673](https://tools.ietf.org/html/rfc2673), `false` otherwise.
  """
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

  @doc """
  Checks if the value is a valid IPv6 address.

  This function returns `true` if the value is a string and is formatted as
  defined by [RFC 2373](https://tools.ietf.org/html/rfc2373), `false` otherwise.
  """
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

  @doc """
  Checks if the value is a valid uri.

  This function returns `true` if the value is a string and is formatted as
  defined by [RFC 3986](https://tools.ietf.org/html/rfc3986), `false` otherwise.

  The following are two example URIs and their component parts:
  ```code
                        hierarchical part
                              |
          |-----------------------------------------|
                      authority               path
                          |                    |
          |-------------------------------||--------|
    abc://username:password@example.com:123/path/data?key=value#fragid1
    |-|   |---------------| |---------| |-|           |-------| |-----|
     |            |              |       |                |        |
  scheme  user information     host     port            query   fragment

    urn:example:mammal:monotreme:echidna
    |-| |------------------------------|
     |                 |
  scheme              path
  ```
  Wikipedia: [Uniform Resource Identifier](https://en.wikipedia.org/wiki/Uniform_Resource_Identifier)
  """
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

  @doc """
  Checks if the value is a valid uri user info.

  See also `Xema.Format.is_uri?/1`.
  """
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

  @doc """
  Checks if the value is a valid uri path.

  See also `Xema.Format.is_uri?/1`.
  """
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

  @doc """
  Checks if the value is a valid uri qurey.

  See also `Xema.Format.is_uri?/1`.
  """
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

  @doc """
  Checks if the value is a valid uri fragment.

  See also `Xema.Format.is_uri?/1`.
  """
  @spec is_uri_fragment?(any) :: boolean
  def is_uri_fragment?(string) when is_binary(string), do: is_uri_query?(string)

  def is_uri_fragment?(_), do: false
end

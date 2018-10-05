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
    :json_pointer,
    :relative_json_pointer,
    :time,
    :uri,
    :uri_fragment,
    :uri_path,
    :uri_query,
    :uri_reference,
    :uri_template,
    :uri_userinfo
  ]

  @typedoc "The list of supported validators."
  @type format ::
          :date_time
          | :email
          | :hostname
          | :ipv4
          | :ipv6
          | :json_pointer
          | :relative_json_pointer
          | :time
          | :uri
          | :uri_fragment
          | :uri_path
          | :uri_query
          | :uri_reference
          | :uri_template
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
      unquote(:"#{Atom.to_string(fmt)}?")(string)
    end
  end

  #
  # Date-Time
  #

  @doc """
  Checks if the value is a valid date time.

  This function returns `true` if the value is a string and is formatted as
  defined by [RFC 3339](https://tools.ietf.org/html/rfc3339), `false` otherwise.
  """
  @spec date_time?(any) :: boolean
  def date_time?(string) when is_binary(string) do
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
        |> date_time_valid?()
    end
  end

  def date_time?(_), do: false

  @spec date_time_valid?([integer]) :: boolean
  defp date_time_valid?([year, month, day, hour, min, sec]),
    do: date_time_valid?([year, month, day, hour, min, sec, 0])

  defp date_time_valid?([year, month, day, hour, min, sec, frac]) do
    case NaiveDateTime.new(year, month, day, hour, min, sec, frac) do
      {:ok, _} -> true
      _ -> false
    end
  end

  #
  # Time
  #

  @doc """
  Checks if the value is a valid time.

  This function returns `true` if the value is a string and is formatted as
  defined by [RFC 3339](https://tools.ietf.org/html/rfc3339), `false` otherwise.
  """
  @spec time?(any) :: boolean
  def time?(string) when is_binary(string),
    do: date_time?("2000-01-01T#{string}")

  #
  # Email
  #

  @doc """
  Checks if the value is a valid email.

  This function returns `true` if the value is a string and is formatted as
  defined by [RFC 5322](https://tools.ietf.org/html/rfc5322), `false` otherwise.
  """
  @spec email?(any) :: boolean
  def email?(string) when is_binary(string) do
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
  @spec host?(any) :: boolean
  def host?(string) when is_binary(string) do
    ipv4?(string) || ipv6?(string) || hostname?(string)
  end

  def host?(_), do: false

  @doc """
  Checks if the value is a valid hostname.

  This function returns `true` if the value is a string and is formatted as
  defined by [RFC 1034](https://tools.ietf.org/html/rfc1034), `false` otherwise.
  """
  @spec hostname?(any) :: boolean
  def hostname?(string) when is_binary(string) do
    regex = ~r/
      (?(DEFINE)
        (?<sub_domain> (?:[a-z][-a-z\d]{0,62}) )
      )
      ^(?&sub_domain)(?:\.(?&sub_domain))*$
    /xi

    Regex.match?(regex, string)
  end

  def hostname?(_), do: false

  @doc """
  Checks if the value is a valid IPv4 address.

  This function returns `true` if the value is a string and is formatted as
  defined by [RFC 2673](https://tools.ietf.org/html/rfc2673), `false` otherwise.
  """
  @spec ipv4?(any) :: boolean
  def ipv4?(string) when is_binary(string) do
    regex = ~r/
      (?(DEFINE)
        (?<dec_octet> (?:25[0-5]|2[0-4]\d|[0-1]?\d{1,2}) )
        (?<ipv4> (?:(?&dec_octet)(?:\.(?&dec_octet)){3}) )
      )
      ^(?&ipv4)$
    /x

    Regex.match?(regex, string)
  end

  def ipv4?(_), do: true

  @doc """
  Checks if the value is a valid IPv6 address.

  This function returns `true` if the value is a string and is formatted as
  defined by [RFC 2373](https://tools.ietf.org/html/rfc2373), `false` otherwise.
  """
  @spec ipv6?(any) :: boolean
  def ipv6?(string) when is_binary(string) do
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

  def ipv6?(_), do: true

  #
  # JSON Pointer
  #

  @json_pointer ~r/
      (?(DEFINE)
        (?<json_pointer> (?: \/ (?&reference_token))*      )
        (?<reference_token> (?:(?&unescaped)|(?&escaped))* )
        (?<unescaped> [^~\/]                               )
        (?<escaped> ~[01]                                  )
      )
      ^(?&json_pointer)$
    /x

  @doc """
  Checks if the value is a valid JSON poiner.
  """
  @spec json_pointer?(any) :: boolean
  def json_pointer?(string) when is_binary(string),
    do: Regex.match?(@json_pointer, string)

  def json_pointer?(_), do: false

  #
  # Relative JSON Pointer
  #

  @doc """
  Checks if the value is a valid JSON poiner.
  """
  @spec relative_json_pointer?(any) :: boolean
  def relative_json_pointer?(string) when is_binary(string) do
    with false <- Regex.match?(~r/^\d#$/, string),
         false <- Regex.match?(~r/^\d$/, string),
         false <- do_relative_json_pointer?(string) do
      false
    end
  end

  def relative_json_pointer?(_), do: false

  def do_relative_json_pointer?(string) do
    case String.split(string, "/", parts: 2) do
      [pre, pointer] ->
        Regex.match?(~r/^\d+$/, pre) && json_pointer?("/#{pointer}")

      _ ->
        false
    end
  end

  #
  # URI
  #

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
  @spec uri?(any) :: boolean
  def uri?(string), do: do_uri?(string, :uri)

  @doc """
  Checks if the value is a valid uri reference.
  """
  @spec uri_reference?(any) :: boolean
  def uri_reference?(string), do: do_uri?(string, :uri_reference)

  @doc """
  Checks if the value is a valid uri template.
  """
  def uri_template?(string), do: do_uri?(string, :uri_template)

  # do_uri?/2 handels:
  #   * uri?
  #   * uri_reference?
  #   * uri_template?

  defp do_uri?(string, type) when is_binary(string),
    do: do_uri?(URI.parse(string), type)

  defp do_uri?(%URI{scheme: nil}, :uri), do: false

  defp do_uri?(%URI{scheme: "mailto", path: path}, _), do: email?(path)

  # credo:disable-for-next-line
  defp do_uri?(%URI{} = uri, :uri_template) do
    (is_nil(uri.host) || host?(uri.host)) &&
      (is_nil(uri.userinfo) || uri_userinfo?(uri.userinfo)) &&
      (is_nil(uri.path) || uri_template_path?(uri.path))
  end

  # credo:disable-for-next-line
  defp do_uri?(%URI{} = uri, _) do
    (is_nil(uri.host) || host?(uri.host)) &&
      (is_nil(uri.userinfo) || uri_userinfo?(uri.userinfo)) &&
      (is_nil(uri.path) || uri_path?(uri.path)) &&
      (is_nil(uri.query) || uri_query?(uri.query)) &&
      (is_nil(uri.fragment) || uri_fragment?(uri.fragment))
  end

  defp do_uri?(_, _), do: false

  @doc """
  Checks if the value is a valid uri user info.

  See also `Xema.Format.uri?/1`.
  """
  @spec uri_userinfo?(any) :: boolean
  def uri_userinfo?(string) when is_binary(string) do
    regex = ~r/
      (?(DEFINE)
        (?<pct_encoded> %[[:xdigit:]][[:xdigit:]] )
        (?<chars>  [-._~[:alnum:]!$&'()*+,;=:] )
      )
      ^(?:(?&chars)|(?&pct_encoded))*$
    /x

    Regex.match?(regex, string)
  end

  def uri_userinfo?(_), do: false

  @doc """
  Checks if the value is a valid uri path.

  See also `Xema.Format.uri?/1`.
  """
  @spec uri_path?(any) :: boolean
  def uri_path?(string) when is_binary(string) do
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

  def uri_path?(_), do: false

  @doc """
  Checks if the value is a valid uri path.
  """
  @spec uri_template_path?(any) :: boolean
  def uri_template_path?(string) when is_binary(string) do
    regex = ~r/
      (?(DEFINE)
        (?<unreserved>  [-._~[:alnum:]] )
        (?<sub_delims>  [!$&'()*+,;=] )
        (?<pct_encoded> %[[:xdigit:]][[:xdigit:]] )
        (?<pchar>       @|(?&unreserved)|(?&pct_encoded)|(?&sub_delims)
                        |(?&template) )
        (?<seg_nz_nc>   (?&pchar)+ )
        (?<seg_nz>      (?::|(?&pchar))+ )
        (?<seg>         (?::|(?&pchar))* )
        (?<rootless>    (?&seg_nz)(?:\/(?&seg))* )
        (?<noscheme>    (?&seg_nz_nc)(?:\/(?&seg)*) )
        (?<absolute>    \/(?:(?&seg_nz)(?:\/(?&seg))*)? )
        (?<abempty>     (?:\/(?&seg))* )
        (?<tmpl_char>   ([_[:alnum:]])|(?&pct_encoded) )
        (?<operator>    [+#.,;?&=@!|\/] )
        (?<modifier>    (?&prefix)|\* )
        (?<prefix>      :\d+ )
        (?<var>         (?&tmpl_char)+(?&modifier)? )
        (?<var_list>    (?&var)(?:,(?&var))* )
        (?<template>    (?:\{)(?&operator)?(?&var_list)\} )
      )
      ^(?:(?&rootless)|(?&noscheme)|(?&absolute)|(?&abempty))$
    /x

    Regex.match?(regex, string)
  end

  def uri_template_path?(_), do: false

  @doc """
  Checks if the value is a valid uri qurey.

  See also `Xema.Format.uri?/1`.
  """
  @spec uri_query?(any) :: boolean
  def uri_query?(string) when is_binary(string) do
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

  def uri_query?(_), do: false

  @doc """
  Checks if the value is a valid uri fragment.

  See also `Xema.Format.uri?/1`.
  """
  @spec uri_fragment?(any) :: boolean
  def uri_fragment?(string) when is_binary(string), do: uri_query?(string)

  def uri_fragment?(_), do: false
end

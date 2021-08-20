defmodule Xema.Format do
  @moduledoc """
  This module contains semantic validators for strings.
  """

  @formats [
    :date,
    :date_time,
    :email,
    :hostname,
    :ipv4,
    :ipv6,
    :json_pointer,
    :regex,
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
          :date
          | :date_time
          | :email
          | :hostname
          | :ipv4
          | :ipv6
          | :json_pointer
          | :regex
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
  Returns `true` for a valid format type, `false` otherwise.  This macro can be
  used in guards.
  """
  defguard supports(format) when format in @formats

  @doc """
  Checks if the value matches the given type. The function expected a available
  `format` and a `string` to check. Returns `true` for a valid `string`, `false`
  otherwise.

  ## Examples

      iex> Xema.Format.is?(:email, "foo@bar.net")
      true
      iex> Xema.Format.is?(:email, "foo.bar.net")
      false
  """
  @spec is?(format, String.t()) :: boolean
  for fmt <- @formats do
    def is?(unquote(fmt), string) when is_binary(string) do
      unquote(:"#{Atom.to_string(fmt)}?")(string)
    end
  end

  #
  # Date-Time
  #

  @doc """
  Checks if the `string` is a valid date time representation.

  This function returns `true` if the value is a `string` and is formatted as
  defined by [RFC 3339](https://tools.ietf.org/html/rfc3339), `false` otherwise.
  """
  @date_time ~r/^
      (\d{4})-([01]\d)-([0-3]\d)T
      ([0-2]\d):([0-5]\d):([0-6]\d)(?:\.(\d+))?
      (?:Z|[-+](?:[01]\d|2[0-3]):(?:[0-5]\d|60))
    $/xi
  @spec date_time?(String.t()) :: boolean
  def date_time?(string) when is_binary(string) do
    case Regex.run(@date_time, string) do
      nil ->
        false

      [_ | date] ->
        date
        |> Enum.map(&String.to_integer/1)
        |> date_time_valid?()
    end
  end

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
  Checks if the `string` is a valid time representation.

  This function returns `true` if the value is a string and is formatted as
  defined by [RFC 3339](https://tools.ietf.org/html/rfc3339), `false` otherwise.
  """
  @spec time?(String.t()) :: boolean
  def time?(string) when is_binary(string),
    do: date_time?("2000-01-01T#{string}")

  #
  # Date
  #

  @doc """
  Checks if the `string` is a valid date representation.

  This function returns `true` if the value is a string and is formatted as
  defined by [RFC 3339](https://tools.ietf.org/html/rfc3339), `false` otherwise.
  """
  @spec date?(String.t()) :: boolean
  def date?(string) when is_binary(string),
    do: date_time?("#{string}T00:00:00.0Z")

  #
  # Email
  #

  @doc """
  Checks if the `string` is a valid email representation.

  This function returns `true` if the value is a string and is formatted as
  defined by [RFC 5322](https://tools.ietf.org/html/rfc5322), `false` otherwise.

  The regular expression was taken from
  [https://emailregex.com/](https://emailregex.com/).

  ## Examples

      iex> import Xema.Format
      iex>
      iex> email?("marin.musterman@germany.net")
      true
      iex> email?("Otto.Normalverbraucher")
      false
      iex> email?("Otto.Normal@Verbraucher.NET")
      true
  """
  # credo:disable-for-previous-line
  @email ~r<
    (?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*
    |"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\
    [\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+
    [a-z0-9](?:[a-z0-9-]*[a-z0-9])?|
    \[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)
    \.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:
    (?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\
    [\x01-\x09\x0b\x0c\x0e-\x7f])+)\])
  >ix
  @spec email?(String.t()) :: boolean
  def email?(string) when is_binary(string) do
    !Regex.match?(~r/^\./, string) &&
      !Regex.match?(~r/\.\./, string) &&
      Regex.match?(@email, string)
  end

  @doc """
  Checks if the `string` is a valid host representation.

  This function returns `true` if the value is a valid IPv4 address, IPv6
  address, or a valid hostname, `false` otherwise.

  ## Examples

      iex> import Xema.Format
      iex>
      iex> host?("127.0.0.1")
      true
      iex> host?("localhost")
      true
      iex> host?("elixirforum.com")
      true
      iex> host?("go go go")
      false
  """
  @spec host?(String.t()) :: boolean
  def host?(string) when is_binary(string),
    do: ipv4?(string) || ipv6?(string) || hostname?(string)

  @doc """
  Checks if the `string` is a valid hostname representation.

  This function returns `true` if the value is a string and is formatted as
  defined by [RFC 1034](https://tools.ietf.org/html/rfc1034), `false` otherwise.
  """
  @hostname ~r/
      (?(DEFINE)
        (?<sub_domain> (?:[a-z\d][-a-z\d]{0,62}) )
      )
      ^(?&sub_domain)(?:\.(?&sub_domain))*$
    /xi
  @spec hostname?(String.t()) :: boolean
  def hostname?(string) when is_binary(string),
    do: !Regex.match?(~r/-$/, string) && Regex.match?(@hostname, string)

  @doc """
  Checks if the `string` is a valid IPv4 address representation.

  This function returns `true` if the value is a string and is formatted as
  defined by [RFC 2673](https://tools.ietf.org/html/rfc2673), `false` otherwise.
  """
  @ipv4 ~r/
      (?(DEFINE)
        (?<dec_octet> (?:25[0-5]|2[0-4]\d|[0-1]?\d{1,2}) )
        (?<ipv4> (?:(?&dec_octet)(?:\.(?&dec_octet)){3}) )
      )
      ^(?&ipv4)$
    /x
  @spec ipv4?(String.t()) :: boolean
  def ipv4?(string) when is_binary(string), do: Regex.match?(@ipv4, string)

  @doc """
  Checks if the `string` is a valid IPv6 address representation.

  This function returns `true` if the value is a string and is formatted as
  defined by [RFC 2373](https://tools.ietf.org/html/rfc2373), `false` otherwise.
  """
  @ipv6 ~r/
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
  @spec ipv6?(String.t()) :: boolean
  def ipv6?(string) when is_binary(string), do: Regex.match?(@ipv6, string)

  @doc """
  Checks if the `string` is a valid JSON pointer representation.
  """
  @json_pointer ~r/
      (?(DEFINE)
        (?<json_pointer> (?: \/ (?&reference_token))*      )
        (?<reference_token> (?:(?&unescaped)|(?&escaped))* )
        (?<unescaped> [^~\/]                               )
        (?<escaped> ~[01]                                  )
      )
      ^(?&json_pointer)$
    /x
  @spec json_pointer?(String.t()) :: boolean
  def json_pointer?(string) when is_binary(string),
    do: Regex.match?(@json_pointer, string)

  @doc """
  Checks if the `string` is a valid JSON pointer representation.
  """
  @spec relative_json_pointer?(String.t()) :: boolean
  def relative_json_pointer?(string) when is_binary(string) do
    with false <- Regex.match?(~r/^\d#$/, string),
         false <- Regex.match?(~r/^\d$/, string),
         false <- do_relative_json_pointer?(string) do
      false
    end
  end

  defp do_relative_json_pointer?(string) do
    case String.split(string, "/", parts: 2) do
      [pre, pointer] ->
        Regex.match?(~r/^\d+$/, pre) && json_pointer?("/#{pointer}")

      _ ->
        false
    end
  end

  @doc """
  Return true if `string` contains a regular expression.
  """
  @spec regex?(String.t()) :: boolean
  def regex?(string) do
    case Regex.compile(string) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end

  #
  # URI
  #

  @doc """
  Checks if the `string` is a valid URI representation.

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
  @spec uri?(String.t()) :: boolean
  def uri?(string), do: do_uri?(string, :uri)

  @doc """
  Checks if the `string` is a valid URI reference representation.
  """
  @spec uri_reference?(String.t()) :: boolean
  def uri_reference?(string), do: do_uri?(string, :uri_reference)

  @doc """
  Checks if the `string` is a valid URI template representation.
  """
  def uri_template?(string), do: do_uri?(string, :uri_template)

  # do_uri?/2 handles:
  #   * uri?
  #   * uri_reference?
  #   * uri_template?

  defp do_uri?(string, type) when is_binary(string),
    do: do_uri?(URI.parse(string), type)

  defp do_uri?(%URI{scheme: nil}, :uri), do: false

  defp do_uri?(%URI{scheme: "mailto", path: path}, _), do: email?(path)

  # credo:disable-for-next-line
  defp do_uri?(%URI{} = uri, :uri_template) do
    (is_nil(uri.host) || uri_host?(uri.host)) &&
      (is_nil(uri.userinfo) || uri_userinfo?(uri.userinfo)) &&
      (is_nil(uri.path) || uri_template_path?(uri.path))
  end

  # credo:disable-for-next-line
  defp do_uri?(%URI{} = uri, _) do
    (is_nil(uri.host) || uri_host?(uri.host)) &&
      (is_nil(uri.userinfo) || uri_userinfo?(uri.userinfo)) &&
      (is_nil(uri.path) || uri_path?(uri.path)) &&
      (is_nil(uri.query) || uri_query?(uri.query)) &&
      (is_nil(uri.fragment) || uri_fragment?(uri.fragment))
  end

  defp do_uri?(_, _), do: false

  @doc """
  Checks if the `string` is a valid URI user info.

  See also `Xema.Format.uri?/1`.
  """
  @uri_userinfo ~r/
      (?(DEFINE)
        (?<pct_encoded> %[[:xdigit:]][[:xdigit:]] )
        (?<chars>  [-._~[:alnum:]!$&'()*+,;=:] )
      )
      ^(?:(?&chars)|(?&pct_encoded))*$
    /x
  @spec uri_userinfo?(String.t()) :: boolean
  def uri_userinfo?(string) when is_binary(string),
    do: Regex.match?(@uri_userinfo, string)

  @doc """
  Checks if the `string` is a valid URI path representation.

  See also `Xema.Format.uri?/1`.
  """
  @uri_path ~r/
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
  @spec uri_path?(String.t()) :: boolean
  def uri_path?(string) when is_binary(string),
    do: Regex.match?(@uri_path, string)

  @doc """
  Checks if the `string` is a valid URI template path representation.
  """
  @uri_template_path ~r/
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
  @spec uri_template_path?(String.t()) :: boolean
  def uri_template_path?(string) when is_binary(string),
    do: Regex.match?(@uri_template_path, string)

  @doc """
  Checks if the `string` is a valid URI query representation.
  """
  @uri_query ~r/
      (?(DEFINE)
        (?<pct_encoded> %[[:xdigit:]][[:xdigit:]] )
        (?<chars>  [-._~[:alnum:]!$&'()*+,;=:@] )
        (?<pchar> (?:(?&chars)|(?&pct_encoded)) )
      )
      ^(?:(?&pchar)|[\/?])*$
    /x
  @spec uri_query?(String.t()) :: boolean
  def uri_query?(string) when is_binary(string),
    do: Regex.match?(@uri_query, string)

  @doc """
  Checks if the `string` is a valid URI fragment representation.
  """
  @spec uri_fragment?(String.t()) :: boolean
  def uri_fragment?(string) when is_binary(string), do: uri_query?(string)

  # The same as, `hostname?` with the exception that sub-domains are not restricted
  # to 63 octets.
  @uri_hostname ~r/
      (?(DEFINE)
        (?<sub_domain> (?:[a-z\d][-a-z\d]*) )
      )
      ^(?&sub_domain)(?:\.(?&sub_domain))*$
    /xi
  defp uri_hostname?(string) when is_binary(string),
    do: !Regex.match?(~r/-$/, string) && Regex.match?(@uri_hostname, string)

  # The same as, `host?` with the exception of using `uri_hostname?` instead of
  # `hostname?`.
  defp uri_host?(string) when is_binary(string),
    do: ipv4?(string) || ipv6?(string) || uri_hostname?(string)
end

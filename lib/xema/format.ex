defmodule Xema.Format do
  @moduledoc false

  @formats [:date_time, :email, :hostname, :ipv4, :ipv6, :uri]

  defmacro __using__(_opts) do
    quote do
      alias Xema.Format
      require Format
    end
  end

  defguard available?(fmt) when fmt in @formats

  @spec is?(atom, any) :: boolean
  for fmt <- @formats do
    def is?(unquote(fmt), str) do
      unquote(:"is_#{Atom.to_string(fmt)}?")(str)
    end
  end

  @spec is_date_time?(any) :: boolean
  def is_date_time?(str) when is_binary(str) do
    regex = ~r/^
      (\d{4})-([01]\d)-([0-3]\d)T
      ([0-2]\d):([0-5]\d):([0-6]\d)(?:\.(\d+))?
      (?:Z|[-+](?:[01]\d|2[0-3]):(?:[0-5]\d|60))
    $/xi

    case Regex.run(regex, str) do
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
  def is_hostname?(str) when is_binary(str) do
    regex = ~r/
      (?(DEFINE)
        (?<sub_domain> (?:[a-z][-a-z\d]{0,62}) )
      )
      ^(?&sub_domain)(?:\.(?&sub_domain))*$
    /xi

    Regex.match?(regex, str)
  end

  def is_hostname?(_), do: false

  @spec is_ipv4?(any) :: boolean
  def is_ipv4?(str) when is_binary(str) do
    regex = ~r/
      (?(DEFINE)
        (?<dec_octet> (?:25[0-5]|2[0-4]\d|[0-1]?\d{1,2}) )
        (?<ipv4> (?:(?&dec_octet)(?:\.(?&dec_octet)){3}) )
      )
      ^(?&ipv4)$
    /x

    Regex.match?(regex, str)
  end

  def is_ipv4?(_), do: true

  @spec is_ipv6?(any) :: boolean
  def is_ipv6?(str) when is_binary(str) do
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

    Regex.match?(regex, str)
  end

  def is_ipv6?(_), do: true

  @spec is_email?(any) :: boolean
  def is_email?(str) when is_binary(str) do
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

    Regex.match?(regex, str)
  end

  @spec is_uri?(any) :: boolean
  def is_uri?(str) when is_binary(str), do: is_uri?(URI.parse(str))

  def is_uri?(%URI{scheme: nil}), do: false

  def is_uri?(%URI{scheme: "mailto", path: path}), do: is_email?(path)

  def is_uri?(%URI{} = uri) do
    (is_nil(uri.host) || is_host?(uri.host)) &&
      (is_nil(uri.path) || is_uri_path?(uri.path)) &&
      (is_nil(uri.query) || is_uri_query?(uri.query)) &&
      (is_nil(uri.fragment) || is_uri_fragment?(uri.fragment))
  end

  @spec is_host?(any) :: boolean
  def is_host?(str) when is_binary(str) do
    is_ipv4?(str) || is_ipv6?(str) || is_hostname?(str)
  end

  def is_host?(_), do: false

  @spec is_uri_path?(any) :: boolean
  def is_uri_path?(str) when is_binary(str) do
    # ; RFC-3086 - Uniform Resource Identifier (URI): Generic Syntax
    #
    # path          = path-abempty    ; begins with "/" or is empty
    #               / path-absolute   ; begins with "/" but not "//"
    #               / path-noscheme   ; begins with a non-colon segment
    #               / path-rootless   ; begins with a segment
    #               / path-empty      ; zero characters
    #
    # path-abempty  = *( "/" segment )
    # path-absolute = "/" [ segment-nz *( "/" segment ) ]
    # path-noscheme = segment-nz-nc *( "/" segment )
    # path-rootless = segment-nz *( "/" segment )
    # path-empty    = 0<pchar>
    # segment       = *pchar
    # segment-nz    = 1*pchar
    # segment-nz-nc = 1*( unreserved / pct-encoded / sub-delims / "@" )
    #               ; non-zero-length segment without any colon ":"
    #
    # pchar         = unreserved / pct-encoded / sub-delims / ":" / "@"
    # pct-encoded   = "%" HEXDIG HEXDIG
    # sub-delims    = "!" / "$" / "&" / "'" / "(" / ")" / "*" / "+" / "," / ";"
    #               / "="
    # unreserved    = ALPHA / DIGIT / "-" / "." / "_" / "~"
    #
    # ; RFC-2234 - Augmented BNF for Syntax Specifications: ABNF
    #
    # ALPHA         =  %x41-5A / %x61-7A   ; A-Z / a-z
    # DIGIT         = %x30-39              ; 0-9
    # HEXDIG        =  DIGIT / "A" / "B" / "C" / "D" / "E" / "F"
    # TODO
    true
  end

  def is_uri_path?(_), do: false

  @spec is_uri_query?(any) :: boolean
  def is_uri_query?(str) when is_binary(str) do
    # TODO
    true
  end

  def is_uri_query?(_), do: false

  @spec is_uri_fragment?(any) :: boolean
  def is_uri_fragment?(str) when is_binary(str) do
    # TODO
    true
  end

  def is_uri_fragment?(_), do: false
end

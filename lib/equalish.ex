defmodule Equalish do
  @default_tolerance 0.00001
  @tolerance Application.compile_env(:equalish, :tolerance, @default_tolerance)
  @default_relative_tolerance 1.0e-9

  @moduledoc ~s"""
  Equality operators for floats that are *almost* equal. Smooths out rounding errors and floating point precision issues.

  ```elixir
  import Equalish

  # As a macro
  assert is_eq_ish(0.5, 0.50000001)
  #=> true

  # As a guard
  def foo(a, b) when is_eq_ish(a, b) do
    ...
  end
  ```

  ## Tolerance
  Two numbers are considered equal if they are no further apart than the tolerance.
  The default tolerance is `#{@default_tolerance}`.

  You can change this in your config file with:

  ```elixir
  config :equalish,
    tolerance: #{@default_tolerance} # <- Change this
  ```

  This is a **compile-time** setting, because guards cannot read config while your program runs:

  * Set it in `config/config.exs` (or an env-specific config), not in `config/runtime.exs`.
    Changing it there recompiles everything that uses these guards.
  * A different value in `runtime.exs` is ignored by `mix run` and `iex -S mix`, and
    makes a release fail to boot.

  You can always pass a tolerance as the third argument instead.

  The tolerance is a fixed amount, not a percentage. This works well for numbers of
  everyday size, but not for very large or very small ones:

  * `is_eq_ish(1.0e12 + 0.1 + 0.2, 1.0e12 + 0.3)` is `false`, because rounding errors
    at that size are bigger than `#{@default_tolerance}`.
  * `is_eq_ish(1.0e-9, 9.0e-6)` is `true`, even though one is 9000 times the other.

  Examples below sometimes use the following tolerances as an example:

  ```
  @lax 0.1
  @strict 0.000000000000001
  ```

  These are not built into the library, and you must define them yourself.
  """

  @doc ~s"""
  Whether two numbers are equal (within the given tolerance)
  ## Examples
      iex> is_eq_ish(0.5, 0.5)
      true
      iex> is_eq_ish(0.5, 0.5001, @lax)
      true
      iex> is_eq_ish(0.5, 0.5001, @strict)
      false
      iex> is_eq_ish(0.5, 0.51)
      false
  """
  @spec is_eq_ish(left :: number(), right :: number(), tolerance :: number()) :: boolean()
  defguard is_eq_ish(left, right, tolerance \\ @tolerance) when abs(left - right) <= tolerance

  @doc ~s"""
  Whether two numbers are not within the given tolerance of each other.

  ## Examples
      iex> is_not_eq_ish(0.5, 0.5)
      false
      iex> is_not_eq_ish(0.5, 0.5001, @lax)
      false
      iex> is_not_eq_ish(0.5, 0.5001, @strict)
      true
  """
  @spec is_not_eq_ish(left :: number(), right :: number(), tolerance :: number()) :: boolean()
  defguard is_not_eq_ish(left, right, tolerance \\ @tolerance)
           when abs(left - right) > tolerance

  @doc ~s"""
  Whether a number is greater than another number, by AT LEAST the tolerance amount.
  ## Examples
      iex> is_gt_ish(0.5, 0.5)
      false
      iex> is_gt_ish(0.5, 0.4)
      true
      iex> is_gt_ish(0.5, 0.6)
      false
      iex> is_gt_ish(0.5, 0.50000001)
      false
  """
  @spec is_gt_ish(left :: number(), right :: number(), tolerance :: number()) :: boolean()
  defguard is_gt_ish(left, right, tolerance \\ @tolerance)
           when left > right and is_not_eq_ish(left, right, tolerance)

  @doc ~s"""
  Whether a number is greater than another number, or equalish.

  ## Examples
      iex> is_gte_ish(0.5, 0.5)
      true
      iex> is_gte_ish(0.5, 0.4)
      true
      iex> is_gte_ish(0.5, 0.6)
      false
      iex> is_gte_ish(0.5, 0.50000001)
      true
  """
  @spec is_gte_ish(left :: number(), right :: number(), tolerance :: number()) :: boolean()
  defguard is_gte_ish(left, right, tolerance \\ @tolerance)
           when left > right or is_eq_ish(left, right, tolerance)

  @doc ~s"""
  Whether a number is less than another number, or equalish.

  ## Examples
      iex> is_lte_ish(0.5, 0.5)
      true
      iex> is_lte_ish(0.5, 0.4)
      false
      iex> is_lte_ish(0.5, 0.6)
      true
      iex> is_lte_ish(0.5, 0.50000001)
      true
      iex> is_lte_ish(0.5, 0.49999999)
      true
  """
  @spec is_lte_ish(left :: number(), right :: number(), tolerance :: number()) :: boolean()
  defguard is_lte_ish(left, right, tolerance \\ @tolerance)
           when left < right or is_eq_ish(left, right, tolerance)

  @doc ~s"""
  Whether a number is less than another number, by AT LEAST the tolerance amount.
  ## Examples
      iex> is_lt_ish(0.5, 0.5)
      false
      iex> is_lt_ish(0.5, 0.4)
      false
      iex> is_lt_ish(0.5, 0.6)
      true
      iex> is_lt_ish(0.5, 0.50001, @lax)
      false
      iex> is_lt_ish(0.5, 0.50001, @strict)
      true
  """
  @spec is_lt_ish(left :: number(), right :: number(), tolerance :: number()) :: boolean()
  defguard is_lt_ish(left, right, tolerance \\ @tolerance)
           when left < right and is_not_eq_ish(left, right, tolerance)

  @doc ~s"""
  Whether a number is zero, or within the tolerance of zero.

  ## Examples
      iex> is_zero_ish(0.1 + 0.2 - 0.3)
      true
      iex> is_zero_ish(-0.000001)
      true
      iex> is_zero_ish(0.01)
      false
      iex> is_zero_ish(0.01, @lax)
      true
  """
  @spec is_zero_ish(value :: number(), tolerance :: number()) :: boolean()
  defguard is_zero_ish(value, tolerance \\ @tolerance) when is_eq_ish(value, 0, tolerance)

  @doc ~s"""
  Whether two numbers are close to each other, compared to their size.

  The other guards in this module use a fixed tolerance, which works best for
  numbers of everyday size. `is_close` instead allows a difference that grows
  with the numbers being compared, so it also works for very large and very
  small numbers.

  Two numbers are close if their difference is no bigger than **either**:

    * `relative_tolerance` times the larger of the two (by absolute value).
      The default `#{@default_relative_tolerance}` means "the same to about 9 significant digits".
    * `absolute_tolerance`, which defaults to `0.0`.

  Comparing anything to zero needs an `absolute_tolerance`, because a
  percentage of zero is zero. Use `is_zero_ish/2` for that instead.

  ## Examples
      iex> is_close(1.0e12 + 0.1 + 0.2, 1.0e12 + 0.3)
      true
      iex> is_close(1.0e-9, 9.0e-6)
      false
      iex> is_close(100.0, 101.0)
      false
      iex> is_close(100.0, 101.0, 0.01)
      true
      iex> is_close(1.0e-12, 0.0)
      false
      iex> is_close(1.0e-12, 0.0, 1.0e-9, 1.0e-10)
      true
  """
  @spec is_close(
          left :: number(),
          right :: number(),
          relative_tolerance :: number(),
          absolute_tolerance :: number()
        ) :: boolean()
  # Written without max/2, which is only allowed in guards from OTP 26.
  defguard is_close(
             left,
             right,
             relative_tolerance \\ @default_relative_tolerance,
             absolute_tolerance \\ 0.0
           )
           when abs(left - right) <= absolute_tolerance or
                  abs(left - right) <= relative_tolerance * abs(left) or
                  abs(left - right) <= relative_tolerance * abs(right)

  @doc false
  # The default tolerance, for code built by Equalish.Assertions. The leading
  # underscores stop `import Equalish` from importing it, so it can never clash
  # with a caller's own functions.
  @spec __tolerance__() :: number()
  def __tolerance__, do: @tolerance
end

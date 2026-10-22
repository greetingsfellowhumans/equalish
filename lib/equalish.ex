defmodule Equalish do
  @default_tolerance 0.00001
  @tolerance Application.compile_env(:equalish, :tolerance, @default_tolerance)

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
end

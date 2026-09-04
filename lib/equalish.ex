defmodule Equalish do

  @default_tolerance 0.00001
  @doc false
  defp get_tolerance() do
    Application.get_env(:equalish, :tolerance, @default_tolerance)
  end

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
  The default tolerance is `#{@default_tolerance}`, which is to say that two numbers are considered equal if their first 5 decimal places are the same.

  You can change this in your config file with:

  ```elixir
  config :equalish,
    tolerance: #{@default_tolerance} # <- Change this
  ```

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
  @spec is_eq_ish(left :: number(), right :: number(), tolerance :: float()) :: boolean()
  defguard is_eq_ish(left, right, tolerance \\ get_tolerance()) when abs(left - right) <= tolerance


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
  @spec is_not_eq_ish(left :: number(), right :: number(), tolerance :: float()) :: boolean()
  defguard is_not_eq_ish(left, right, tolerance \\ get_tolerance()) when abs(left - right) > tolerance


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
  @spec is_gt_ish(left :: number(), right :: number(), tolerance :: float()) :: boolean()
  defguard is_gt_ish(left, right, tolerance \\ get_tolerance()) when left > right and is_not_eq_ish(left, right, tolerance)

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
  @spec is_gte_ish(left :: number(), right :: number(), tolerance :: float()) :: boolean()
  defguard is_gte_ish(left, right, tolerance \\ get_tolerance()) when left > right or is_eq_ish(left, right, tolerance)


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
  @spec is_lte_ish(left :: number(), right :: number(), tolerance :: float()) :: boolean()
  defguard is_lte_ish(left, right, tolerance \\ get_tolerance()) when left < right or is_eq_ish(left, right, tolerance)

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
  @spec is_lt_ish(left :: number(), right :: number(), tolerance :: float()) :: boolean()
  defguard is_lt_ish(left, right, tolerance \\ get_tolerance()) when left < right and is_not_eq_ish(left, right, tolerance)
end

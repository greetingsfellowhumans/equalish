defmodule Equalish.Assertions do
  @moduledoc ~s"""
  ExUnit assertions for numbers that should be *almost* equal.

  They work like `assert is_eq_ish(left, right)`, but when they fail they show
  both values, how far apart they are, and the tolerance.

  ```elixir
  defmodule MyTest do
    use ExUnit.Case
    import Equalish.Assertions

    test "adding floats" do
      assert_eq_ish(0.1 + 0.2, 0.3)
      refute_eq_ish(0.1 + 0.2, 0.4)
    end
  end
  ```

  A failing assertion looks like this:

  ```
  Expected numbers to be equal-ish
  difference: 0.009999999999999953
  tolerance:  1.0e-5
  code:  assert_eq_ish(0.1 + 0.2, 0.31)
  left:  0.30000000000000004
  right: 0.31
  ```
  """

  require Equalish

  @doc ~s"""
  Asserts that `left` and `right` are within `tolerance` of each other.

  The tolerance defaults to the one set in your config (see `Equalish`). Returns `true` on success,
  and raises `ExUnit.AssertionError` on failure, including when either value
  is not a number.

  ## Examples
      iex> assert_eq_ish(0.1 + 0.2, 0.3)
      true
      iex> assert_eq_ish(0.5, 0.55, 0.1)
      true
  """
  @spec assert_eq_ish(Macro.t(), Macro.t(), Macro.t()) :: Macro.t()
  defmacro assert_eq_ish(left, right, tolerance \\ quote(do: Equalish.__tolerance__())) do
    build(:assert_eq_ish, left, right, tolerance)
  end

  @doc ~s"""
  Asserts that `left` and `right` are further apart than `tolerance`.

  The tolerance defaults to the one set in your config (see `Equalish`). Returns `true` on success,
  and raises `ExUnit.AssertionError` on failure, including when either value
  is not a number.

  ## Examples
      iex> refute_eq_ish(0.1 + 0.2, 0.4)
      true
      iex> refute_eq_ish(0.5, 0.55, 0.01)
      true
  """
  @spec refute_eq_ish(Macro.t(), Macro.t(), Macro.t()) :: Macro.t()
  defmacro refute_eq_ish(left, right, tolerance \\ quote(do: Equalish.__tolerance__())) do
    build(:refute_eq_ish, left, right, tolerance)
  end

  # Builds the code for either assertion. The raise is expanded into the
  # caller's test, so this library never references ExUnit itself.
  @spec build(atom(), Macro.t(), Macro.t(), Macro.t()) :: Macro.t()
  defp build(name, left, right, tolerance) do
    code = Macro.escape({name, [], [left, right]})

    # generated: true stops the type checker warning about a branch that can never
    # run when the arguments are literals, e.g. assert_eq_ish(1, 1).
    quote generated: true do
      left = unquote(left)
      right = unquote(right)
      tolerance = unquote(tolerance)

      case Equalish.Assertions.__failure__(unquote(name), left, right, tolerance) do
        nil ->
          true

        message ->
          raise ExUnit.AssertionError,
            message: message,
            expr: unquote(code),
            left: left,
            right: right
      end
    end
  end

  @doc false
  # Returns the failure message, or nil if the assertion passes.
  # Public only so the code built by the macros can call it.
  @spec __failure__(:assert_eq_ish | :refute_eq_ish, term(), term(), term()) :: String.t() | nil
  def __failure__(_name, left, right, tolerance)
      when not is_number(left) or not is_number(right) or not is_number(tolerance) do
    "Expected numbers, got: #{inspect(left)}, #{inspect(right)} (tolerance: #{inspect(tolerance)})"
  end

  def __failure__(name, left, right, tolerance),
    do: check(name, difference(left, right), tolerance)

  # How far apart two numbers are, or :overflow when the difference is too
  # large to be a float (e.g. 1.7e308 and -1.7e308). Numbers that far apart
  # are never equal-ish.
  @spec difference(number(), number()) :: number() | :overflow
  defp difference(left, right) do
    abs(left - right)
  rescue
    ArithmeticError -> :overflow
  end

  # Returns nil if the assertion passes, or the failure message.
  @spec check(:assert_eq_ish | :refute_eq_ish, number() | :overflow, number()) ::
          String.t() | nil
  defp check(:assert_eq_ish, difference, tolerance)
       when is_number(difference) and Equalish.is_zero_ish(difference, tolerance),
       do: nil

  defp check(:refute_eq_ish, :overflow, _tolerance), do: nil

  defp check(:refute_eq_ish, difference, tolerance)
       when not Equalish.is_zero_ish(difference, tolerance),
       do: nil

  defp check(:assert_eq_ish, difference, tolerance),
    do: message("Expected numbers to be equal-ish", difference, tolerance)

  defp check(:refute_eq_ish, difference, tolerance),
    do: message("Expected numbers NOT to be equal-ish", difference, tolerance)

  # Formats a failure message with the difference and tolerance.
  @spec message(String.t(), number() | :overflow, number()) :: String.t()
  defp message(headline, difference, tolerance) do
    """
    #{headline}
    difference: #{format_difference(difference)}
    tolerance:  #{inspect(tolerance)}\
    """
  end

  @spec format_difference(number() | :overflow) :: String.t()
  defp format_difference(:overflow), do: "too large to represent"
  defp format_difference(difference), do: inspect(difference)
end

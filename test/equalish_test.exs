defmodule EqualishTest do
  use ExUnit.Case
  use ExUnitProperties
  import Equalish
  @lax 0.1
  @strict 0.000000000000001
  doctest Equalish

  # Bounded so that `a - b` can never overflow.
  @bound 1.0e12

  def foo(a, b) when is_eq_ish(a, b, @lax), do: true
  def foo(_, _), do: false

  # Runs every comparison as a guard in a function head, returning the results as a map.
  defp guard_results(a, b, tol) do
    %{
      eq: guard_eq(a, b, tol),
      not_eq: guard_not_eq(a, b, tol),
      gt: guard_gt(a, b, tol),
      gte: guard_gte(a, b, tol),
      lt: guard_lt(a, b, tol),
      lte: guard_lte(a, b, tol)
    }
  end

  # Same as guard_results/3, but calling the guards as ordinary expressions.
  defp expr_results(a, b, tol) do
    %{
      eq: is_eq_ish(a, b, tol),
      not_eq: is_not_eq_ish(a, b, tol),
      gt: is_gt_ish(a, b, tol),
      gte: is_gte_ish(a, b, tol),
      lt: is_lt_ish(a, b, tol),
      lte: is_lte_ish(a, b, tol)
    }
  end

  defp guard_eq(a, b, tol) when is_eq_ish(a, b, tol), do: true
  defp guard_eq(_, _, _), do: false
  defp guard_not_eq(a, b, tol) when is_not_eq_ish(a, b, tol), do: true
  defp guard_not_eq(_, _, _), do: false
  defp guard_gt(a, b, tol) when is_gt_ish(a, b, tol), do: true
  defp guard_gt(_, _, _), do: false
  defp guard_gte(a, b, tol) when is_gte_ish(a, b, tol), do: true
  defp guard_gte(_, _, _), do: false
  defp guard_lt(a, b, tol) when is_lt_ish(a, b, tol), do: true
  defp guard_lt(_, _, _), do: false
  defp guard_lte(a, b, tol) when is_lte_ish(a, b, tol), do: true
  defp guard_lte(_, _, _), do: false

  defp num, do: one_of([float(min: -@bound, max: @bound), integer()])
  defp tolerance, do: float(min: 0.0, max: 1.0)

  describe "Guards" do
    test "eq should be a valid guard" do
      assert foo(0.1, 0.1000001)
      refute foo(0.1, 0.5)
    end
  end

  describe "Determine when two floats are almost equal" do
    test "Respect tolerance level" do
      a = 0.1234
      b = 0.1235
      assert is_eq_ish(a, b, @lax)
      refute is_eq_ish(a, b, @strict)
    end

    test "a difference exactly equal to the tolerance counts as equal" do
      assert is_eq_ish(0, 1, 1)
      refute is_not_eq_ish(0, 1, 1)
      refute is_gt_ish(1, 0, 1)
      refute is_lt_ish(0, 1, 1)
    end

    test "negative numbers" do
      assert is_eq_ish(-0.5, -0.50000001)
      assert is_lt_ish(-0.6, -0.5)
      assert is_gt_ish(-0.5, -0.6)
      refute is_eq_ish(-0.5, 0.5)
    end

    test "mixed integers and floats" do
      assert is_eq_ish(1, 1.000001)
      assert is_gt_ish(2, 1.5)
      assert is_lte_ish(1.0, 1)
    end

    test "default tolerance boundaries" do
      assert is_eq_ish(1.0, 1.0 + 0.9e-5)
      refute is_eq_ish(1.0, 1.0 + 1.1e-5)
    end

    test "the README example" do
      assert is_eq_ish(0.1 + 0.2, 0.3)
    end
  end

  describe "Properties" do
    property "guards and expressions agree" do
      check all(a <- num(), b <- num(), tol <- tolerance()) do
        assert guard_results(a, b, tol) == expr_results(a, b, tol)
      end
    end

    property "exactly one of eq / not_eq holds" do
      check all(a <- num(), b <- num(), tol <- tolerance()) do
        assert is_eq_ish(a, b, tol) != is_not_eq_ish(a, b, tol)
      end
    end

    property "gt is the opposite of lte, and lt is the opposite of gte" do
      check all(a <- num(), b <- num(), tol <- tolerance()) do
        assert is_gt_ish(a, b, tol) == not is_lte_ish(a, b, tol)
        assert is_lt_ish(a, b, tol) == not is_gte_ish(a, b, tol)
      end
    end

    property "swapping arguments" do
      check all(a <- num(), b <- num(), tol <- tolerance()) do
        assert is_gt_ish(a, b, tol) == is_lt_ish(b, a, tol)
        assert is_gte_ish(a, b, tol) == is_lte_ish(b, a, tol)
        assert is_eq_ish(a, b, tol) == is_eq_ish(b, a, tol)
      end
    end

    property "every number is equalish to itself" do
      check all(a <- num(), tol <- tolerance()) do
        assert is_eq_ish(a, a, tol)
        refute is_gt_ish(a, a, tol)
        refute is_lt_ish(a, a, tol)
      end
    end

    property "numbers well within the tolerance are equalish" do
      check all(
              a <- float(min: -1.0e6, max: 1.0e6),
              tol <- float(min: 1.0e-6, max: 1.0),
              ratio <- float(min: -0.5, max: 0.5)
            ) do
        assert is_eq_ish(a, a + ratio * tol, tol)
      end
    end
  end
end

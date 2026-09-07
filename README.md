# Equalish

Comparison operators for floats that are *almost* equal.

## The problem this solves

Smooths out rounding errors and floating point precision issues.

```elixir
    iex> 0.1 + 0.2 
    0.30000000000000004
    iex> 0.1 + 0.2 == 0.3
    false
    iex> import Equalish
    iex> is_eq_ish(0.1 + 0.2) == 0.3
    true
```

## Guards

```elixir
import Equalish

# As a macro
assert is_eq_ish(0.5, 0.50000001)

# As a guard
def foo(a, b) when is_eq_ish(a, b) do
  ...
end
```

All 6 of the usual equality operators are present:

* `is_eq_ish`: roughly `==`
* `is_not_eq_ish`: NOT roughly `==`
* `is_gt_ish`: `>` but must be enough of a difference to NOT be roughly equal.
* `is_gte_ish`: roughly `==` OR `>`
* `is_lt_ish`: `<` but must be enough of a difference to NOT be roughly equal.
* `is_lte_ish` roughly `==` OR `<`

```elixir
assert is_gt_ish(0.5, 0.2)
refute is_gt_ish(0.5, 0.49999999999999)
```

## Tolerance

You can pass in a custom tolerance threshold, or add it to your config.

## Installation

This package can be installed by adding `equalish` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:equalish, "~> 1.0.0"}
  ]
end
```

Documentation can be found at <https://hexdocs.pm/equalish>.

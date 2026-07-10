defmodule Servy.MixProject do
  use Mix.Project

  def project do
    [
      app: :servy,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      aliases: aliases(),
      dialyzer: dialyzer(),
      docs: docs(),
      test_coverage: [summary: [threshold: 80]]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def cli do
    [
      preferred_envs: [
        check: :test,
        quality: :test,
        "test.coverage": :test
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :eex]
    ]
  end

  defp deps do
    [
      # Style, design smells, and readability — closest to RuboCop + Reek
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},

      # Static type analysis — no direct Ruby equivalent; catches impossible calls
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},

      # API docs from @moduledoc / @doc — closest to YARD
      {:ex_doc, "~> 0.37", only: :dev, runtime: false},

      # Dependency vulnerability scan — closest to bundle-audit
      {:mix_audit, "~> 2.1", only: [:dev, :test], runtime: false},

      # Documentation coverage report — closest to `yard stats`
      {:doctor, "~> 0.23", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      # Auto-format all files (like rubocop -a for layout)
      fmt: ["format"],

      # Fast pre-commit gate: formatting, lint, tests
      check: ["format --check-formatted", "credo", "test"],

      # Documentation coverage thresholds (like yard stats)
      "docs.check": ["doctor --summary --raise"],

      # Full quality gate: check + types + dependency audit + doc coverage
      quality: ["check", "doctor --summary --raise", "dialyzer", "deps.audit"],

      # Coverage report printed after the test run
      "test.coverage": ["test --cover"],

      # Stricter lint pass (includes low-priority checks)
      "lint.strict": ["credo --strict"]
    ]
  end

  defp dialyzer do
    [
      plt_add_apps: [:ex_unit],
      flags: [:unmatched_returns, :error_handling, :underspecs],
      list_unused_filters: true
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"],
      groups_for_modules: [
        Core: [Servy.Handler, Servy.Parser, Servy.Plugins, Servy.Conv]
      ]
    ]
  end
end

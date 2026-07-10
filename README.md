# Servy

A minimal HTTP request handler built while working through
[Pragmatic Studio's Elixir course](https://pragmaticstudio.com/elixir).
Servy parses raw HTTP/1.1 requests, routes them to handlers, and formats
responses — without a web framework.

## How it works

A request flows through a pipeline of functions, each transforming a **conv**
(conversation) struct (`%Servy.Conv{}`):

```elixir
%Servy.Conv{method: "GET", path: "/wildlife", resp_body: "", status: nil}
```

```mermaid
flowchart LR
    A["Raw HTTP request"] --> B["log\n(Servy.Plugins)"]
    B --> C["parse\n(method + path + headers + params)"]
    C --> D["rewrite_path\n(/wildthings → /wildlife)"]
    D --> E["route\n(status + body)"]
    E --> F["format_response"]
    F --> G["HTTP response string"]
```

### Module relationships

```mermaid
flowchart TB
    Handler["Servy.Handler\n(orchestrator)"]
    Conv["Servy.Conv\nstruct · display_status"]
    Plugins["Servy.Plugins\nlog · rewrite_path"]
    Parser["Servy.Parser\nstatic HTML from pages/"]
    BearCtrl["Servy.BearController\nindex · show · delete"]
    BearView["Servy.BearView\nEEx index · show"]
    Wildthings["Servy.Wildthings\nbear catalog"]
    Bear["Servy.Bear\nstruct"]

    Handler --> Plugins
    Handler --> Parser
    Handler --> BearCtrl
    Handler -.-> Conv
    BearCtrl --> Wildthings
    BearCtrl --> BearView
    Wildthings --> Bear
    BearView -.-> Templates["templates/*.eex"]
```

## Modules

| Module | Responsibility |
| --- | --- |
| `Servy.Handler` | Orchestrates the pipeline; parses, routes, and formats responses |
| `Servy.Plugins` | Cross-cutting transforms: logging and path rewriting |
| `Servy.Parser` | Serves static HTML from the `pages/` directory |
| `Servy.Conv` | Typed conv struct; formats HTTP status lines via `display_status/1` |
| `Servy.BearController` | Bear actions: load data, set status/body on the conv |
| `Servy.BearView` | Compiles `templates/*.eex` into `index/1` and `show/1` HTML helpers |
| `Servy.Wildthings` | In-memory bear catalog (`bear_list/0`, `get_bear/1`) |
| `Servy.Bear` | Bear struct (`id`, `name`, `type`, `hibernating`) |
| `Recurse` | Practice recursion helpers (`loopy/1`, `factorial/1`) — not part of HTTP |

### Bears: controller vs view

- **`Servy.BearController`** — HTTP/action layer. Fetches bears from
  `Wildthings`, calls the view, returns an updated conv (`status` + `resp_body`).
- **`Servy.BearView`** — Presentation layer. Uses `EEx.function_from_file/4` so
  templates under `templates/` become compiled functions (`index/1`, `show/1`).
  Edit a `.eex` file, then recompile for changes to apply.

## Routes

| Method | Path | Response |
| --- | --- | --- |
| `GET` | `/wildlife` | `200` wildlife listing |
| `GET` | `/bears` | `200` list HTML via `BearController.index` → `BearView.index` |
| `GET` | `/bears/:id` | `200` show HTML via `BearController.show` → `BearView.show` |
| `POST` | `/bears` | `201` with `inspect(params) created!` (form body) |
| `DELETE` | `/bears/:id` | `403` `"Delete a bear is Forbidden"` |
| `GET` | `/about`, `/contact_us`, `/info/*` | HTML from `pages/` (`200` / `404` / `500`) |
| * | unmatched | `404` with `"{path} Not Found"` |

`GET /wildthings` is rewritten to `/wildlife` before routing.

## Getting started

Requires Elixir `~> 1.18`.

```bash
mix deps.get
mix test
```

## Testing

Tests live under `test/` and use shared builders in `Servy.Test.Fixtures`
(`test/support/fixtures.ex`):

| Helper | Purpose |
| --- | --- |
| `Fixtures.conv/0` / `conv/1` | Build a `%Servy.Conv{}` with overrides |
| `Fixtures.request/2` | Minimal GET-style request string |
| `Fixtures.request/3,4` | Request with body and optional `content_type` |
| `Fixtures.form_request/3` | URL-encoded form POST with params map |

Layout:

```text
test/
  recurse_test.exs              # Recurse practice module
  support/
    fixtures.ex                 # shared builders (compiled in test)
    fixtures_test.exs           # fixture contract tests
  handler/
    handler_test.exs            # pipeline, parse, route, format
    parser_test.exs             # static pages
    plugins_test.exs            # log + rewrite_path
    conv_test.exs               # status phrases
    bear_controller_test.exs    # index / show / delete
    bear_view_test.exs          # compiled EEx views
    wildthings_test.exs         # bear catalog
```

```bash
# Full suite
mix test

# Suite with coverage summary (threshold: 80%)
mix test.coverage
```

## Code quality (Ruby → Elixir)

If you are coming from Ruby, this table maps familiar tools to their Elixir
equivalents in this project:

| Ruby | Elixir (this project) | What it does |
| --- | --- | --- |
| RuboCop (layout) | `mix format` | Built-in formatter — no extra gem needed |
| RuboCop + Reek | [Credo](https://github.com/rrrene/credo) | Style, readability, and design-smell checks |
| Sorbet / Steep | [Dialyzer](https://www.erlang.org/doc/apps/dialyzer) via [Dialyxir](https://github.com/jeremyjh/dialyxir) | Static analysis of types and impossible calls |
| RSpec / Minitest | [ExUnit](https://hexdocs.pm/ex_unit/ExUnit.html) | Built-in test framework (`test/`, doctests in `@doc`) |
| YARD | [ExDoc](https://github.com/elixir-lang/ex_doc) | Docs generated from `@moduledoc` and `@doc` |
| `yard stats` | [Doctor](https://github.com/akoutmos/doctor) | Documentation coverage % for modules, functions, and `@spec` |
| bundle-audit | [mix_audit](https://github.com/mirego/mix_audit) | Scans `mix.lock` for known vulnerable deps |
| SimpleCov | `mix test --cover` | Built-in coverage report (threshold: 80%) |
| Brakeman | [Sobelow](https://github.com/nccgroup/sobelow) | Add when you reach Phoenix — not needed here |

### Quality workflow

```mermaid
flowchart TD
    subgraph daily ["While coding"]
        T["mix test"]
        F["mix fmt"]
    end

    subgraph commit ["Before commit"]
        C["mix check\nformat · credo · test"]
    end

    subgraph pr ["Before PR / weekly"]
        Q["mix quality\ncheck · doctor · dialyzer · deps.audit"]
        TC["mix test.coverage"]
        DC["mix docs.check"]
        D["mix docs"]
    end

    daily --> commit --> pr
```

### Day-to-day commands

```bash
# Auto-format all files (run often, like rubocop -a)
mix fmt

# Fast pre-commit check: format + lint + tests
mix check

# Full quality gate: check + doctor + dialyzer + dependency audit
mix quality

# Stricter Credo pass (includes low-priority hints)
mix lint.strict

# Tests with coverage summary
mix test.coverage

# Documentation coverage report (like yard stats)
mix docs.check

# Generate HTML docs
mix docs && open doc/index.html
```

### What each tool teaches you

- **`mix format`** — One official Elixir style. Run `mix fmt` before every commit.
- **`mix credo`** — RuboCop-style cops plus Reek-style smells. Try
  `mix credo --strict` or `mix credo explain <issue>` to learn why a check fired.
- **`mix dialyzer`** — First run builds a PLT cache (1–2 min); later runs are fast.
  Add `@spec` to public functions as you learn — Dialyzer actually uses them.
- **`mix test`** — Doctests in `@doc` strings are executable examples (like YARD
  examples that also run in CI).
- **`mix deps.audit`** — Like `bundle audit`; runs as part of `mix quality`.
- **`mix doctor`** — Like `yard stats`. Thresholds live in `.doctor.exs`;
  `mix docs.check` fails when coverage drops.
- **Credo `ModuleDoc`** — Catches missing `@moduledoc`; use Doctor for per-function
  `@doc` coverage.

### Suggested workflow

```bash
# While coding
mix test
mix fmt

# Before committing
mix check

# Before opening a PR / weekly
mix quality
mix test.coverage
mix docs.check
mix docs
```

> **Note:** The first `mix dialyzer` builds the PLT cache under `_build/`.
> Subsequent runs reuse it and are much faster.

## Project layout

```text
lib/
  recurse.ex              # recursion practice (loopy, factorial)
  servy/
    handler.ex            # request pipeline and routing
    plugins.ex            # logging and path rewrite
    parser.ex             # static page loader
    conv.ex               # Conv struct and display_status/1
    bear.ex               # Bear struct
    bear_controller.ex    # bear actions (status + body on conv)
    bear_view.ex          # compiled EEx views (index, show)
    wildthings.ex         # in-memory bear data
pages/                    # HTML files served by Servy.Parser
templates/                # EEx templates compiled by BearView
test/
  support/                # shared fixtures + fixture tests
  handler/                # tests per request module
  recurse_test.exs
```

## Static pages

HTML files live under `pages/` and are resolved by path:

- `/about` → `pages/about.html`
- `/contact_us` → `pages/contact_us.html`
- `/info/about_me` → `pages/info/about_me.html`

Missing files yield `404`; other `File.read/1` errors yield `500`.

## Tools to explore later

As the course progresses, these are worth adding:

| Tool | When to add | Ruby analogue |
| --- | --- | --- |
| [Mox](https://github.com/dashbitco/mox) | Mocking external services | RSpec doubles |
| [ExCoveralls](https://github.com/parroty/excoveralls) | CI coverage badges | SimpleCov + Coveralls |
| [Sobelow](https://github.com/nccgroup/sobelow) | Phoenix web apps | Brakeman |
| [GitHub Actions](https://github.com/marketplace?type=actions&query=elixir) | CI on every push | GitHub Actions with RuboCop + RSpec |

## Markdown linting

README and other Markdown files can be checked with
[markdownlint](https://github.com/DavidAnson/markdownlint):

```bash
npx markdownlint-cli2 "README.md"
```

Rules are configured in `.markdownlint.json` at the project root.

# <img src="app/assets/images/watchtower/watchtower_icon.svg" alt="Watchtower Icon" width="200" height="200">

Watchtower is a drop-in immutable incident log and dashboard for Rails apps.

It automatically captures unhandled exceptions, stores them as permanent
records with full request context, and exposes a Sidekiq-style dashboard
at a route of your choice.

**Zero instrumentation required — install, mount, configure once.**

![Ruby](https://img.shields.io/badge/ruby-%3E%3D%203.2-red)
![Rails](https://img.shields.io/badge/rails-7.1%2F8.0-red)
![License](https://img.shields.io/badge/license-MIT-green)

---

## How it works

User request → Exception raised → Rack middleware intercepts
→ Incident created with full context → Admin visits /watchtower

Watchtower sits at the outermost layer of your Rack stack. When an
unhandled exception bubbles up, it captures everything — who, what,
where, when — stores it immutably, and re-raises so your app's normal
error handling is unaffected.

---

## Installation

Add to your `Gemfile`:

```ruby
gem "watchtower"
```

Install:

```bash
bundle install
rails watchtower:install:migrations
rails db:migrate
```

Mount the dashboard in `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  mount Watchtower::Engine => "/watchtower"
end
```

That's it. Watchtower is now capturing incidents automatically.

---

## Configuration

Create `config/initializers/watchtower.rb`:

```ruby
Watchtower.configure do |config|
  # Tell Watchtower how to find the current user.
  # The proc is evaluated in request context.
  config.current_actor { Current.user }

  # Protect the dashboard — proc is evaluated in controller context.
  config.dashboard_auth { authenticate_admin! }

  # Add exceptions you never want recorded.
  config.ignored_exceptions << "MyApp::ExpectedError"
end
```

### Options

| Option | Default | Description |
|---|---|---|
| `current_actor` | `nil` | Proc to resolve the acting user |
| `dashboard_auth` | `nil` | Proc to authorize dashboard access |
| `ignored_exceptions` | `["ActionController::RoutingError", "ActionController::UnknownFormat"]` | Exceptions to skip |

---

## Dashboard

Visit `/watchtower` (or wherever you mounted the engine).

- **Incident feed** — all captured exceptions, newest first
- **Filters** — by status (open/resolved) and severity
- **Stats** — open, resolved, and critical counts
- **Detail view** — full backtrace, request context, actor, params, metadata
- **Resolve** — mark incidents as resolved

---

## Manual capture

For exceptions you rescue yourself but still want logged:

```ruby
rescue Stripe::CardError => e
  Watchtower.record_incident(e, context: {
    metadata: { order_id: @order.id, amount: @order.total }
  })
  redirect_to checkout_path, alert: "Payment failed."
end
```

### Context options

| Key | Description |
|---|---|
| `metadata` | Any hash of extra data |
| `request_url` | Override the request URL |
| `request_method` | Override the request method |
| `controller` | Override controller name |
| `action` | Override action name |
| `ip_address` | Override IP address |
| `user_agent` | Override user agent |
| `actor` | Override the actor entirely |

---

## Architecture

### Key design decisions

**Immutability** — Incidents are append-only. `before_update` and
`before_destroy` callbacks raise `Watchtower::ImmutableRecordError`.
`resolve!` is the single allowed state transition — it uses
`update_columns` to bypass callbacks intentionally.

**Fingerprinting** — Each incident gets an MD5 fingerprint derived
from `exception_class + exception_message + first backtrace line`.
Identical errors produce identical fingerprints, enabling grouping.

**Never crashes the host app** — Both the middleware and recorder
wrap persistence in a `rescue StandardError` with a `warn`, so
Watchtower never takes down your app even if its own DB is unavailable.

**Isolated namespace** — `isolate_namespace Watchtower` ensures models,
controllers, and routes never collide with the host app.

---

## Incident schema

| Column | Type | Description |
|---|---|---|
| `exception_class` | string | e.g. `NoMethodError` |
| `exception_message` | string | The exception message |
| `backtrace` | text | Full backtrace joined by newlines |
| `fingerprint` | string | MD5 of class + message + location |
| `severity` | string | `low / medium / high / critical` |
| `status` | string | `open / resolved` |
| `actor_type` | string | Polymorphic — e.g. `User` |
| `actor_id` | bigint | Polymorphic — actor's id |
| `request_url` | string | Full request URL |
| `request_method` | string | `GET`, `POST`, etc. |
| `controller` | string | Rails controller name |
| `action` | string | Rails action name |
| `ip_address` | inet | Client IP |
| `user_agent` | string | Client user agent |
| `params` | jsonb | Filtered request params |
| `metadata` | jsonb | Arbitrary extra context |
| `occurred_at` | datetime | When the exception happened |
| `resolved_at` | datetime | When it was resolved |

---

## Requirements

- Ruby >= 3.2
- Rails >= 7.1
- PostgreSQL (uses `jsonb` and `inet` column types)

---

## Contributing

1. Fork the repo
2. Create a branch (`git checkout -b feat/my-feature`)
3. Make your changes with tests
4. Run the test suite (`bundle exec rspec`)
5. Open a pull request

---

## License

MIT — see [LICENSE](LICENSE.txt).

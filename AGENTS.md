# AGENTS.md — belanjaan/backend

## Project context
- Indonesian-language shopping app (`belanjaan` = shopping, `Barang` = item/goods).
- **Laravel 13** (PHP 8.3) with Tailwind CSS 4 + Vite 8 frontend.
- Fresh project — only skeleton code + `Barang` model and migration exist. No API routes, auth, or business logic yet.

## Commands
| Command | What |
|---|---|
| `composer dev` | Dev servers: PHP + queue worker + logs (`pail`) + Vite HMR via `concurrently` |
| `composer test` | Runs `php artisan config:clear` then `php artisan test` |
| `composer setup` | Full first-time setup (install deps, .env, key, migrate, npm, build) |
| `php artisan test --filter=ExampleTest` | Run a single test file |
| `npm run build` | Vite production build |

## Database
- **Local dev:** MySQL `db_belanja` (see `.env`). **SQLite** in `.env.example` — do not blindly copy example.
- **Tests:** SQLite `:memory:` (configured in `phpunit.xml`). Session, cache, queue all use `database` driver in dev.
- **Migrations:** Only `users`, `cache`, `jobs`, `barangs` (barangs is a skeleton — just `id` + `timestamps`).

## Architecture notes
- `bootstrap/app.php` configures web routes only (no API routes). JSON rendering is enabled for `api/*` routes.
- `Barang` model (`app/Models/Barang.php`) and its migration are empty shells — no fillable, casts, or relationships yet.
- `.npmrc` sets `ignore-scripts=true` — npm lifecycle hooks won't run.

## Code style
- `laravel/pint` (PHP CS Fixer wrapper) — run `./vendor/bin/pint` to fix.
- EditorConfig: 4-space indent, LF line endings.

## Testing
- PHPUnit 12 with `tests/Unit` and `tests/Feature` suites.
- Feature test environment overrides all services to `array`/`sync`/`null` drivers.

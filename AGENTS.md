# AGENTS.md — belanjaan/backend

## Project context
- Indonesian shopping list app (`belanjaan` = shopping, `Barang` = item).
- **Laravel 13** (PHP 8.3) with Tailwind CSS 4 + Vite 8.
- Real-time broadcasting via **Laravel Reverb** (local: `BROADCAST_CONNECTION=reverb`, port 8080).
- `bootstrap/app.php` configures both `web` and `api` routes, CSRF exclusion for `api/*`, JSON rendering for `api/*`, and `statefulApi()` (Sanctum).
- **Frontend is separate** — React SPA lives in `../frontend/` (not a Laravel Inertia/Blade app). The `resources/` dir is only a skeleton.
- **No auth endpoints** yet — Sanctum is installed but not wired to any login/register routes.

## Commands
| Command | What |
|---|---|
| `composer dev` | Dev servers: PHP + queue worker + logs (`pail`) + Vite HMR via `concurrently` |
| `composer test` | Runs `php artisan config:clear` then `php artisan test` |
| `composer setup` | Full first-time setup (install deps, .env, key, migrate, npm, build) |
| `php artisan test --filter=ExampleTest` | Run a single test file |

## Database
- **Local dev:** MySQL `db_belanja` (see `.env`). **SQLite** in `.env.example` — do not blindly copy example.
- **Tests:** SQLite `:memory:` (configured in `phpunit.xml`).
- **Dev driver choices:** Session, cache, queue all use `database` driver. Broadcasting uses `reverb`.

## Migrations
- `users`, `cache`, `jobs`, `barangs` — plus one migration that drops `harga_estimasi` from `barangs`.

## API (`routes/api.php` — all under `/api/barang`)
| Method | Path | Handler |
|---|---|---|
| GET | `/api/barang` | `index` — list all, latest first |
| POST | `/api/barang` | `store` — create (if `harga_final` given, sets `is_dibeli=true`) |
| PATCH | `/api/barang/{barang}` | `update` — partial update |
| PATCH | `/api/barang/{barang}/toggle-status` | `toggleStatus` — required `is_dibeli` boolean, `harga_final` required when buying |
| DELETE | `/api/barang/{barang}` | `destroy` |

## Broadcasting
- `BarangEvent` implements `ShouldBroadcastNow` on `shopping-channel` as `barang.event`.
- Dispatched in controller on create/update/delete (wrapped in `try/catch` — won't fail request on broadcast error).
- Payload: `{ action: 'CREATED'|'UPDATED'|'DELETED', data: { id, nama_barang, harga_final, is_dibeli } }`.

## Model: `Barang`
- `$fillable`: `nama_barang`, `harga_final`, `is_dibeli`
- `casts`: `harga_final` → `decimal:2`, `is_dibeli` → `boolean`

## Code style
- `laravel/pint` — run `./vendor/bin/pint` to fix.
- EditorConfig: 4-space indent, LF line endings.

## Testing
- PHPUnit 12 with `tests/Unit` and `tests/Feature` suites.
- Feature test environment overrides all services to `array`/`sync`/`null` drivers (no database, queue, or broadcast in tests).
- No business-logic tests exist yet (only `ExampleTest`).

## Infrastructure
- Deployed on **Railway** (`railway.json`): Nixpacks builder, start command runs `php artisan migrate --force && apache2-foreground`.
- `.npmrc` sets `ignore-scripts=true` — npm lifecycle hooks won't run.
- Docker config at `.docker/nginx.conf`.

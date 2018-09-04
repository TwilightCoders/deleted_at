# DeletedAt

## 0.5.0 _(June 25, 2018)_
- Removed use of invasive views in preference of sub-selects
- Dropped support for Ruby 2.0, 2.1, 2.2
- Dropped support for Rails 4.1
- Default `deleted_at` options using `Proc`

## 0.4.0 _(Never Released)_
- Specs for Rails 4.0-5.1
  - Uses `combustion` gem for cleaner and more comprehensive testing
- Added badges to ReadMe
- Using `:prepend` to leverage ancestry chain
- Add logger for internal use
- DRYd up init code
- Removed partially supported features
- Added DSL in migrations/schema for adding `deleted_at` timestamps to tables

## 0.3.0 _(May 10, 2017)_
- Add specs
- Clean up dependencies
- Auto-init models after installing views
- Remove chained `create` methods

## 0.2.6 _(April 06, 2017)_
- Add warning when no DB connection present

## 0.2.5 _(March 28, 2017)_
- Extract injections to `.load` method

## 0.2.4 _(February 03, 2017)_
- Use `becomes` to mask `::All` etc classes

## 0.2.3 _(February 03, 2017)_
- Chain `create!` method to work properly

## 0.2.2 _(February 03, 2017)_
- Chain `create` method to work properly

## 0.2.1 _(February 03, 2017)_
- More reliable table name handling
- Changed API for installing views (e.g. `destroy_deleted_view`, `uninstall_deleted_view`)

## 0.1.1 _(January 31, 2017)_
- Added instructions to readme
- Fixes stack-too-deep edge-case (by moving to `:include` over `:prepend`)

## 0.1.0 _(January 30, 2017)_
- Renames primary table to `model_name/all`
- Creates views for each model using `deleted_at`
  - `model_name/deleted`
  - `model_name/present`
- Classes created to read from views (`::All`, `::Present`, `::Deleted`)

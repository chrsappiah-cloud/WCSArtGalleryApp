# Enforcing CI on GitHub

These checks apply to **WCSArtGalleryApp** only (this repository). The **AfricanFashionApp** project is a separate repo with its own workflows.

After the first push to `main`, open **Settings → Branches → Branch protection rules → Add rule** (or edit the rule for `main`).

1. Enable **Require a pull request before merging** (recommended).
2. Under **Require status checks to pass before merging**, search for and require these checks (names match the workflow `name:` and job `id:`):

   - **WCS iOS build & unit tests** → job `ios`
   - **WCS Backend tests** → job `pytest`
   - **WCS Cloudflare Worker** → job `typecheck`

   GitHub shows them as separate rows in the status picker (for example **WCS iOS build & unit tests / ios**).

3. Optionally enable **Require branches to be up to date before merging**.

If a required check does not appear in the list, merge one PR to `main` so each workflow has run at least once on the default branch.

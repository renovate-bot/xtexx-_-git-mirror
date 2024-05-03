# shellcheck disable=SC2034

SYNCER_TYPE=forgejo
SYNCER_DEST=https://xtexChooser:"$GH_TOKEN"@github.com/xtexChooser/central.git
SYNCER_DEST_PREFIX=refs/heads/codeberg/xtex/
FORGEJO_BASE_URL=https://codeberg.org
FORGEJO_USERNAME=xtex

forgejo::hook::should_fail_on_push_err() {
	return 1
}

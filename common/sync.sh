# sync::sync_repo <name> <url>
sync::sync_repo() {
	local name="$1" url="$2"
	try_call_func anysyncer::hook::should_sync_repo "$name" || return 0
	try_call_func "$SYNCER_TYPE"::hook::should_sync_repo "$name" || return 0

	echo "Syncing $name from $url"
	git::refs::fetch repo "$url"
	cp -f "$(git::refs::file repo)" "$(git::refs::file repo1)"
	while read -r ref; do
		try_call_func anysyncer::hook::should_sync_ref "$name" "$ref" || continue
		try_call_func "$SYNCER_TYPE"::hook::should_sync_ref "$name" "$ref" || continue
		local destRef isSignedTagRef=''
		destRef="$SYNCER_DEST_PREFIX$name/$ref"
		if [[ "$ref" == *^{} ]]; then
			destRef="${destRef%\^\{\}}"
			isSignedTagRef=true
		fi
		echo "Syncing $name $ref to $destRef"
		if ! git::refs::check repo1 "$ref^{}"; then
			# commits, or annotated tags, or object ref of signed tags
			wgit fetch --no-write-fetch-head "$SYNCER_DEST" "$destRef" || true
			if [[ -z "$isSignedTagRef" ]]; then
				wgit fetch --write-fetch-head "$url" "$ref"
				headRev="$(wgit rev-parse FETCH_HEAD)"
			else
				wgit fetch --write-fetch-head "$url" "${ref%\^\{\}}"
				headRev="$(wgit rev-parse 'FETCH_HEAD^{commit}')"
			fi
			sync::push_branch "$headRev" "$destRef"

			if [[ "$ref" == refs/tags/* ]]; then
				if [[ -z "$isSignedTagRef" ]]; then
					sync::sync_tag "$name" "$url" "${ref#refs\/tags\/}" ""
				else
					sync::sync_signed_tag "$name" "$url" "${ref#refs\/tags\/}"
				fi
			fi
		fi
	done <"$(git::refs::file repo)"

	while read -r ref; do
		try_call_func anysyncer::hook::should_prune_ref "$ref" || continue
		try_call_func "$SYNCER_TYPE"::hook::should_prune_ref "$ref" || continue
		echo "Deleting ref $ref"
		wgit push --force "$SYNCER_DEST" :"$ref"
	done < <(git::refs::withprefix dest "$SYNCER_DEST_PREFIX$name/")

	wgit -c gc.reflogExpire=1 -c gc.reflogExpireUnreachable=0 \
		-c gc.rerereResolved=0 -c gc.rerereUnresolved=0 \
		-c gc.pruneExpire=now gc --quiet
}

# sync::push_branch <ref> <dest ref>
sync::push_branch() {
	echo "Pushing $1 to $2"
	if ! wgit push --force "$SYNCER_DEST" "$1":"$2"; then
		result=$?
		if try_call_func anysyncer::hook::should_fail_on_push_err "$2" &&
			try_call_func "$SYNCER_TYPE"::hook::should_fail_on_push_err "$2"; then
			return $result
		fi
	fi
	git::refs::remove dest "$2"
	echo "Pushed $1 to $2"
}

# sync::prune_refs
sync::prune_refs() {
	while read -r ref; do
		try_call_func anysyncer::hook::should_prune_ref "$ref" || continue
		try_call_func "$SYNCER_TYPE"::hook::should_prune_ref "$ref" || continue
		echo "Deleting ref $ref"
		wgit push --force "$SYNCER_DEST" :"$ref"
	done < <(git::refs::withprefix dest "$SYNCER_DEST_PREFIX")
}

# sync::sync_tag <name> <url> <tag>
sync::sync_tag() {
	local name="$1" url="$2" tag="$3"
	local ref headRev destRef
	ref="refs/tags/$tag"
	destRef="$SYNCER_DEST_TAGS_PREFIX$name/$tag"

	wgit fetch --write-fetch-head "$url" "$ref"
	headRev="$(wgit rev-parse FETCH_HEAD)"
	sync::push_branch "$headRev" "$destRef"
}

# sync::sync_signed_tag <name> <url> <annotated tag>
sync::sync_signed_tag() {
	local name="$1" url="$2" tag="$3"
	local ref="refs/tags/$tag"
	local signedRef="${ref%\^\{\}}"
	local signedTag="${tag%\^\{\}}"
	local headRev

	echo "Syncing signed tag from $name $tag to $signedTag/{signed,annotated}"

	wgit fetch --write-fetch-head "$url" "$signedRef"
	headRev="$(wgit rev-parse 'FETCH_HEAD^{tag}')"
	sync::push_branch "$headRev" "$SYNCER_DEST_TAGS_PREFIX$name/$signedTag/signed"
	headRev="$(wgit rev-parse 'FETCH_HEAD^{}')"
	sync::push_branch "$headRev" "$SYNCER_DEST_TAGS_PREFIX$name/$signedTag/annotated"
}

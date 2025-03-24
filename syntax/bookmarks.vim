" Bookmarks syntax file

if exists("b:current_syntax")
  finish
endif

syntax match bookmarksPath "^[^|]*"he=e-1 nextgroup=bookmarksSeparator1
syntax match bookmarksSeparator1 "|" contained nextgroup=bookmarksPos
syntax match bookmarksPos "[^|]*" contained nextgroup=bookmarksSeparator2
syntax match bookmarksSeparator2 "|" contained

highlight link bookmarksPath Directory
highlight link bookmarksSeparator1 Delimiter
highlight link bookmarksPos LineNr
highlight link bookmarksSeparator2 Delimiter

let b:current_syntax = "bookmarks"

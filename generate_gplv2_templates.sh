#!/usr/bin/env bash
#
# This script generates Xcode templates with GPLv2 header comments
#

source_template_dir='/Applications/Xcode.app/Contents/Developer/Library/Xcode/Templates/File Templates/Source'
gpl_template_dir="$HOME/Library/Developer/Xcode/Templates/File Templates/GPLv2 Source"

function copy_template {
	template_dir=$1
	target_dir=$gpl_template_dir/$(basename "$template_dir")
	echo "copy '$(basename "$template_dir")'"
	cp -r "$template_dir" "$target_dir"
	echo 'replace ___COPYRIGHT___'
	find "$target_dir" -type f -exec grep -Il "" {} \; | while read f; do
		perl -pi -e 's|//___COPYRIGHT___|//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___.\n//\n//  This file is part ___PROJECTNAME___.\n//\n//  ___PROJECTNAME___ is free software: you can redistribute it and/or modify\n//  it under the terms of the GNU General Public License as published by\n//  the Free Software Foundation, either version 2 of the License, or\n//  (at your option) any later version.\n//\n//  ___PROJECTNAME___ is distributed in the hope that it will be useful,\n//  but WITHOUT ANY WARRANTY; without even the implied warranty of\n//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n//  GNU General Public License for more details.\n//\n//  You should have received a copy of the GNU General Public License\n//  along with ___PROJECTNAME___.  If not, see <http://www.gnu.org/licenses/>.|' "$f"
	done
}

if [[ -e $gpl_template_dir ]]; then
	echo "'$gpl_template_dir' already exists" >&2
	exit 1
fi

mkdir -p "$gpl_template_dir"

find "$source_template_dir" -type d -mindepth 1 -maxdepth 1 | while read template; do
	copy_template "$template"
done

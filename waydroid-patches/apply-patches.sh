#!/bin/bash
# -*- coding: utf-8; tab-width: 4; c-basic-offset: 4; indent-tabs-mode: nil -*-

# autopatch.sh: script to manage patches on top of repo
# Copyright (c) 2018, Intel Corporation.
# Author: sgnanase <sundar.gnanasekaran@intel.com>
#
# This program is free software; you can redistribute it and/or modify it
# under the terms and conditions of the GNU General Public License,
# version 2, as published by the Free Software Foundation.
#
# This program is distributed in the hope it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.

top_dir=`pwd`
LOCALDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
patch_dir="$LOCALDIR/base-patches"
roms_patch_dir="$LOCALDIR/roms-patches"

#setup colors
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
purple=`tput setaf 5`
teal=`tput setaf 6`
light=`tput setaf 7`
dark=`tput setaf 8`
ltred=`tput setaf 9`
ltgreen=`tput setaf 10`
ltyellow=`tput setaf 11`
ltblue=`tput setaf 12`
ltpurple=`tput setaf 13`
CL_CYN=`tput setaf 12`
CL_RST=`tput sgr0`
reset=`tput sgr0`
current_project=""
previous_project=""
conflict=""
conflict_list=""
goodpatch=""
project_revision=""

tag_project() {
  cd $top_dir/$1
  git tag -f autopatch/`basename $patch_dir` > /dev/null
}

apply_patch() {

  pl=$1
  pd=$2

  echo -e ${reset}""${reset}
  echo -e ${teal}"Applying Patches"${reset}
  echo -e ${reset}""${reset} 

  for i in $pl
  do
    current_project=`dirname $i`
    if [[ $current_project != $previous_project ]]; then
      if [[ -n "$previous_project" ]]; then
        tag_project $previous_project
      fi
      echo -e ${reset}""${reset}
      echo -e ${ltblue}"Project $current_project"${reset}
      echo -e ${reset}""${reset} 
      cd $top_dir
      project_revision=`repo --color=never info $current_project | grep 'Current revision: ' | sed 's/Current revision: //'`
      project_log=`git -C $current_project log --max-count=1000 --pretty="format:%aD, %s" $project_revision..`
    fi
    previous_project=$current_project

    conflict_project=`echo $conflict_list | grep " $current_project "`
    if [[ -n "$conflict_project" ]]; then
      echo -e ${reset}""${reset}
      echo -e ${ltgreen}"        Skipping          $i"${reset}
      echo -e ${reset}""${reset} 
    fi

    cd $top_dir/$current_project
    a=`grep "Date: " $pd/$i | sed -e "s/Date: //"`
    b=`grep "Subject: " $pd/$i | sed -e "s/Subject: //" | sed -e "s/^\[PATCH[^]]*\] //"`
    c=`grep -F "$a, $b" <<< "$project_log"`

    if [[ "$c" == "" ]] ; then
      git am -3 $pd/$i >& /dev/null

      if [[ $? == 0 ]]; then
        echo -e ${reset}""${reset}
        echo -e ${ltgreen}"        Applying          $i"${reset}
        echo -e ${reset}""${reset}
      else
        echo -e ${reset}""${reset}
        echo -e ${ltred}"        Conflicts         $i"${reset}
        echo -e ${reset}""${reset}
		git am --abort >& /dev/null

		echo "                Searching other vendors for patch resolutions..."
        for agvendor in "$roms_patch_dir"/*/ ; do
            agvendor_name=$(echo ${d%%/} | sed 's|.*/||')
			echo "                looking in $agvendor_name for that patch..."
			if [[ -f "${agvendor}${i}" ]]; then
				echo "                Found ${agvendor}${i}!!"
				echo "                trying..."
				git am -3 "${agvendor}${i}" >& /dev/null
				if [[ $? == 0 ]]; then
					echo "                Applying          $i $?"
					goodpatch="y"
					break
				else
					echo "                Conflicts          $i"
					git am --abort >& /dev/null
					conflict="y"
				fi
			fi
		done
		if [[ "$goodpatch" != "y" ]]; then
			echo "                No resolution was found"
			git am --abort >& /dev/null
			echo "                Setting $i as Conflicts"
			conflict="y"
			conflict_list="$current_project $conflict_list"
		fi
      fi
    else
	  echo -e ${reset}""${reset}
	  echo -e ${green}"        Already applied   $i"${reset}
	  echo -e ${reset}""${reset}
    fi
  done

  if [[ -n "$previous_project" ]]; then
    tag_project $previous_project
  fi
}

sdkv=$(cat build/make/core/version_defaults.mk | grep "PLATFORM_SDK_VERSION :=" | grep -o "[[:digit:]]\+")
patch_dir="${patch_dir}-${sdkv}"
roms_patch_dir="${roms_patch_dir}-${sdkv}"

#Apply common patches
cd $patch_dir
patch_list=`find * -iname "*.patch" | sort -u`

apply_patch "$patch_list" "$patch_dir"

echo ""
if [[ "$conflict" == "y" ]]; then
  echo -e ${yellow} "==========================================================================="${reset}
  echo -e ${yellow} "           ALERT : Conflicts Observed while patch application !!           "${reset}
  echo -e ${yellow} "==========================================================================="${reset}
  for i in $conflict_list ; do echo $i; done | sort -u
  echo -e ${yellow} "==========================================================================="${reset}
  echo -e ${yellow} "WARNING: Please resolve Conflict(s). You may need to re-run build..."${reset}
  exit 1
else
  echo -e ${green} "==========================================================================="${reset}
  echo -e ${green} "           INFO : All patches applied fine !!                              "${reset}
  echo -e ${green} "==========================================================================="${reset}
fi

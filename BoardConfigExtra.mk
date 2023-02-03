#
# Copyright (C) 2021 The Waydroid project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

EXTRA_VENDOR_PATH := vendor/extra

# Filesystem
BOARD_ROOT_EXTRA_FOLDERS := odm_extra vendor_extra mnt_extra run var tmp

# Sepolicy
SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += $(EXTRA_VENDOR_PATH)/sepolicy/private
SELINUX_IGNORE_NEVERALLOWS := true

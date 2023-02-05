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

# HIDL
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/hosthals.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/hosthals.xml

# Init
PRODUCT_PACKAGES += \
    init.waydroid.rc

# Dummy libnfc-nci.conf
PRODUCT_PACKAGES += \
    libnfc-nci.conf

# Properties
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/waydroid.prop:$(TARGET_COPY_OUT_VENDOR)/waydroid.prop

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.setupwizard.mode=DISABLED

# PC mode
PRODUCT_PACKAGES += \
    pc.xml

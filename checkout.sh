#!/usr/bin/env bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

git clone https://github.com/mozilla-services/shavar-prod-lists.git || exit 1

# This revision is taken from the original Cartfile.resolved
(cd shavar-prod-lists && git checkout -q 56e01bfb2ee84349289e33ea785dea0946fe0030)

(cd content-blocker-lib-ios/ContentBlockerGen && swift run)

#!/usr/bin/env bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

git clone https://github.com/mozilla-services/shavar-prod-lists.git || exit 1

(cd shavar-prod-lists && git checkout -q 93.0)

(cd content-blocker-lib-ios/ContentBlockerGen && swift run)

#!/bin/bash

# Copyright 2015 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


get_src()
{
  url="$1"
  f=$(basename "$url")

  curl -sSL "$url" -o "$f"

  tar xzf "$f"
  rm -rf "$f"
}

apt-get update && apt-get dist-upgrade -y \
  curl \
  gcc \
  libssl-dev \
  libnl-3-dev libnl-route-3-dev libnl-genl-3-dev libxtables-dev libnfnetlink-dev libiptcdata0-dev \
  make \
  libipset-dev \
  libsnmp-dev \
  automake \
  ca-certificates

cd /tmp || exit 1

# download, verify and extract the source files
get_src "https://github.com/acassen/keepalived/archive/refs/tags/v${KeepalivedVersion}.tar.gz"

cd keepalived-$VERSION

aclocal
autoreconf -i
autoheader
automake --add-missing


./configure --prefix=/keepalived \
  --sysconfdir=/etc \
  --enable-snmp \
  --enable-sha1

make && make install

tar -czvf /keepalived.tar.gz /keepalived
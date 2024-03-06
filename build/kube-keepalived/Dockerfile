# Copyright 2015 The Kubernetes Authors. All rights reserved.
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

# Build
FROM golang:1.21 as build_context

ENV OUTDIR=/out
RUN mkdir -p ${OUTDIR}/usr/local/bin/

WORKDIR /workspace
ADD . /workspace/

RUN make binary
RUN mv /workspace/bin/cmd/kube-keepalived-vip ${OUTDIR}/kube-keepalived-vip



##############
# Final image
#############
FROM rykren/build-keepalived:2.2.8 as keepalived
FROM  debian:10.13

COPY --from=build_context /out/kube-keepalived-vip /
COPY --from=keepalived  /keepalived/ /keepalived/
COPY build/kube-keepalived /

RUN apt update && apt install -y \
  libssl1.1 \
  libnl-3-200 \
  libnl-route-3-200 \
  libnl-genl-3-200 \
  iptables \
  libxtables12 \
  libnfnetlink0 \
  libiptcdata0 \
  libipset11 \
  libipset-dev \
  libsnmp30 \
  kmod \
  ca-certificates \
  iproute2 \
  curl \
  ipvsadm \
  bash \
  jq \
  dumb-init \
  procps \
  && mkdir -p /etc/keepalived  \
  && ln -s /keepalived/sbin/keepalived /usr/sbin  \
  && ln -s /keepalived/bin/genhash /usr/sbin

ENTRYPOINT ["/usr/bin/dumb-init", "--", "/kube-keepalived-vip"]
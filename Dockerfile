FROM ubuntu:23.04 as latex
MAINTAINER Alexandre Norman <norman@xael.org>

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
        perl-tk \
        wget \
        python3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# COPY install-tl-unx.tar.gz ./
RUN wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz

RUN tar -zxf install-tl-unx.tar.gz \
    && mkdir -p /profiles/ \
    && mkdir -p /source

ENV PATH /usr/local/texlive/2023/bin/x86_64-linux:$PATH
ENV INFOPATH /usr/local/texlive/2023/texmf-dist/doc/info
ENV MANPATH /usr/local/texlive/2023/texmf-dist/doc/man

COPY texlive.profile /profiles/
COPY update-tlmgr-latest.sh /source/install-tl-*/

RUN cd install-tl-*/ ; ./install-tl --profile=/profiles/texlive.profile

RUN sh /source/install-tl-*/update-tlmgr-latest.sh -- --upgrade || true
RUN cd install-tl-*/ ; tlmgr init-usertree
RUN cd install-tl-*/ ; tlmgr install texliveonfly

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1
WORKDIR /source

ENTRYPOINT ["texliveonfly"]

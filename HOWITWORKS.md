# How Does This Work?

This is a high-level overview of the process, with which binary packages
for the `proaudio` package repository are built.

## Build Process

We use an automatic process to build binary Arch packages for the amd64 (aka
`x86_64`) and arm64 (aka `aarch64`) architectures from `PKGBUILD` files
organized in a single [source repository] hosted on GitHub. If a package is
successfully built and the updated `PKGBUILD` file is merged into the `master`
branch of the repository, the package is uploaded by the CI to the
[package repository] and the package listing on the [website] is also updated.

Our build process is rather idiosyncratic. We use [drone.io] as the CI,
employing a self-hosted drone server at `drone.cbix.de`. The CI is triggered
via webhooks from the Github repo. For each major phase of the build process
a [shell script] or a [drone.io plugin] is run as a separate step of our CI
[pipeline] in its own docker container.

Most custom pipeline steps use the [archlinux/archlinux:base-devel] docker
image. The build steps are defined in the file [.drone.yml] located in the
repository root.

For a more detailed and technical description of the various build steps,
consult the [README.md] file in the `tools` directory.


## Pros and Cons

This custom setup has its pros and cons.

Pros:

* We support building for the `aarch64` architecture.
* One can test the build locally on any Linux system, not just Arch Linux, when
  one has `drone-cli` installed.
* We can sync package updates to AUR package repositories.

Cons:

* We don't run all the checks, which the official Arch build chain does, for
  example checking for updated library soname, running `find-libdeps` etc.
* We can't have AUR dependencies (but AFAIK this is rather complicated with the
  official build process too).
* Probably some more, which I forget now.


[.drone.yml]: ./.drone.yml
[archlinux/archlinux:base-devel]: https://hub.docker.com/r/archlinux/archlinux/tags?page=1&name=base-devel
[drone.io plugin]: https://docs.drone.io/plugins/overview/
[drone.io]: https://www.drone.io/
[package repository]: https://arch.osamc.de/proaudio/
[pipeline]: https://docs.drone.io/pipeline/overview/
[readme.md]: ./tools/README.md
[shell script]: ./tools
[source repository]: https://github.com/osam-cologne/archlinux-proaudio
[website]: https://arch.osamc.de

# Website

This builds a simple static site using [Hugo] to be deployed at
[arch.osamc.de](https://arch.osamc.de/).

To see a preview run `./tools/preview-website.sh` from the repository root
dir. To render the package list this extracts the files databases to
`<repo root>/.tmp/db/{x86_64,aarch64}`, so this must be writeable by the
current user.


[hugo]: https://gohugo.io/

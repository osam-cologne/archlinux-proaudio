# Behind the scenes

## Guidelines
This project closely follows the [Arch package guidelines](https://wiki.archlinux.org/title/Arch_package_guidelines).
To support packaging, convenient tools are being maintained in this repo.
- [`.editorconfig`](https://editorconfig.org/) to ensure consistent formatting of PKGBUILDs in your editor (may need a plugin)
- `tools/fmt.sh` to manually format the PKGBUILD files (needs [`shfmt`](https://archlinux.org/packages/community/x86_64/shfmt/) installed)
- An [nvchecker](https://nvchecker.readthedocs.io/en/latest/) config with patterns for all included packages.
- check the CI logs for hints:
  - [`namcap`](https://wiki.archlinux.org/title/Namcap) analysis of PKGBUILD
  - full build of the package in a [clean environment](https://wiki.archlinux.org/title/DeveloperWiki:Building_in_a_clean_chroot#Why)
  - `namcap` analysis of the built package
  - rebuild and basic analysis of [reproducibility](https://reproducible-builds.org/) using [`diffoscope`](https://diffoscope.org/)

## Continuous Integration

Most of the tools in this directory are being used by the CI Build / Check / Publish pipeline,
which uses [Drone.io](https://www.drone.io/), so here's a rough outline of how that works:
Taking a look at the `.drone.yml` in the root directory, we can see several actions that are automatically
triggered by Git pushes / PRs:

### Prepare
This step determines which packages to build based on latest live versions etc. At the end of the
CI log for this step you'll see a summary like
```
Packages to skip:
 mclk.lv2: current version already in repo
 midiomatic: current version already in repo
 tuxguitar: unsupported architecture

Packages to build:
 mamba: new
 python-rtmidi: new
 string-machine: new
```
Remember to update the `pkgrel` so your package update reaches the users!

This step also fetches all required dependencies to a shared pacman cache in order to speed up successive
package installs.

The output of `makepkg --packagelist` is also used to create a list of all potential
package files of all packages in the repo, which is [later used](#update-database)
to remove old packages from the database.

### Build packages
This builds all packages determined by the prepare step.

### Reproduce packages
A quick way to check if [packages are reproducible](https://wiki.archlinux.org/title/Reproducible_Builds):
build the package twice using a fixed `SOURCE_DATE_EPOCH` value, then compare using `sha512sum` and
`diffoscope`.

### Analyze build scripts / built packages
Please refer to the [Namcap documentation](https://wiki.archlinux.org/title/Namcap).

### Sign packages
We're signing packages automatically using the [Drone GPGSign plugin](https://plugins.drone.io/drone-plugins/drone-gpgsign/)
and a private key stored as a secret in the CI system which is only available on pushes to `master`.
The key is generated like this
```
$ gpg --quick-generate-key 'OSAMC <https://github.com/osam-cologne/archlinux-proaudio>' ed25519 sign 5y
```
Then the secret key is exported
```
gpg --export-secret-key $KEY_ID | base64 -w0
```
and stored as a Drone secret (without PR permission!) using the Drone settings dashboard:

![Drone secrets screenshot](https://user-images.githubusercontent.com/1295945/159436898-1fff2b57-1277-4cbe-92b0-8dbeaf3f6c2b.png)

Alternatively [use the drone cli](https://docs.drone.io/cli/secret/drone-secret-add/):
```
$ drone secret add --name pkgsignkey --data '...5LAqcQp6zTA5lIc2tQpVf3F8+c=' osam-cologne/archlinux-proaudio
```
If you added a passphrase in the gpg step, also create a secret for that (`pkgsignkey-pass`).

The public key is exported using
```
gpg --export --armor $KEY_ID > osamc.gpg
```
and can be [downloaded from the repo server](https://arch.osamc.de/proaudio/osamc.gpg)

### Update database
This is basically using the stock `repo-add` and `repo-remove` which are shipped with Pacman.
To keep the database clean, all entries which are not built by any PKGBUILD are
removed. This prevents leftover entries from removed, renamed or merged packages.

### Publish
The [Drone SCP Plugin](https://plugins.drone.io/appleboy/drone-scp/) is used to push the resulting files to
the server. This needs a private SSH key stored as another Drone secret:
```
ssh-keygen -t ed25519 -C ci@osamc -f ./id_osamc -N ""
```
Store the content of `id_osamc` as another drone secret as described above
```
$ drone secret add --name ssh-key --data '-----BEGIN OPENSSH PRIVATE KEY...' osam-cologne/archlinux-proaudio
```
and append the public key in `id_osamc.pub` to `~/.ssh/authorized_keys` on the server for the desired user.

The server is a simple web server and only requires all published files for a repo and architecture
to sit in the same directory, for example `/var/www/proaudio/x86_64` and `/var/www/proaudio/aarch64`.
Users can then use the repo in their `/etc/pacman.conf` by adding
```
[proaudio]
Server = https://example.com/$repo/$arch
```
and manually using the provided signing key as described in the
[Arch Wiki](https://wiki.archlinux.org/title/Pacman/Package_signing#Adding_unofficial_keys).

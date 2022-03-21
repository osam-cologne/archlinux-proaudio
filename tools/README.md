# Behind the scenes

## Continuous Integration

Most of the tools in this directory are being used by the CI Build / Check / Publish pipeline, so here's a rough
outline of how that works:
Taking a look at the `.drone.yml` in the root directory, we can see several actions that are automatically
triggered by Git pushes / PRs:

### Prepare
This step determines which packages to build based on `git diff`, latest live versions etc. At the end of the
CI log for this step you'll see a summary like
```
Packages to skip:
 mclk.lv2: current version already in repo
 midiomatic: current version already in repo
 tuxguitar: unsupported architecture

Packages to build:
 mamba: modified
 string-machine: modified
```
Remember to update the `pkgrel` so your package update reaches the users!

This step also fetches all required dependencies to a shared pacman cache in order to speed up successive
package installs.

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
and stored as a Drone secret. The public key is exported using
```
gpg --export --armor $KEY_ID > osamc.gpg
```
and can be [downloaded from the repo server](https://arch.osamc.de/proaudio/osamc.gpg)
```

### Update database
This is basically using the stock `repo-add` and `repo-remove` which are shipped with Pacman.

### Publish
The [Drone SCP Plugin](https://plugins.drone.io/appleboy/drone-scp/) is used to push the resulting files to
the server. This needs a private SSH key stored as another Drone secret:
```
ssh-keygen -t ed25519 -C ci@osamc -f ./id_osamc -N ""
```
The server is a simple web server and only requires all published files to sit in the same directory.

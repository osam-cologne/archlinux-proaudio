# nvchecker for Archlinux-ProAudio

This directory contains a setup to check for new versions of software, which is
packaged by this project, using [nvchecker].

It contains a script, designed to run periodically on a server, which runs
`nvchecker` using a configuration generated from PKGBUILD and .nvchecker.toml files
in this repo and then posts a message to a Matrix Chat room, if `nvcmp` reports any
new versions.

## Howto

Install `jq` using your package manager of choice, e.g.:

```sh
pacman -Syu jq
```

Install `nvchecker`, e.g. via `pipx`:

```sh
PYTHON=python3.9
$PYTHON -m pip install --user pipx
pipx install "nvchecker[pypi]"
```

Install Python dependencies:

```sh
$PYTHON -m pip install --user appdirs tabulate matrix-nio
```

Clone this repository and set up the `nvchecker` sub-directory as the
`nvchecker` configuration directory:

```sh
git clone https://github.com/osam-cologne/archlinux-proaudio
mkdir -p ~/.config
ln -s ../archlinux-proaudio/nvchecker ~/.config
ln -s archlinux-proaudio.toml ~/.config/nvchecker/nvchecker.toml
```

Create a `keyfile.toml` file with an empty `[keys]` section for nvchecker:

```sh
echo -e `[keys]\n` > ~/.config/nvchecker/keyfile.toml`
```

You can add a Github API key to this file, if you want `nvchecker` to
authenticate to the Github API service using this key. See the `nvchecker`
[documentation](https://nvchecker.readthedocs.io/en/latest/usage.html#configuration-table)
for more information.

Copy the configuration file template for the `nvchecker-notify-matrixchat.py`
script and make it user-read- and -writeable only:

```sh
cd ~/.config/nvchecker/
cp nvchecker-notify-matrixchat.json.tmpl nvchecker-notify-matrixchat.json
chmod 600 nvchecker-notify-matrixchat.json
```

... and open `nvchecker-notify-matrixchat.json` for editing. Change the
`user_id` and `password` to the correct credentials for the Matrix Chat Bot
user account (this user must have a matching acount on the given Matrix server
and have joined the `archlinux-proaudio` room).

```json
{
  "homeserver": "https://sonoj.org",
  "password": "<change here>",
  "room_id": "!AkWpRHuPJQwVbEpayh:sonoj.org",
  "template": "{table}",
  "user_id": "@bot-archlinux-proaudio:sonoj.org"
}
```

Finally, add an entry to the user's crontab to run the `run-nvchecker.cron`
script periodically (e.g. once every 6 hours):

```sh
crontab -e
```

```cron
SHELL=/bin/bash
NVCHECK=$HOME/.config/nvchecker/run-nvchecker.cron
# run every 6 hours at half past the hour
30 0-23/6 * * * test -x $NVCHECK && $NVCHECK >> $HOME/logs/run-nvchecker.log 2>&1
# run every Monday at 10 a.m. and report all new versions, even if already reported
0 10 * * 1 test -x $NVCHECK && $NVCHECK --seen >> $HOME/logs/run-nvchecker.log 2>&1
```

Command line options passed to `run-nvchecker.cron` are passed on to
`nvchecker-notify-matrixchat.py`.

Note: by default, the script reports new version only once and records the
latest version it has seen. To make it report all new versions, use the
`-s|--seen` command line option.

[nvchecker]: https://github.com/lilydjwg/nvchecker

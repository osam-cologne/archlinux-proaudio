# nvchecker for Archlinux-ProAudio

This directory contains a setup to check for new versions of software, which is
packaged by this project, using [nvchecker].

It contains a script, designed to run periodically on a server, which runs
`nvchecker` using the latest configuration from this repo and then posts a
message to a Matrix Chat room, if `nvcmp` reports any new versions.


## Howto

Install `nvchecker`, e.g. via `pipx`:

```con
PYTHON=python3.9
$PYTHON -m pip install --user pipx
pipx install "nvchecker[pypi]"
```

Install Python dependencies:

```con
$PYTHON -m pip install --user appdirs tabulate matrix-nio
```

Clone this repository and set up the `nvchecker` sub-directory as the
`nvchecker` configuration directory:

```con
git clone https://github.com/osam-cologne/archlinux-proaudio
mkdir -p ~/.config
ln -s ../archlinux-proaudio/nvchecker ~/.config
ln -s archlinux-proaudio.toml ~/.config/nvchecker/nvchecker.toml
```

Copy the configuration file template for the `nvchecker-notify-matrixchat.py`
script and make it user-read- and -writeable only:

```con
cd ~/.config/nvchecker/
cp nvchecker-notify-matrixchat.json.tmpl nvchecker-notify-matrixchat.json
chmod 600 nvchecker-notify-matrixchat.json
```

... and open `nvchecker-notify-matrixchat.json` for editing. Change the
`user_id` and `password` to the correct credentials for the Matrix Chat Bot
user account (this user must have a matching acount on the given Matrix server
and have joined the `archlinux-proaudio` room).

```
{
    "homeserver": "https://sonoj.org",
    "password": "<change here>",
    "room_id": "!AkWpRHuPJQwVbEpayh:sonoj.org",
    "template": "{table}"
    "user_id": "@bot-archlinux-proaudio:sonoj.org",
}
```

Finally, add an entry to the user's crontab to run the `run-nvchecker.cron`
script periodically (e.g. every day):

```con
crontab -e
```

```cron
SHELL=/bin/bash
NVCHECK=$HOME/.config/nvchecker/run-nvchecker.cron
* 12 * * * test -x $NVCHECK && $NVCHECK >> $HOME/logs/run-nvchecker.log 2>&1
```


[nvchecker]: https://github.com/lilydjwg/nvchecker

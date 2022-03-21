# nvchecker for Archlinux-ProAudio

This directory contains a setup to check for new versions of software, which is
packaged by this project, using [nvchecker].

It contains a script, designed to run periodically on a server, which runs
`nvchecker` using the latest configuration from this repo and then posts a
message to a Rocket Chat room, if `nvcmp` reports any new versions.


## Howto

Install `nvchecker`, e.g. via `pipx`:

```con
PYTHON=python3.9
$PYTHON -m pip install --user pipx
pipx install "nvchecker[pypi]"
```

Install Python dependencies:

```con
$PYTHON -m pip install --user appdirs tabulate rocket-python
```

Clone this repository and set up the `nvchecker` sub-directory as the
`nvchecker` configuration directory:

```con
git clone https://github.com/osam-cologne/archlinux-proaudio
mkdir -p ~/.config
ln -s ../archlinux-proaudio/nvchecker ~/.config
ln -s archlinux-proaudio.toml ~/.config/nvchecker/nvchecker.toml
```

Copy the configuration file template for the `nvchecker-notify-rocketchat.py`
script and make it user-readable only:

```con
cd ~/.config/nvchecker/
cp nvchecker-notify-rocketchat.ini.tmpl nvchecker-notify-rocketchat.ini
chmod 600 nvchecker-notify-rocketchat.ini
```

... and open `nvchecker-notify-rocketchat.ini` for editing. Change the
`username` and `password` to the correct credentials for the Rocket Chat Bot
user account.

```
[notify-rocketchat]
room = ArchlinuxProAudioRepository
server_url = https://chat.sonoj.org/
username = BOT-arch.osamc.de
password = <change here>
[...]
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

# Announcing the Unofficial Pro-Audio Arch Package Repository (Beta Phase)

**Published:** 2022-04-15

## Where?

<https://arch.osamc.de/>


## What?

An actively maintained binary package repo for Arch Linux of free and open
source pro-audio software.

The repository only provides packages that are not already in the official Arch
Linux repository.

The repository is maintained and tested for both x86_64 and aarch64 (Arch Linux
ARM) architectures.


## Why?

1. We are convinced that Arch Linux is currently the best free platform for
   audio production and we want to help improving it further.
2. Having more up-to-date and easy to install packages of useful audio
   production software is always a good thing.
3. The pro-audio packages in the `extra` and `community` package repositories
   are currently maintained by only one person. We want to distribute the
   workload and spread the packing expertise between more people and decrease
   the "bus-factor".
4. We want to create packages, which can eventually be migrated to the official
   repositories with no or minimal changes. We do not intend to duplicate the
   packaging efforts from the official repos.
5. This repository can be considered a place for learning and testing proper
   audio packaging. It's not a "rogue operation", but was even created with
   guidance of [dvzrv](https://archlinux.org/people/developers/#dvzrv).
6. Reproducible, trustworthy binary packages are fast to install and convenient
   to update with just pacman; not requiring unsupported AUR helper programs.
   Also keep in mind that a rebuild of package may be required when its shared
   library dependencies are updated, not only when the package itself is updated,
   which can only be offered by a binary repository.

## How?

See the web site for instructions on how to add the repository to your Arch
System (or derivatives). The repository is also listed on the [Unofficial
user repositories] page on the Arch Wiki.

We are still stabilizing the build process and packaging conventions. While this
is going on, we consider the repository to be in a *Beta quality stage*. We
currently have around two dozen projects packaged and ready to install and plan
to add many more over time.

We try to announce important changes on IRC (`#archlinux-proaudio` on
`irc.libera.chat`) and always keep the information on the Arch Wiki page up to
date.

**Note:** *Our build process is currently not based on the official Arch Linux
`devtools`, but we adhere strictly to the Arch Packaging guidelines and test all
package builds via our CI. With the Arch Packaging infrastructure expected to
evolve significantly in the near future, we plan to adapt our tooling to
whatever the outcome of that will be.


## Contributing

Contributions are welcome! To suggest software for inclusion in the repo open a
GitHub issue.


### PKGBUILD and CI Code Repository and Issue Tracker:

https://github.com/osam-cologne/archlinux-proaudio


### Team-Chat

Discussion and coordination of the project happens on the Sonoj Rocket Chat
instance. If you are interested in helping out or have questions or suggestions,
join the general chat room (no registration required, English):

<https://chat.sonoj.org/channel/english>


[Unofficial user repositories]: https://wiki.archlinux.org/title/Unofficial_user_repositories#proaudio

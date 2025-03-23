# Waterleaf icon theme

Waterleaf is a spiritual successor to the Debonaire/Paper-Q4OS icon theme. It was created because the development of that icon theme had grown beyond the scope of the Q4OS Linux project. Further development has continued to be targeted towards Q4OS and the Trinity/Plasma desktop environments, but is also suitable for other distributions and DEs.

Waterleaf is currently based primarily on Paper icons by Sam Hewitt. It also mixes application icons from the Deepin and Papirus icon themes with original work (mostly TDE specific icons).

An experimental branch was introduced by the Q4OS Team in July 2020 with the intent to rebase on Papirus with Q4OS-specific changes being overlaid. This had the advantage of incorporating the work of a larger team with a faster development pace and moving towards all icons being in svg format. Waterleaf will continue to differentiate itself by focusing on Q4OS, Trinity and Plasma while expanding and refining icons specific to those projects.

## Requirements

The requirements to generate the complete theme and build packages on Q4OS are:

- debhelper (>=9~)
- git
- make
- q4os-devpack-base
- scour
- tqt3-dev-tools

## Generating the complete theme and building packages

To generate the complete Waterleaf icon theme, simply run as a user:

```$ sh 99_generate_iconset.sh```

To build packages for Debian and Q4OS, run:

```$ dpkg-buildpackage -b -uc -us -tc```

## Copying or reusing
- "[Waterleaf Icons](https://github.com/jaerrib/waterleaf-icon-theme)" by [John Beers](https://github.com/jaerrib/) licensed under [CC BY-SA 4.0](http://creativecommons.org/licenses/by-sa/4.0/)
- Original Debonaire/Paper-Q4OS icons by [Q4OS Team](https://github.com/q4osteam) licensed under [CC BY-SA 4.0](http://creativecommons.org/licenses/by-sa/4.0/)
- "[Paper Icons](http://snwh.org/paper/icons)" by [Sam Hewitt](http://samuelhewitt.com/) licensed under [CC BY-SA 4.0](http://creativecommons.org/licenses/by-sa/4.0/)
- "[Deepin Icons](https://github.com/linuxdeepin/deepin-icon-theme)" licensed under [GPLv3](https://www.gnu.org/licenses/gpl-3.0.html)
- "[Papirus Icons]( https://git.io/papirus-icon-theme)" licensed under [GPLv3](https://www.gnu.org/licenses/gpl-3.0.html)

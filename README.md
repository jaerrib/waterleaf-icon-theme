# Waterleaf icon theme
Waterleaf is a spiritual successor to the Debonaire/Paper-Q4OS icon theme. It was created because the development of that icon theme has grown beyond the scope of the Q4OS Linux project. Further development will continue to be targeted towards Q4OS and the  Trinity and Plasma desktop environments, but will ultimately be suitable for other distributions and DEs.

Waterleaf is based primarily on Paper icons by Sam Hewitt. It also mixes application icons from the Deepin and Papirus icon themes with original work (mostly TDE specific icons). 

## Copying or reusing
- "[Waterleaf Icons](https://github.com/jaerrib/waterleaf-icon-theme)" by [John Beers](https://github.com/jaerrib/) licensed under [CC-SA-4.0](http://creativecommons.org/licenses/by-sa/4.0/)
- Original Debonaire/Paper-Q4OS icons by [Q4OS Team](https://github.com/q4osteam) licensed under [CC-SA-4.0](http://creativecommons.org/licenses/by-sa/4.0/)
- "[Paper Icons](http://snwh.org/paper/icons)" by [Sam Hewitt](http://samuelhewitt.com/) licensed under [CC-SA-4.0](http://creativecommons.org/licenses/by-sa/4.0/)
- "[Deepin Icons](https://github.com/linuxdeepin/deepin-icon-theme)" licensed under [GPLv3](https://www.gnu.org/licenses/gpl-3.0.html)
- "[Papirus Icons]( https://git.io/papirus-icon-theme)" licensed under [GPLv3](https://www.gnu.org/licenses/gpl-3.0.html)

## Current issues:
- Mixed styles *(Example: Shadows differ between Paper, Deepin & Papirus; original icons closer to Elementary shadow style)*
- Mixed formats *(Mix of png and svg)*
- Mixed color pallets *(Paper, Elementary & Material design coloration)*
- Incomplete for TDE *(Falls back to hicolor in some cases (Example: devices & some control panel settings)*
- Sizing variations & fractional pixels lead to blurriness for screen rendering
- Mixed index.theme structure
- Icon locations don't always adhere to freedesktop standards
- Monochrome & color used inconsistently
- Not optimized for some DEs

## Project goals:
- Decide on overall style & color pallet
- Rework existing icons according to style/pallet decision
- Replace all png files with svg variations
- Fill in icon gaps in TDE
- Add additional icons as needed
- Address structure issues *(Possibly use Breeze-icon-theme as an example)*

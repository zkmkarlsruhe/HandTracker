Hello Demo
==========

Copyright (c) 2021 Dan Wilcox.

Detect simple wave gesture and show a greeting in one of 10+ languages.

Usage
-----

1. start hand tracker
2. run `main.lua` in loaf, ie. drag and drop script onto loaf.app
3. wave

After the greeting is shown, the wave detection will wait a bit before checking for the next wave.

OSC Communication
-----------------

```
tracker --OSC--> main.lua
```

tracker:
* send address: "localhost"
* send port: 9999

main.lua
* receive port: 9999

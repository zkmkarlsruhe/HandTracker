Synth Demo
==========

Copyright (c) 2021 Dan Wilcox.

Simple additive synth control:
* detect hand to engage envelope
* ping gesture to "squeeze" pitch

Usage
-----

1. start hand tracker
2. open `synth.pd` in Pure Data & enable the listen toggle box

OSC Communication
-----------------

```
tracker --OSC--> synth.pd
```

tracker:
* send address: "localhost"
* send port: 9999

synth.pd
* receive port: 9999

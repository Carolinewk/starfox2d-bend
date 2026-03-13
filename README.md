# Starfox 2D on Bend2

This workspace contains a standalone copy of `app_starfox_2d.bend` ported from
`studiovibi/Bend2/demo/` to run against the current Bend2 compiler and bundled
prelude.

## Run

```sh
bend app_starfox_2d.bend --no-strict
```

## Compile To HTML

```sh
bend app_starfox_2d.bend --no-strict --to-web > starfox_2d.html
```

`--no-strict` is currently required because the original game uses many
non-case-tree definitions that the new Bend2 strict validator rejects by
default.

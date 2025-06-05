# Convert PNG Sequence to Transparent Video

This tool convert a .png sequence (e.g. render.1.png, render.2.png, ...) to a transparent video (.mov + .webm) with alpha channel, for use in all modern web browsers.

## Usage

```bash
$ npx convert-png-sequence-to-transparent-video

Usage: convert-png-sequence-to-transparent-video -i pattern [-o directory] [-f fps] [-h height] [-q_mov quality] [-q_webm quality]

Required:
  -i pattern    Input file pattern (e.g., 'sequence.%d.png')

Optional:
  -o directory  Output directory (defaults to current directory)
  -f fps        Framerate (default: 24)
  -h height     Output height in pixels (width scales automatically)
  -q_mov quality Quality for MOV output (default: 15, min: 0, max: 64, lower is better)
  -q_webm quality Quality for WebM output (default: 10, min: 0, max: 63, lower is better)

Example:
  convert-png-sequence-to-transparent-video -i 'sequence.%d.png' -o ~/Desktop/output -f 30 -h 720 -q_mov 20 -q_webm 40

Creates both .webm (Chrome/Firefox) and .mov (Safari) with transparency
```

## Example

### Convert

Let's see we have a directory `~/Desktop/pngs/` with the following files:

```
my_render.1.png
my_render.2.png
...
my_render.200.png
```

Then run the tool as follows:

```bash
$ npx convert-png-sequence-to-transparent-video \
  -i "~/Desktop/pngs/my_render.%1.png" \
  -o "~/Desktop/" \
  -f 30 \
  -h 720
```

This will create two files, `my_render.webm` and `my_render.mov` in `~/Desktop`. Both with `30` frames per second, and a height of `720` pixels.

### HTML

```xhtml
<video>
  <source src="output.mov"  type='video/mp4; codecs="hvc1"'> <!-- Safari on macOS & iOS -->
  <source src="output.webm" type="video/webm"> <!-- Chrome, Firefox -->
</video>
```
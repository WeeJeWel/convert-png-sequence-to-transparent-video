#!/bin/bash

# Function to display usage
show_usage() {
  binary=$(basename "$0")
  echo "Usage: $binary -i pattern [-o directory] [-f fps] [-h height] [-q_mov quality]"
  echo ""
  echo "Required:"
  echo "  -i pattern    Input file pattern (e.g., 'sequence.%d.png')"
  echo ""
  echo "Optional:"
  echo "  -o directory  Output directory (defaults to current directory)"
  echo "  -f fps        Framerate (default: 24)"
  echo "  -h height     Output height in pixels (width scales automatically)"
  echo "  -q_mov quality Quality for MOV output (default: 15, min: 0, max: 64)"
  echo ""
  echo "Example:"
  echo "  $binary -i 'sequence.%d.png' -o ~/Desktop/output -f 30 -h 720 -q_mov 20"
  echo ""
  echo "Creates both .webm (Chrome/Firefox) and .mov (Safari) with transparency"
  exit 1
}

# Check if ffmpeg is installed
if ! command -v ffmpeg &>/dev/null; then
  echo "Error: ffmpeg is not installed. Please install it first."
  exit 1
fi

# Default values
input_pattern=""
output_dir="$PWD" # Default to current directory
framerate=24
height="" # Empty by default, meaning no resize
q_mov=15 # Default quality for MOV

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -i) input_pattern="$2"; shift 2 ;;
    -o) output_dir="$2"; shift 2 ;;
    -f) framerate="$2"; shift 2 ;;
    -h) height="$2"; shift 2 ;;
    -q_mov) q_mov="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; show_usage ;;
  esac
done

# Show usage if no arguments or no input pattern
if [ -z "$input_pattern" ]; then
  show_usage
fi

# Expand tilde in paths
input_pattern="${input_pattern/#\~/$HOME}"
output_dir="${output_dir/#\~/$HOME}"

# Get just the filename without path and remove the .%d.png part
output_base=$(basename "$input_pattern")
output_base="${output_base/.%d.png/}"

# Get the pattern base name (everything before %d)
base_name="${input_pattern%%%d*}"
# Get the extension (everything after %d)
extension="${input_pattern#*%d}"

# Normalize output directory path (resolve .. and .)
output_dir=$(cd "$output_dir" 2>/dev/null && pwd || echo "$output_dir")

# Create output directory if it doesn't exist
mkdir -p "$output_dir"

# Get the first frame number using expanded path
first_frame=$(ls "${base_name}"*"${extension}" | head -n 1 | grep -o '[0-9]\+' | head -n 1)
if [ -z "$first_frame" ]; then
  echo "Error: Could not determine first frame number from pattern: $input_pattern"
  exit 1
fi

# Prepare scale filter
scale_filter=""
if [ ! -z "$height" ]; then
  scale_filter="-vf scale=-2:$height"
fi

echo "Starting WebM conversion..."
# Create WebM with VP9
ffmpeg -framerate $framerate \
  -start_number $first_frame \
  -i "$input_pattern" \
  $scale_filter \
  -c:v libvpx-vp9 \
  -b:v 2M \
  -pix_fmt yuva420p \
  -auto-alt-ref 0 \
  -y \
  "${output_dir}/${output_base}.webm"

echo "Starting MOV conversion..."
# Create compressed ProRes with alpha
ffmpeg -framerate $framerate \
  -start_number $first_frame \
  -i "$input_pattern" \
  $scale_filter \
  -c:v prores_ks \
  -profile:v 4444 \
  -alpha_bits 8 \
  -pix_fmt yuva444p \
  -q:v $q_mov \
  -y \
  "${output_dir}/${output_base}.mov"

if [ $? -eq 0 ]; then
  echo "Conversion complete! Created:"
  echo "  ${output_dir}/${output_base}.webm"
  echo "  ${output_dir}/${output_base}.mov"
else
  echo "Error occurred during conversion"
  exit 1
fi

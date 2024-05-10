# godot-zig-examples
Examples for godot-zig

## Build

1. git clone --recursive https://github.com/godot-zig/godot-zig-examples
2. zig build bind
3. godot -e --path ./project
4. zig build run

## Options

1. -Doutput=<generated_file_path>   #default: zig build bind -Doutput=./gen
2. -Dprecision=<double|float>       #default: zig build bind -Dprecision=float
3. -Darch=<32|64>                   #default: zig build bind -Darch=64
4. -Dgodot=<godot_cmd>              #default: zig build bind -Dgodot=godot

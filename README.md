# Ping Pong in x86-64 Assembly (NASM, Linux)

A simple text-based 2D ping pong game for the terminal, written in x86-64 NASM assembly for Linux.

## Controls
- `W`: Move left paddle up
- `S`: Move left paddle down
- `Q`: Quit

The right paddle is controlled by a simple AI.

## Requirements
- Linux (x86-64)
- NASM assembler

## Build
```
make
```

## Run
```
make run
```

## Clean
```
make clean
```

## Notes
- The game runs in your terminal. Use `W` and `S` to move your paddle.
- The right paddle is AI-controlled.
- The game uses raw terminal mode for real-time input. If your terminal is left in a weird state, run `stty sane`. 
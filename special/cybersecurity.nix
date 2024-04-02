{ lib, pkgs, ...}:

let
  cutterWithPlugins = pkgs.cutter.withPlugins (ps: with ps; [ jsdec rz-ghidra sigdb ]);
in
{
  home.packages = with pkgs; [
      cutterWithPlugins
      iaito
      gdb
      ltrace
      strace
      radare2
      ghidra
      heaptrack
      obsidian
   ];
}


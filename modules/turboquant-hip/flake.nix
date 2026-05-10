{
  description = "llama.cpp with TurboQuant HIP/ROCm support";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    turboquant-src = {
      # We must point to the specific branch where the ROCm port lives
      url = "github:domvox/llama.cpp-turboquant-hip?ref=feature/turboquant-hip-port-clean";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, turboquant-src }: 
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    packages.${system}.default = (pkgs.llama-cpp.override {
      rocmSupport = true;
    }).overrideAttrs (old: {
      # Change this to a plain number so C++ doesn't try to do math on it
      version = "9999"; 
      src = turboquant-src;
      npmDepsHash = "sha256-eeftjKt0FuS0Dybez+Iz9VTVMA4/oQVh+3VoIqvhVMw="; 
      
      cmakeFlags = (old.cmakeFlags or []) ++ [
        "-DAMDGPU_TARGETS=gfx1201"
        "-DLLAMA_WERROR=OFF"
        "-DLLAMA_BUILD_NUMBER=9999" # Force the build number in CMake
      ];
    });ackages.${system}.default = (pkgs.llama-cpp.override {
      rocmSupport = true;
    }).overrideAttrs (old: {
      version = "turboquant-hip-experimental";
      src = turboquant-src;
      npmDepsHash = "sha256-eeftjKt0FuS0Dybez+Iz9VTVMA4/oQVh+3VoIqvhVMw="; 
      # Force the compilation for the RDNA 4 architecture
      cmakeFlags = (old.cmakeFlags or []) ++ [
        "-DAMDGPU_TARGETS=gfx1201"
        "-DLLAMA_WERROR=OFF"
      ];
    });
  };
}

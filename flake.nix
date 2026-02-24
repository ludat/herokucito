{
  inputs = {
    utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      utils,
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          allowUnfree = true;
        };
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            (wrapHelm kubernetes-helm {
              plugins = with pkgs.kubernetes-helmPlugins; [
                helm-unittest
              ];
            })
          ];
        };
      }
    );
}

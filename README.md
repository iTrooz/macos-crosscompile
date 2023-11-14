This project contains an image capable crosscompiling for MacOS ARM64 (and possibly x64, but you'll need to tweak it a bit). The Dockerfile to generate the image can be found in the folder crosscompile/ and the image can be built using the command `make crosscompile_img` (see the root Makefile)

You can also use the docker image (without the XCode SDK embedded): https://github.com/itrooz/macos-crosscompile/pkgs/container/macos-crosscompile

**By building or using the image with the XCode SDK (which is required for using the compilers), you agree to the [XCode license terms](https://www.apple.com/legal/sla/docs/xcode.pdf). Please ensure you have read and understood them first**

Note that this project has been made mainly to introduce MacOS ARM64 builds to https://github.com/WerWolv/ImHex/.
If you are interested in this project taking a more official/general turn, please open an issue

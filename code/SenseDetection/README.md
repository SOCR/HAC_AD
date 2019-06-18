# Building the .jar File
1. Create `.jar` files for `SenceDisambiuation/*` and `SenseDetection/*` using:
   1. `jar cf SenseDetection.jar SenseDetection/`
   1. `jar cf SenceDisambiuation.jar SenceDisambiuation/`
1. Move these to `lib/`: `mv S*.jar lib/`
1. Create `.jar` file for `MetaMapWrapper/*`: `jar cf MetaMapWrapper.jar MetaMapWrapper/`
1. Build a `jar` for the current directory using the manifest: `jar cmf MANIFEST.MF TightSenseClustering.jar .` **Note:** this depends on being invoked from `HAC_AD/code/SenseDetection`.

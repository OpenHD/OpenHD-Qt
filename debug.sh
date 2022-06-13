./build.sh pi-bullseye |& tee >(ts "%d-%m-%y %H_%M_%S" > build.log)

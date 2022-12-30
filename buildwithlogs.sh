TYPE=$1

VER2=$(git rev-parse --short HEAD) 
echo ${VER2}

screen 
bash build.sh $TYPE |& tee >(ts "%d-%m-%y %H_%M_%S" > build$(date '+%m%d%H%M')-${VER2}.log)

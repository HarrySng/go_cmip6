#!/bin/bash

# Directory structure
# ./
#	downscale.sh
#	rawnc/
#		getnc.py
#		sproket
#		target_grid
#	ncfiles/

# This script runs in parent directory

cd rawnc

for mdl in CanESM5 NorESM2-LM IPSL-CM6A-LR EC-Earth3 ACCESS-CM2; do
	for exp in historical ssp245; do
		for var in pr tasmax tasmin; do
			python getnc.py $var $exp $mdl
			./sproket -config params.json # a1
			while [ ! -e *.part]; do # a2
				:
			done
		done
	done
done

# All files have been downloaded by the above loop
# Now subset and downscale and move to another directory

for file in *.nc; do
	fname=$(echo "$file" | cut -d'.' -f 1)
	ncks -d lat,43.,54. -d lon,65.,95. $file -O ${fname}_subset.nc
	rm -f $file
	cdo remapbil,target_grid ${fname}_subset.nc ${fname}_d.nc
	rm ${fname}_subset.nc
	mv ${fname}_d.nc ../ncfiles/${fname}_d.nc
done


# a1
	# sprocket will start downloading 1 or multiple files
	# depending on whether that scenario has just 1 nc file
	# or it is split into multiple nc files.

# a2
	# When files are being downloaded, they are named as 
	# .part. Once the download is complete, they are named
	# to .nc
	# So, this command checks whether any .part file is 
	# remaining in the directory. This way the next
	# iteration only starts when all files from one
	# iteration have been fulle downloaded.
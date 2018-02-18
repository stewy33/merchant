#!/bin/bash
cd .packages/$*/$*
pwd
mmc --make --no-libgrade --libgrade hlc.gc --install-prefix ../ lib$*.install
cd ../../..

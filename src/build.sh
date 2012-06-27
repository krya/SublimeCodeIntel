#!/bin/bash

reset(){
	rm -rf /tmp/pcre-8.21
	rm -rf cElementTree-1.0.5-20051216
	rm -rf silvercity
	rm -rf scintilla
	rm -rf sgmlop-1.1.1-20040207
}

reset

rm -rf logs

CURRENT_PATH=`pwd`
LOGDIR=$CURRENT_PATH/logs
mkdir logs

# In Linux, Sublime Text's Python is compiled with UCS4:
if [ $OSTYPE = "linux-gnu" ]; then
	if [ `uname -m` == 'x86_64' ]; then
		export CFLAGS='-fPIC -DPy_UNICODE_SIZE=4 -I /tmp/pcre-8.21'
	else
		export CFLAGS='-DPy_UNICODE_SIZE=4 -I /tmp/pcre-8.21'
	fi
fi

export LDFLAGS='-L/tmp/pcre-8.21/.libs'


echo "building pcre";
tar xzf pcre-8.21.tar.gz -C /tmp/ && \
cd /tmp/pcre-8.21 && \
./configure --disable-shared > $LOGDIR/pcre_config.log && \
mkdir .libs && \
make > $LOGDIR/pcre.log 2>&1 && \
cd $CURRENT_PATH && \

echo "building sgmlop" && \
unzip sgmlop-1.1.1-20040207.zip > /dev/null && \
cd sgmlop-1.1.1-20040207 && \
cat ../sgmlop*.patch | patch -sup1 && \
python setup.py build > $LOGDIR/sgmlop.log 2>&1 && \
cd .. && \
tar xzf scintilla.tar.gz && \
find . -name "LexTCL*" -delete && \

echo "patching scintilla" && \
cd scintilla && \
cat ../scintilla.patch/*.patch | patch -sup0 && \
cp -f ../scintilla.patch/lexers/* lexers/ && \
cd include && python HFacer.py > /dev/null && \
cd ../.. && \

echo "building silvercity" && \
tar xzf silvercity.tar.gz && \
cd silvercity && \
cat ../SilverCity.patch/*.patch | patch -sup1 && \
cp -f ../SilverCity.patch/*.py PySilverCity/SilverCity/ && \
python setup.py build > $LOGDIR/silvercity.log 2>&1 && \
cd .. && \

echo "building cElementTree" && \
tar xzf cElementTree-1.0.5-20051216.tar.gz && \
cd cElementTree-1.0.5-20051216 && \
cat ../cElementTree-1.0.5-20051216.patch/*.patch | patch -sup1 && \
python setup.py build > $LOGDIR/cElementTree.log 2>&1 && \
cd .. && \
find . -type f -name sgmlop.so -exec cp {} ../libs/_local_arch \; && \
find . -type f -name _SilverCity.so -exec cp {} ../libs/_local_arch \; && \
find . -type f -name ciElementTree.so -exec cp {} ../libs/_local_arch \; && \
reset && \
echo "Done!" && \
strip ../libs/_local_arch/*.so >> /dev/null 2>&1 || \
echo "build failed"

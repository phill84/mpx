#!/usr/bin/env python
#
# This script recursively copies all dependencies of libmpv.dylib
# which are in /usr/local to lib/ and modifies id and install
# path to @rpath
#
import os
import re
import shutil
import subprocess
import sys

scriptpath=os.path.dirname(os.path.realpath(__file__))
os.chdir(scriptpath)

def patch_lib(libpath, iteration):
	lib=os.path.basename(libpath)
	print '%schecking %s...' % ('>' * iteration, lib)
	p = subprocess.Popen(['otool', '-L', libpath], stdout=subprocess.PIPE)
	r = p.wait()
	if r != 0:
		sys.exit('failed to execute otool')
	line = p.stdout.readline()
	while line:
		process_otool_output(libpath, lib, line, iteration)
		line = p.stdout.readline()

def process_otool_output(libpath, lib, line, iteration):
	m = re.match('^\s+(/usr/local/[^\s]+)', line)
	if not m:
		return
	deppath = m.group(1)
	dep = os.path.basename(deppath)
	rpath = '@rpath/%s' % dep
	p = None
	if lib == dep:
		print '%s   change id of %s to %s' % ('>' * iteration, dep, rpath)
		p = subprocess.Popen(['install_name_tool', '-id', rpath, libpath])
	else:
		print '%s   change install path of %s to %s on %s' % ('>' * iteration, dep, rpath, libpath)
		p = subprocess.Popen(['install_name_tool', '-change', deppath, rpath, libpath])

	r = p.wait()
	if r != 0:
		sys.exit('failed to patch %s' % (dep, libpath))

	if not os.path.isfile('lib/%s' % dep):
		deppath = get_real_file(deppath)
		destpath = 'lib/%s' % dep
		print '%s   copy %s to %s' % ('>' * iteration, deppath, destpath)
		shutil.copyfile(deppath, destpath)
		patch_lib(destpath, iteration + 1)

def get_real_file(path):
	if not os.path.islink(path):
		return path
	realfile=os.readlink(path)
	if not os.path.isabs(realfile):
		realfile=os.path.normpath(os.path.join(os.path.dirname(path), realfile))

	if os.path.islink(realfile):
		return get_real_file(realfile)
	else:
		return realfile

libmpv='lib/libmpv.dylib'

if not os.path.isfile(libmpv):
	sys.exit('cannot find %s' % libmpv)

patch_lib(libmpv, 0)

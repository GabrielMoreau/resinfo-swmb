#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# ----------------------------------------------------------------------
#
# This file is part of project CNRS RESINFO SWMB
# Copyright (C) 2017-2020, Disassembler <disassembler@dasm.cz>
# Copyright (C) 2020-2026, CNRS, France
#
# License: MIT License (Same as project Win10-Initial-Setup-Script)
# Homepage: https://gitlab.in2p3.fr/resinfo-gt/swmb/resinfo-swmb
#
# SWMB is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# MIT License for more details.
#
# Authors:
#  2021 - Gabriel Moreau (CNRS / LEGI)
#
# ----------------------------------------------------------------------

from setuphelpers import *

uninstallkey = []

setup_path = makepath(programfiles64,'SWMB')

def install():
	version = control.version.split('-',1)[0]
	install_exe_if_needed("SWMB-Setup-%s.exe" % version, '/S')

def uninstall():
	run(r'"%s" /S' % makepath(setup_path, r'Uninst.exe'))

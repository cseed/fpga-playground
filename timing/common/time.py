#!/usr/bin/python

from __future__ import print_function
import sys
import subprocess
import re
import math

family = sys.argv[1]

print('family = ', family)

if family == 'artix7':
    dev = 'xc7a35ticsg324-1l'
elif family == 'ku':
    dev = 'xcku035-ffva1156-2-e'
else:
    raise ValueError('unknown family: {}'.format(family))

upper_bound = None
lower_bound = 0.0

attempt = 3.0

def round3(x):
    r = int(x * 1000.0) / 1000.0
    if (x > r):
        return r + 0.001
    else:
        return r
        
# do binary search to find best timing to nearest 0.1ns
while True:
    print('try period = {}ns'.format(attempt))

    xdc_file = 'tmp/main_{}_{}.xdc'.format(family, attempt)
    synth_file = 'tmp/synth_{}_{}.tcl'.format(family, attempt)
    log_file = 'tmp/synth_{}_{}.log'.format(family, attempt)

    with open(xdc_file, 'w') as fp:
        fp.write('''
create_clock -add -name sys_clk_pin -period {} [get_ports {{ sys_clk }}]
'''.format(attempt))

    with open(synth_file, 'w') as fp:
        fp.write('''
read_verilog main.v
read_xdc {}

synth_design -part {} -top main
opt_design
place_design
route_design

report_utilization
report_timing
'''.format(xdc_file, dev))

    rc = subprocess.call('vivado -nojournal -mode batch -source {} -log {} >/dev/null 2>&1'.format(synth_file, log_file),
                         shell=True)
    if rc != 0:
        raise ValueError('vivado returned non-zero exit code: {}'.format(rc))

    p = subprocess.Popen('grep ^Slack {}'.format(log_file), shell=True, stdout=subprocess.PIPE)
    (stdout, stderr) = p.communicate()

    if p.returncode != 0:
        raise ValueError('Slack line not found in log')

    m = re.match('^Slack \\(MET\\) :\\s*([0-9\\.]+)ns', stdout)
    if m:
        slack = float(m.group(1))
        upper_bound = round3(attempt - slack)
        print('    period = {}ns = {} - {} MET'.format(upper_bound, attempt, slack))
    else:
        m = re.match('^Slack \\(VIOLATED\\)', stdout)
        if m:
            print('    period = {}ns VIOLATED'.format(attempt))
            lower_bound = attempt
        else:
            raise ValueError('Slack line not found in grep output')

    if upper_bound and upper_bound - lower_bound < 0.1:
        print('    period = {}ns BEST, freq = {}MHz'.format(upper_bound, 1000.0 / upper_bound))
        break

    if upper_bound:
        attempt = round3((upper_bound + lower_bound) / 2.0)
    else:
        attempt = attempt * 2.0

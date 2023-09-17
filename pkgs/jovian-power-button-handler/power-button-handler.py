#!/usr/bin/env python3

# Modified from power-button-handler.py in jupiter-hw-support

import argparse
import evdev
import logging
import threading
import os
import sys
from typing import Optional

parser = argparse.ArgumentParser()
parser.add_argument(
    '--device',
    help='The PHYS attribute of the power button device',
    default='isa0060/serio0/input0',
)
parser.add_argument(
    '--check',
    help='Check that the device exists and exit',
    action='store_true',
)
parser.add_argument(
    '--command-wrapper',
    help='Prefix to add to all commands',
    default='',
)
parser.add_argument(
    '--short-press-command',
    help='The command to run with a short press',
    default='~/.steam/root/ubuntu12_32/steam -ifrunning steam://shortpowerpress',
)
parser.add_argument(
    '--long-press-command',
    help='The command to run with a long press',
    default='~/.steam/root/ubuntu12_32/steam -ifrunning steam://longpowerpress',
)

def find_device(phys: str) -> Optional[evdev.InputDevice]:
    for path in evdev.list_devices():
        device = evdev.InputDevice(path)
        if device.phys == phys:
            return device
        else:
            device.close()

    return None

def dump_devices():
    logging.info('Available devices:')
    for path in evdev.list_devices():
        device = evdev.InputDevice(path)
        logging.info(device)

def run_command(args: argparse.Namespace, command: str):
    if args.command_wrapper:
        command = f'{args.command_wrapper} {command}'

    logging.info(f'Running {command}')
    os.system(command)

if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)

    args = parser.parse_args()
    logging.info(f'Using power button device {args.device}')

    powerbuttondev = find_device(args.device)
    if not powerbuttondev:
        logging.error(f"Can't find power button {args.device}")
        dump_devices()
        sys.exit(1)

    if args.check:
        sys.exit(0)

    longpresstimer = None

    def longpress():
        run_command(args, args.long_press_command)
        global longpresstimer
        longpresstimer = None

    for event in powerbuttondev.read_loop():
        if event.type == evdev.ecodes.EV_KEY and event.code == 116: # KEY_POWER
            print(event)
            if event.value == 1:
                longpresstimer = threading.Timer(1.0, longpress)
                longpresstimer.start()
            elif event.value == 0:
                if longpresstimer != None:
                    run_command(args, args.short_press_command)
                    longpresstimer.cancel()
                    longpresstimer = None

    powerbuttondev.close()

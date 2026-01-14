#!/usr/bin/env python3
#  ________   __    __    ___  ___   _____  ___   ___________   __    __   
# /"       ) /" |  | "\  |"  \/"  | (\"   \|"  \ ("     _   ") /" |  | "\ 
#(:   \___/ (:  (__)  :)  \   \  /  |.\\   \    | )__/  \\__/ (:  (__)  :)
# \___  \    \/      \/    \\  \/   |: \.   \\  |    \\_ /     \/      \/ 
#  __/  \\   //  __  \\    /   /    |.  \    \. |    |.  |     //  __  \\ 
# /" \   :) (:  (  )  :)  /   /     |    \    \ |    \:  |    (:  (  )  :)
#(_______/   \__|  |__/  |___/       \___|\____\)     \__|     \__|  |__/ 
#
import sys
import math
import struct
import argparse
import signal
import os
import random
import time
import re

#######################################
# audio
SAMPLE_RATE = 44100
AMPLITUDE = float(0.5) 

#######################################
# voice engine sample = tone + tines -> adsr
class VoiceEngine:
    @staticmethod
    def get_adsr(sample_idx, total_samples, attack, decay, sustain_lvl, release):
        a_samples = int(total_samples * attack)
        d_samples = int(total_samples * decay)
        r_samples = int(total_samples * release)
        s_samples = total_samples - a_samples - d_samples - r_samples

        if sample_idx < a_samples:
            return sample_idx / a_samples
        elif sample_idx < a_samples + d_samples:
            return 1.0 - (1.0 - sustain_lvl) * (sample_idx - a_samples) / d_samples
        elif sample_idx < total_samples - r_samples:
            return sustain_lvl
        else:
            return sustain_lvl * (total_samples - sample_idx) / r_samples

    @staticmethod
    def tone_ep(freq, t, i, total):
        primary = math.sin(2 * math.pi * freq * t)
        tine = math.sin(2 * math.pi * freq * 2.001 * t) * 0.3
        env = VoiceEngine.get_adsr(i, total, 0.01, 0.2, 0.3, 0.2)
        return (primary + tine) * env

    @staticmethod
    def tone_mellow(freq, t, i, total):
        primary = math.sin(2 * math.pi * freq * t)
        tine1 = math.sin(2 * math.pi * freq * 1.48 * t) * 0.4
        tine2 = math.sin(2 * math.pi * freq * 3.001 * t) * 0.2
        env = VoiceEngine.get_adsr(i, total, 0.4, 0.1, 0.7, 0.4)
        return (primary + tine1 + tine2) * env

    @staticmethod
    def tone_noisy(freq, t, i, total):
        noise = random.uniform(-0.2, 0.2)
        wave = 0.5 if math.sin(2 * math.pi * freq * t) > 0 else -0.5
        env = VoiceEngine.get_adsr(i, total, 0.05, 0.1, 0.5, 0.4)
        return (wave + noise) * env

#######################################
# generate chunk of sound with given notes
def generate_chord_chunk(midi_notes, duration, tone_type):
    num_samples = int(duration * SAMPLE_RATE)
    mixed_buffer = [0.0] * num_samples
    
    tone_map = {
        "ep": VoiceEngine.tone_ep,
        "mellow": VoiceEngine.tone_mellow,
        "noisy": VoiceEngine.tone_noisy,
        "saw": lambda f, t, i, tot: 2.0 * (t * f - math.floor(0.5 + t * f)) * VoiceEngine.get_adsr(i, tot, 0.05, 0.05, 0.8, 0.1),
        "sine": lambda f, t, i, tot: math.sin(2 * math.pi * f * t) * VoiceEngine.get_adsr(i, tot, 0.1, 0.1, 0.8, 0.1)
    }
    render_func = tone_map.get(tone_type, tone_map["sine"])

    for midi_note in midi_notes:
        freq = midi_to_hz(midi_note)
        if freq is None:
            continue
        
        for i in range(num_samples):
            t = i / SAMPLE_RATE
            mixed_buffer[i] += render_func(freq, t, i, num_samples)

    output = []
    num_notes = max(1, len(midi_notes))
    for val in mixed_buffer:
        final_val = (val / num_notes) * AMPLITUDE
        final_val = max(-0.99, min(0.99, final_val))
        output.append(struct.pack('<h', int(final_val * 32767)))
        
    return b"".join(output)

#######################################
# SIGINT handler
def handle_broken_pipe():
    devnull = os.open(os.devnull, os.O_WRONLY)
    os.dup2(devnull, sys.stdout.fileno())
    sys.exit(0)

#######################################
# midi to Hz
def midi_to_hz(midi_note):
    if midi_note == -1:
        return None

    return 440.0 * (2.0 ** ((midi_note - 69) / 12.0))

#######################################
# read file, play notes
def play_loop(filename, tone):
    signal.signal(signal.SIGINT, signal.SIG_DFL)

    try:
        while True:
            with open(args.input, 'r') as f:
                for line in f:
                    line = line.strip()
                    if not line or line.startswith('#'): continue
                    
                    chord_match = re.match(r'\((.*?)\)\s+(.*)', line)
                    try:
                        if chord_match:
                            notes_str, duration = chord_match.groups()
                            midi_notes = [float(n) for n in notes_str.split()]
                            duration = float(duration)
                            chunk = generate_chord_chunk(midi_notes, duration, args.tone)
                        else:
                            parts = line.split()
                            midi_notes = [float(parts[0])]
                            duration = float(parts[1])
                            chunk = generate_chord_chunk(midi_notes, duration, args.tone)
                        
                        sys.stdout.buffer.write(chunk)
                        sys.stdout.buffer.flush()
                    except BrokenPipeError:
                        sys.stderr.close()
                        sys.exit(0)
                    except ValueError:
                        continue
            time.sleep(0.01)
    except KeyboardInterrupt:
        pass

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True)
    parser.add_argument("--tone", default="ep")
    parser.add_argument("--volume", default=1.0)
    args = parser.parse_args()

    AMPLITUDE *= float(args.volume)

    play_loop(args.input, args.tone)

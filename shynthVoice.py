#  ________   __    __    ___  ___   _____  ___   ___________   __    __   
# /"       ) /" |  | "\  |"  \/"  | (\"   \|"  \ ("     _   ") /" |  | "\ 
#(:   \___/ (:  (__)  :)  \   \  /  |.\\   \    | )__/  \\__/ (:  (__)  :)
# \___  \    \/      \/    \\  \/   |: \.   \\  |    \\_ /     \/      \/ 
#  __/  \\   //  __  \\    /   /    |.  \    \. |    |.  |     //  __  \\ 
# /" \   :) (:  (  )  :)  /   /     |    \    \ |    \:  |    (:  (  )  :)
#(_______/   \__|  |__/  |___/       \___|\____\)     \__|     \__|  |__/ 
#
#!/usr/bin/env python3
import sys
import math
import struct
import argparse
import time
import signal

#######################################
# audio
SAMPLE_RATE = 44100
AMPLITUDE = 0.5 

#######################################
# midi to Hz
def midi_to_hz(midi_note):
    return 440.0 * (2.0 ** ((midi_note - 69) / 12.0))

#######################################
# tone generator
class Oscillator:
    @staticmethod
    def sine(freq, t):
        return math.sin(2 * math.pi * freq * t)

    @staticmethod
    def saw(freq, t):
        return 2.0 * (t * freq - math.floor(0.5 + t * freq))

    @staticmethod
    def square(freq, t):
        return 0.5 if math.sin(2 * math.pi * freq * t) > 0 else -0.5

    @staticmethod
    def noisy(freq, t):
        import random
        return random.uniform(-0.1, 0.1) + (0.5 * math.sin(2 * math.pi * freq * t))

#######################################
def generate_sample(freq, duration, tone_type):
    num_samples = int(duration * SAMPLE_RATE)
    output = []
    
    wave_func = {
        "ep": Oscillator.sine,
        "sine": Oscillator.sine,
        "saw": Oscillator.saw,
        "sharp": Oscillator.square,
        "noisy": Oscillator.noisy,
        "mellow": Oscillator.sine
    }.get(tone_type, Oscillator.sine)

    for i in range(num_samples):
        t = i / SAMPLE_RATE
        envelope = 1.0
        if i < 500: envelope = i / 500  # Attack
        if i > num_samples - 500: envelope = (num_samples - i) / 500 # Release
        
        sample = wave_func(freq, t) * AMPLITUDE * envelope
        output.append(struct.pack('<h', int(sample * 32767)))
    
    return b"".join(output)


#######################################
def handle_broken_pipe():
    devnull = os.open(os.devnull, os.O_WRONLY)
    os.dup2(devnull, sys.stdout.fileno())
    sys.exit(0)

def play_loop(filename, tone):
    signal.signal(signal.SIGINT, signal.SIG_DFL)

    try:
        while True:
            with open(filename, 'r') as f:
                for line in f:
                    if line.startswith('#') or not line.strip():
                        continue
                    
                    # Format: MIDI_NOTE DURATION
                    # 69 0.5
                    try:
                        note, duration = map(float, line.split())
                        freq = midi_to_hz(note)
                        
                        audio_chunk = generate_sample(freq, duration, tone)
                        sys.stdout.buffer.write(audio_chunk)
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
    args = parser.parse_args()
    
    play_loop(args.input, args.tone)

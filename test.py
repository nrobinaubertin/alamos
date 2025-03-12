import sys
import subprocess
import time
import threading
import psutil


def monitor_memory(process, peak_mem_list):
    peak_mem = 0
    try:
        ps_process = psutil.Process(process.pid)
        while process.poll() is None:
            try:
                mem_info = ps_process.memory_info()
                current_mem = mem_info.rss  # Resident Set Size in bytes
                if current_mem > peak_mem:
                    peak_mem = current_mem
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                break
            time.sleep(0.001)
        # Final check after process exits
        try:
            mem_info = ps_process.memory_info()
            current_mem = mem_info.rss
            if current_mem > peak_mem:
                peak_mem = current_mem
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            pass
        peak_mem_list.append(peak_mem)
    except psutil.NoSuchProcess:
        peak_mem_list.append(0)


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 checker.py <executable>")
        sys.exit(1)

    executable = sys.argv[1]
    args = ["rnqknrpppppp............PPPPPPRNQKNR", "w"]
    actual_lines = []
    durations = []
    peak_mems = []

    for _ in range(41):
        start_time = time.time()
        process = subprocess.Popen(
            [executable] + args,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True,
        )
        peak_mem_list = []
        monitor_thread = threading.Thread(
            target=monitor_memory, args=(process, peak_mem_list)
        )
        monitor_thread.start()

        stdout, stderr = process.communicate()
        monitor_thread.join()

        duration = time.time() - start_time
        peak_mem = peak_mem_list[0] if peak_mem_list else 0

        if process.returncode != 0:
            print(f"Error running the executable (exit code {process.returncode}):")
            print(stderr.strip())
            sys.exit(1)

        actual_lines.append(stdout.strip())
        durations.append(duration)
        peak_mems.append(peak_mem)
        args = stdout.strip().split()

    expected_lines = [
        "rnqknrpppppp......P......PPPPPRNQKNR b",
        "rnqknrpp.ppp..p...P......PPPPPRNQKNR w",
        "rnqknrpp.ppp..p...PP......PPPPRNQKNR b",
        "rnqknrpp.ppp......Pp......PPPPRNQKNR w",
        "rnqknrpp.ppp......PP.......PPPRNQKNR b",
        "rn.knrpp.ppp......PP.......PPPRNqKNR w",
        "rn.knrpp.ppp......PP.......PPPRNK.NR b",
        "rn.k.rpp.ppp...n..PP.......PPPRNK.NR w",
        "rn.k.rpp.ppp...n..PP.....K.PPPRN..NR b",
        "rn.k.r.p.pppp..n..PP.....K.PPPRN..NR w",
        "rn.k.r.p.pppP..n..P......K.PPPRN..NR b",
        "r..k.r.p.pppn..n..P......K.PPPRN..NR w",
        "r..k.r.p.pppn..n..P.....K..PPPRN..NR b",
        ".r.k.r.p.pppn..n..P.....K..PPPRN..NR w",
        ".r.k.r.p.pppn..n..P...P.K..P.PRN..NR b",
        ".r.k.r.p.pppn.....P...P.K..PnPRN..NR w",
        ".r.k.r.p.pppn.....P..NP.K..PnPRN...R b",
        ".r.k.r.p..ppn..p..P..NP.K..PnPRN...R w",
        ".r.k.r.p..ppn..p..P...P.K..PnPRNN..R b",
        ".r.k.r....ppnp.p..P...P.K..PnPRNN..R w",
        ".r.k.r....ppnP.p......P.K..PnPRNN..R b",
        ".r.k.r....ppnP.p......P.K..P.PRNn..R w",
        ".r.k.r....ppnP.p......P.K..P.PRNR... b",
        "..rk.r....ppnP.p......P.K..P.PRNR... w",
        "..rk.r....ppnP.p..N...P.K..P.PR.R... b",
        "...k.r....ppnP.p..N...P.K..P.PR.r... w",
        "...k.r....ppnP.p..N...P.K..P.P..R... b",
        ".....r...kppnP.p..N...P.K..P.P..R... w",
        ".....r...kppnP.P..N.....K..P.P..R... b",
        ".....r....ppnP.k..N.....K..P.P..R... w",
        ".....r....ppnP.k..NK.......P.P..R... b",
        ".n...r....pp.P.k..NK.......P.P..R... w",
        ".n...r....pp.P.k..NK.......P.P....R. b",
        ".n..r.....pp.P.k..NK.......P.P....R. w",
        ".n..r.....pp.P.k..NK..R....P.P...... b",
        ".n...r....pp.P.k..NK..R....P.P...... w",
        ".n...r....pp.P.k...K..R...NP.P...... b",
        ".n...r...kpp.P.....K..R...NP.P...... w",
        ".n...r...kpp.P.....K.R....NP.P...... b",
        ".n...r....pp.P..k..K.R....NP.P...... w",
        ".n...r....pp.P..k..K..R...NP.P...... b",
    ]

    if len(actual_lines) != len(expected_lines):
        print(
            f"Line count mismatch. Expected {len(expected_lines)}, got {len(actual_lines)}"
        )
        sys.exit(1)

    for i in range(len(expected_lines)):
        actual = actual_lines[i].strip()
        expected = expected_lines[i].strip()
        if actual != expected:
            print(f"Mismatch at line {i + 1}:")
            print(f"Expected: {expected}")
            print(f"Got:      {actual}")
            sys.exit(1)

    print("Ok")
    print("\nPerformance Metrics:")
    total_duration = sum(durations)
    print(f"Total duration: {total_duration:.2f} seconds")
    print(f"Average duration per call: {total_duration / len(durations):.2f} seconds")
    print(f"Max duration: {max(durations):.2f} seconds")
    print(f"Min duration: {min(durations):.2f} seconds")

    peak_mems_kb = [mem / 1024 for mem in peak_mems if mem is not None]
    if peak_mems_kb:
        print(f"\nPeak Memory (RSS):")
        print(f"Average: {sum(peak_mems_kb) / len(peak_mems_kb):.2f} KB")
        print(f"Max: {max(peak_mems_kb):.2f} KB")
        print(f"Min: {min(peak_mems_kb):.2f} KB")
    else:
        print("\nNo memory data collected.")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
measure_rss_memory.py - Medidor determinístico de Pico de Memória RSS e Duração de Processo
Uso: python3 measure_rss_memory.py <comando...>
Exemplo: python3 measure_rss_memory.py pytest tests/test_perf.py
"""
import sys
import time
import subprocess
import os
import resource

if len(sys.argv) < 2:
    print("Uso: python3 measure_rss_memory.py <comando...>")
    sys.exit(1)

cmd = sys.argv[1:]
print(f"⏱️ Executando: {' '.join(cmd)}")

start_time = time.perf_counter()
env = {**os.environ, "LC_ALL": "C"}

# Usar /usr/bin/time -v (com LC_ALL=C para garantir output determinístico) ou fallback nativo via getrusage
try:
    res = subprocess.run(
        ["/usr/bin/time", "-v"] + cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        env=env,
    )
    duration = time.perf_counter() - start_time

    if res.stdout:
        print(res.stdout, end="" if res.stdout.endswith("\n") else "\n")

    # Extrair pico de RSS do stderr de /usr/bin/time
    max_rss_kb = None
    for line in res.stderr.splitlines():
        if "Maximum resident set size" in line:
            parts = line.split(":")
            if len(parts) >= 2:
                max_rss_kb = float(parts[1].strip())
                break

    if max_rss_kb is None:
        # Fallback POSIX via getrusage (em KB no Linux)
        rusage_rss = resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss
        max_rss_kb = float(rusage_rss)

    max_rss_mb = max_rss_kb / 1024.0

    print("\n--- RESULTADO DE MEDIÇÃO ---")
    print(f"Status:       {'SUCESSO (exit 0)' if res.returncode == 0 else f'FALHA (exit {res.returncode})'}")
    print(f"Duração:      {duration * 1000.0:.2f} ms ({duration:.3f} s)")
    print(f"Pico de RSS:  {max_rss_mb:.2f} MB")
    print("----------------------------")

    if res.returncode != 0:
        print("\nStderr do comando executado:")
        print(res.stderr)
        sys.exit(res.returncode)

except FileNotFoundError:
    res = subprocess.run(cmd, env=env)
    duration = time.perf_counter() - start_time
    rusage_rss_kb = float(resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss)
    print("\n--- RESULTADO DE MEDIÇÃO (fallback getrusage) ---")
    print(f"Status:       {'SUCESSO (exit 0)' if res.returncode == 0 else f'FALHA (exit {res.returncode})'}")
    print(f"Duração:      {duration * 1000.0:.2f} ms ({duration:.3f} s)")
    print(f"Pico de RSS:  {rusage_rss_kb / 1024.0:.2f} MB")
    print("-------------------------------------------------")
    sys.exit(res.returncode)

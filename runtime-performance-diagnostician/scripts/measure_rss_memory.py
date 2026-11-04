#!/usr/bin/env python3
"""Medidor determinístico de Pico de Memória RSS e Duração de Processo.

Suporta aquecimento (--warmup) e múltiplas repetições (--runs) com cálculo
de média, mediana e desvio-padrão, preservando stdout/stderr do processo alvo.
"""
from __future__ import annotations

import os
import resource
import shutil
import statistics
import subprocess
import sys
import tempfile
import time
from dataclasses import dataclass


@dataclass(frozen=True)
class RunSample:
    """Amostra individual de execução de um comando."""

    duration_ms: float
    max_rss_mb: float
    returncode: int


def parse_cli_args(argv: list[str]) -> tuple[int, int, list[str]]:
    """Extrai flags opcionais (--warmup, --runs) e o comando alvo."""
    warmup = 0
    runs = 1
    idx = 0
    while idx < len(argv):
        arg = argv[idx]
        if arg == "--":
            idx += 1
            break
        if arg == "--warmup" and idx + 1 < len(argv):
            warmup = max(0, int(argv[idx + 1]))
            idx += 2
            continue
        if arg == "--runs" and idx + 1 < len(argv):
            runs = max(1, int(argv[idx + 1]))
            idx += 2
            continue
        break
    cmd = argv[idx:]
    if not cmd:
        sys.stderr.write(
            "Uso: python3 measure_rss_memory.py [--warmup W] [--runs N] [--] <comando...>\n"
        )
        sys.exit(2)
    return warmup, runs, cmd


def _extract_rss_kb_from_time_file(time_output: str) -> float | None:
    """Extrai o pico de RSS (em KB) do relatório do GNU time (-v)."""
    for line in time_output.splitlines():
        if "Maximum resident set size" in line:
            parts = line.split(":")
            if len(parts) >= 2:
                try:
                    return float(parts[-1].strip())
                except ValueError:
                    return None
    return None


def execute_once(cmd: list[str], emit_output: bool) -> RunSample:
    """Executa o comando uma vez medindo duração wall-clock e pico de RSS."""
    env = {**os.environ, "LC_ALL": "C"}
    gnu_time = "/usr/bin/time" if os.path.exists("/usr/bin/time") else shutil.which("time")

    if gnu_time:
        with tempfile.NamedTemporaryFile(mode="r+", encoding="utf-8", delete=True) as tmp:
            start_time = time.perf_counter()
            res = subprocess.run(
                [gnu_time, "-v", "-o", tmp.name, "--"] + cmd,
                stdout=None if emit_output else subprocess.DEVNULL,
                stderr=None if emit_output else subprocess.DEVNULL,
                env=env,
            )
            duration_ms = (time.perf_counter() - start_time) * 1000.0
            tmp.seek(0)
            max_rss_kb = _extract_rss_kb_from_time_file(tmp.read())
    else:
        start_time = time.perf_counter()
        res = subprocess.run(
            cmd,
            stdout=None if emit_output else subprocess.DEVNULL,
            stderr=None if emit_output else subprocess.DEVNULL,
            env=env,
        )
        duration_ms = (time.perf_counter() - start_time) * 1000.0
        max_rss_kb = None

    if max_rss_kb is None:
        rusage_rss = resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss
        max_rss_kb = float(rusage_rss) / (1024.0 if sys.platform == "darwin" else 1.0)

    return RunSample(
        duration_ms=duration_ms,
        max_rss_mb=max_rss_kb / 1024.0,
        returncode=res.returncode,
    )


def main(argv: list[str]) -> int:
    """Ponto de entrada principal do medidor empírico."""
    warmup, runs, cmd = parse_cli_args(argv)
    sys.stderr.write(
        f"⏱️ Executando: {' '.join(cmd)} (warmup={warmup}, runs={runs})\n"
    )

    for _ in range(warmup):
        sample = execute_once(cmd, emit_output=False)
        if sample.returncode != 0:
            return sample.returncode

    samples: list[RunSample] = []
    for idx in range(runs):
        sample = execute_once(cmd, emit_output=(idx == 0))
        samples.append(sample)
        if sample.returncode != 0:
            break

    last = samples[-1]
    durations = [s.duration_ms for s in samples]
    rss_peaks = [s.max_rss_mb for s in samples]

    sys.stderr.write("\n--- RESULTADO DE MEDIÇÃO ---\n")
    status_str = "SUCESSO (exit 0)" if last.returncode == 0 else f"FALHA (exit {last.returncode})"
    sys.stderr.write(f"Status:       {status_str}\n")
    if len(durations) > 1:
        mean_ms = statistics.mean(durations)
        median_ms = statistics.median(durations)
        stdev_ms = statistics.stdev(durations)
        sys.stderr.write(
            f"Duração:      Média: {mean_ms:.2f} ms | Mediana: {median_ms:.2f} ms | σ: {stdev_ms:.2f} ms (n={len(durations)})\n"
        )
    else:
        sys.stderr.write(f"Duração:      {durations[0]:.2f} ms ({durations[0] / 1000.0:.3f} s)\n")
    sys.stderr.write(f"Pico de RSS:  {max(rss_peaks):.2f} MB\n")
    sys.stderr.write("----------------------------\n")
    return last.returncode


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

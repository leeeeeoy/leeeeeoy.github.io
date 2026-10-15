"""Validate raw measurements, summarize three-run variation, and plot without altering inputs."""
import csv
import hashlib
import json
import math
from pathlib import Path
import re
import statistics as stats

ROOT = Path(__file__).resolve().parents[1]
RESULTS = ROOT / "results/2026-10-14"
RESUME = RESULTS / "resume-2026-10-15"
CONDITIONS = [("fast", w) for w in [1,10,50,100,200]] + [("slow", w) for w in [1,10,50,100]] + [("cpu", w) for w in [1,2,4,8,16]]


def summarize(values):
    mean = stats.mean(values)
    return {"mean": mean, "min": min(values), "max": max(values), "sample_sd": stats.stdev(values), "cv_percent": stats.stdev(values)/mean*100 if mean else 0}


def quantile(bins, q):
    target = math.ceil(sum(bins)*q); count = 0
    for index, n in enumerate(bins):
        count += n
        if count >= target: return 1.02 ** index / 1000
    raise ValueError("empty histogram")


def main():
    preserved = json.loads((RESUME / "preserved-sha256.json").read_text())
    for name, checksum in preserved.items():
        path = RESULTS / name
        if name == "slow-c1-r3.json": path = RESUME / "slow-c1-r3.json.empty"
        assert hashlib.sha256(path.read_bytes()).hexdigest() == checksum, name
    resource_rows = list(csv.DictReader(open(RESULTS/"resource-samples.csv"))) + list(csv.DictReader(open(RESUME/"resource-samples.csv")))
    progress = json.loads((RESUME/"progress.json").read_text())
    runs=[]; summaries=[]
    for endpoint, workers in CONDITIONS:
        group=[]
        for repeat in [1,2,3]:
            label=f"{endpoint}-c{workers}-r{repeat}"
            path=RESULTS/(label+".json"); value=json.loads(path.read_text())
            assert not value["interrupted"] and value["requested_seconds"]==10 and value["elapsed_seconds"]>=10
            assert value["total"]==value["success"]+value["http_failures"]+value["transport_failures"]==sum(value["latency_bins"])
            assert len(value["latency_bins"])==2048
            assert math.isclose(value["rps"],value["total"]/value["elapsed_seconds"])
            for q,key in [(.5,"p50_ms_upper_bound"),(.95,"p95_ms_upper_bound"),(.99,"p99_ms_upper_bound")]:
                assert math.isclose(value[key],quantile(value["latency_bins"],q),rel_tol=1e-10)
            resumed = label in progress
            resource=json.loads((RESULTS/(label+".resources.json")).read_text())
            rows=[r for r in resource_rows if r["label"]==label and r["phase"]==("main-resumed" if resumed else "main")]
            row={"endpoint":endpoint,"workers":workers,"repeat":repeat,"session":"resumed-2026-10-15" if resumed else "original", **{k:v for k,v in value.items() if k!="latency_bins"},"server_cpu_percent_sample_interval":resource["server_cpu_seconds_delta"]/resource["sampling_wall_seconds"]*100,"client_cpu_percent":value["client_cpu_seconds"]/value["elapsed_seconds"]*100,"server_peak_sampled_rss_kib":max(int(r["rss_kib"]) for r in rows if r["role"]=="server")}
            runs.append(row);group.append(row)
        summary={"endpoint":endpoint,"workers":workers,"repeats":3}
        for key in ["rps","mean_ms","p50_ms_upper_bound","p95_ms_upper_bound","p99_ms_upper_bound"]:
            for statistic, number in summarize([r[key] for r in group]).items(): summary[key+"_"+statistic]=number
        summary["http_failures"]=sum(r["http_failures"] for r in group)
        summary["transport_failures"]=sum(r["transport_failures"] for r in group)
        summary["server_cpu_percent_mean"]=stats.mean(r["server_cpu_percent_sample_interval"] for r in group)
        summary["client_cpu_percent_mean"]=stats.mean(r["client_cpu_percent"] for r in group)
        summary["server_peak_sampled_rss_mib"]=max(r["server_peak_sampled_rss_kib"] for r in group)/1024
        summary["client_peak_rss_mib"]=max(r["client_peak_rss_kib"] for r in group)/1024
        summaries.append(summary)
    assert len(runs)==42
    for name, values in [("runs.csv",runs),("summary.csv",summaries)]:
        with open(RESULTS/name,"w",newline="") as stream:
            writer=csv.DictWriter(stream,fieldnames=list(values[0]));writer.writeheader();writer.writerows(values)
    (RESULTS/"summary.json").write_text(json.dumps(summaries,indent=2)+"\n")
    table=["| Endpoint | Workers | RPS mean | RPS min–max | RPS CV % | Mean ms | p50 ms | p95 ms | p99 ms |","|---|---:|---:|---:|---:|---:|---:|---:|---:|"]
    for s in summaries:
        table.append(f'| /{s["endpoint"]} | {s["workers"]} | {s["rps_mean"]:.2f} | {s["rps_min"]:.2f}–{s["rps_max"]:.2f} | {s["rps_cv_percent"]:.2f} | {s["mean_ms_mean"]:.3f} | {s["p50_ms_upper_bound_mean"]:.3f} | {s["p95_ms_upper_bound_mean"]:.3f} | {s["p99_ms_upper_bound_mean"]:.3f} |')
    (RESULTS/"summary.md").write_text("# Three-run descriptive summary\n\np50/p95/p99 columns are arithmetic means of each run's bucket-upper-bound quantiles, not pooled quantiles. CV = sample SD / mean. No confidence interval is claimed. Original and resumed sessions are combined with session labels in runs.csv.\n\n"+"\n".join(table)+"\n")
    # Load plotting only after all evidence checks, keeping the numerical audit independent.
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    plots=RESULTS/"plots";plots.mkdir(exist_ok=True)
    colors={"fast":"#2563eb","slow":"#16836b","cpu":"#b45309"}
    for metric, name, ylabel in [("rps","rps","Completed requests / second"),("p95_ms_upper_bound","p95","p95 latency (ms, bucket upper bound)"),("p99_ms_upper_bound","p99","p99 latency (ms, bucket upper bound)")]:
        fig, axes=plt.subplots(1,3,figsize=(12.8,3.9),constrained_layout=True)
        for ax,endpoint in zip(axes,["fast","slow","cpu"]):
            data=[s for s in summaries if s["endpoint"]==endpoint]
            x=[s["workers"] for s in data]; y=[s[metric+"_mean"] for s in data]
            lo=[s[metric+"_mean"]-s[metric+"_min"] for s in data];hi=[s[metric+"_max"]-s[metric+"_mean"] for s in data]
            ax.errorbar(x,y,yerr=[lo,hi],fmt="o-",capsize=4,color=colors[endpoint],linewidth=1.8)
            for run in [r for r in runs if r["endpoint"]==endpoint]:
                ax.scatter(run["workers"],run[metric],s=14,color=colors[endpoint],alpha=.45)
            ax.set_xscale("log");ax.set_xticks(x,[str(n) for n in x]);ax.set_xlabel("Concurrent workers")
            ax.set_title("/"+endpoint);ax.grid(alpha=.2);ax.set_ylim(bottom=0)
        axes[0].set_ylabel(ylabel)
        fig.suptitle("Mean and min–max of 3 runs; dots = individual runs (panels use separate y-scales)",fontsize=10)
        fig.savefig(plots/(name+".png"),dpi=170,facecolor="white")
        fig.savefig(plots/(name+".svg"),facecolor="white");plt.close(fig)
    print("Validated 42 results, preserved original hashes; wrote CSV/JSON/Markdown and three plots")


if __name__ == "__main__": main()

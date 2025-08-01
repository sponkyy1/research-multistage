#!/bin/bash
set -e

echo "🔨 Building images..."
docker build -f Dockerfile.single -t trivy-single .
docker build -f Dockerfile.multi -t trivy-multi .

mkdir -p results

echo "🔍 Scanning with Trivy..."
trivy image --severity HIGH,CRITICAL --format table trivy-single > results/single.txt
trivy image --severity HIGH,CRITICAL --format table trivy-multi > results/multi.txt

echo "🔬 Diffing results..."
diff results/single.txt results/multi.txt > results/diff.txt || true

echo "<html><body><h1>🧪 Trivy Vulnerability Report</h1>" > results/report.html
echo "<h2>Single-stage Result</h2><pre>" >> results/report.html
cat results/single.txt >> results/report.html
echo "</pre><h2>Multi-stage Result</h2><pre>" >> results/report.html
cat results/multi.txt >> results/report.html
echo "</pre><h2>Diff</h2><pre>" >> results/report.html
cat results/diff.txt >> results/report.html
echo "</pre>" >> results/report.html

# Math
single_count=$(grep -c "CVE-" results/single.txt || true)
multi_count=$(grep -c "CVE-" results/multi.txt || true)
echo "<h2>📊 Summary</h2><ul>" >> results/report.html
echo "<li>Single-stage CVEs: $single_count</li>" >> results/report.html
echo "<li>Multi-stage CVEs: $multi_count</li>" >> results/report.html
echo "<li>❗ Skipped CVEs (blind spot): $((single_count - multi_count))</li>" >> results/report.html
echo "</ul></body></html>" >> results/report.html

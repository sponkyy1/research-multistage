#!/bin/bash
set -e

echo "🔨 Building Docker images..."
docker build -f Dockerfile.single -t test-single .
docker build -f Dockerfile.multi -t test-multi .

mkdir -p results

echo "🔍 Running Grype scan on single-stage image..."
grype test-single > results/single.txt

echo "🔍 Running Grype scan on multi-stage image..."
grype test-multi > results/multi.txt

echo "🔬 Diffing results..."
diff results/single.txt results/multi.txt > results/diff.txt || true

echo "<html><body><h1>🧪 Grype Vulnerability Report</h1>" > results/report.html
echo "<h2>Single-stage Result</h2><pre>" >> results/report.html
cat results/single.txt >> results/report.html
echo "</pre><h2>Multi-stage Result</h2><pre>" >> results/report.html
cat results/multi.txt >> results/report.html
echo "</pre><h2>Diff</h2><pre>" >> results/report.html
cat results/diff.txt >> results/report.html
echo "</pre>" >> results/report.html

# Math: Count CVEs
single_count=$(grep -c "CVE-" results/single.txt || true)
multi_count=$(grep -c "CVE-" results/multi.txt || true)

echo "<h2>📊 Summary</h2><ul>" >> results/report.html
echo "<li>Single-stage CVEs: $single_count</li>" >> results/report.html
echo "<li>Multi-stage CVEs: $multi_count</li>" >> results/report.html
echo "<li>❗ Skipped CVEs (blind spot): $((single_count - multi_count))</li>" >> results/report.html
echo "</ul></body></html>" >> results/report.html

echo "✅ Done. Results in results/report.html"

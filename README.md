# 🧪 Grype and Trivy Multi-Stage Vulnerability Test

This project demonstrates how vulnerabilities in multi-stage Dockerfiles
may not be detected by Grype if they are present only in the build stage.

## 🔍 Test Plan

We compare:
- A **single-stage Dockerfile** with `wget` installed (vulnerable)
- A **multi-stage Dockerfile**, where `wget` is only in the `builder` stage

Grype is used to scan both images.
Results are saved as artifacts and as an HTML report.

📤 Output: `results/report.html`

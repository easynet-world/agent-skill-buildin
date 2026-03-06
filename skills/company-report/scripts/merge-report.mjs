#!/usr/bin/env node
import { existsSync } from "node:fs";
import { readFile, writeFile } from "node:fs/promises";
import { resolve } from "node:path";

export async function mergeReportHtml(jsonPath, htmlPath, templatePath) {
  if (!existsSync(jsonPath)) {
    throw new Error(`Missing JSON report: ${jsonPath}`);
  }
  if (!existsSync(templatePath)) {
    throw new Error(`Missing HTML template: ${templatePath}`);
  }

  const report = JSON.parse(await readFile(jsonPath, "utf8"));
  const template = await readFile(templatePath, "utf8");
  const html = template.replace(/__REPORT_JSON__/g, JSON.stringify(report));
  await writeFile(htmlPath, html, "utf8");
}

async function main() {
  const root = process.cwd();
  const jsonPath = resolve(root, process.argv[2] || "output/company-report.json");
  const htmlPath = resolve(root, process.argv[3] || "output/company-report.html");
  const templatePath = resolve(
    root,
    process.argv[4] || "skills/company-report/references/company-report.template.html",
  );

  await mergeReportHtml(jsonPath, htmlPath, templatePath);
  process.stdout.write(`Merged report written to: ${htmlPath}\n`);
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main().catch((error) => {
    process.stderr.write(`${error instanceof Error ? error.message : String(error)}\n`);
    process.exit(1);
  });
}


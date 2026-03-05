# Conventions for Company HTML Report (Bootstrap 5)

- **Framework:** Use **Bootstrap 5** only. Include the official Bootstrap 5.3 CSS and JS from jsDelivr CDN. No other CSS framework.
- **Language:** English. Use `lang="en"` on `<html>`.
- **Encoding:** UTF-8. Include `<meta charset="UTF-8" />` and `<meta name="viewport" content="width=device-width, initial-scale=1.0" />`.
- **Layout:** Wrap all main content in `<div class="container py-4">` for a centered, professional width. Use Bootstrap spacing classes (`mb-4`, `py-3`, etc.) between sections.
- **Title:** `<title>Company Report: [Full Company Name]</title>`. Page header: use a large heading (e.g. `display-5 fw-bold`) and the generation date in `text-muted`.
- **Sections:** Each of the four sections (Company Overview, Stock Data, News, Sources) must be inside a Bootstrap **card**: `card` > `card-header` (section title) + `card-body` (content). Use a consistent header style (e.g. `card-header` with blue background and white text).
- **Company overview:** For standard reports use 1–2 paragraphs; for **detailed analysis** use 2–4 paragraphs: company name, sector, business model, key products/services, market position, and brief outlook. Neutral, factual tone. Use "—" or "Not available" if data is missing.
- **Stock data:** Use a Bootstrap **table**: `table table-striped table-hover` inside `div class="table-responsive"`. Columns: Metric | Value. For "Change", use `span class="text-success"` for positive and `span class="text-danger"` for negative. For **detailed analysis**, add 1–2 sentences above the table (e.g. price trend, volume commentary).
- **News:** Use a list (e.g. `list-group list-group-flush` or `list-unstyled`). Each item: link (`<a href="…">`) with headline text; optionally `<small class="text-muted">` for date or source. For **detailed analysis**, add a 1–2 sentence summary or relevance per item. Add a subtle left border or spacing for readability (e.g. `.news-item`).
- **Sources:** List of source names as links in `list-unstyled`. Use descriptive link text (e.g. "Yahoo Finance – AAPL").
- **Colors:** Prefer Bootstrap primary blue (`#0d6efd`) for headers and accents; use `text-success` / `text-danger` only for positive/negative values.
- **Accessibility:** Heading order `h1` → `h2` (card headers can be styled as headings). Descriptive link text; avoid raw URLs as visible text.
- **No custom JavaScript:** Static HTML only; Bootstrap JS is optional for dropdowns/collapse but not required for the report.

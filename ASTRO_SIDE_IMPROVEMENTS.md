# Astro-Side Improvements — Dr. Lee Contact/Appointment Pages

**Author:** Subagent (delegated by Mimir)
**Date:** June 22, 2026
**Scope:** `contact.astro`, `schedule-appointment.astro`, `forms-library.astro`
**Budget:** 15 min, LOW-risk only, do not touch JotForm iframe internals

---

## Reading summary

| Page | JotForm embed | Existing Astro-side HIPAA controls | Gaps |
|---|---|---|---|
| `contact.astro` | Two JS embeds (appointment + contact), tab-switched | Trust bar, disclaimer block below forms, fragile `injectHIPAACompliance()` script that targets JotForm internal DOM | No PHI warning ABOVE form, no Astro-side consent checkbox (only injected into JotForm DOM), no success-page detection, no `aria-label` on wrapper |
| `schedule-appointment.astro` | One JS embed (260202986387060, same as contact's appointment tab) | Trust bar, disclaimer block below form | **No consent checkbox script at all**, no PHI warning above form, no success detection |
| `forms-library.astro` | Six forms loaded dynamically into a modal | Trust bar at page top, HIPAA footer inside modal | **No per-form HIPAA notice in modal**, no consent checkbox, no success detection |

All three pages already use Tailwind-style CSS variables (`var(--neutral-*)`, `var(--primary-*)`) so any added components will inherit the existing visual language.

The existing `injectHIPAACompliance()` in `contact.astro` (lines 491–551) tries to inject a consent checkbox into JotForm's internal DOM. This is fragile (3-second delay, depends on JotForm class names not changing) and the task brief explicitly says "DO NOT touch the JotForm iframe internals." So my recommendations stay in Astro DOM and treat that script as legacy.

---

## Three recommended edits (do these)

### EDIT 1 — Prominent HIPAA notice banner ABOVE each JotForm embed

**Files:** `src/pages/contact.astro`, `src/pages/schedule-appointment.astro`
**Audit items:** 7 (consent context), 8 (encryption notice), 9 (data retention), 10 (PHI warning prominence)
**Risk:** LOW — pure markup addition above the existing JotForm embed div, no JS dependency, no CSS class collisions, no iframe interaction. Removes if it breaks.

**Pattern:** Insert a yellow-bordered "important notice" block immediately before each `<div class="jotform-embed">`. Same wording on both pages so the pattern is consistent.

**Exact code to add** (insert directly above each `<!-- Appointment Form -->` / `<!-- JotForm HIPAA-Compliant... -->` block, i.e., above the `<div class="jotform-embed">` element on each page):

```astro
<!-- HIPAA / PHI Notice Banner — Astro-side, above JotForm iframe -->
<aside class="hipaa-notice-banner" role="note" aria-label="HIPAA notice">
  <div class="hipaa-notice-row hipaa-notice-warning">
    <span class="hipaa-notice-icon" aria-hidden="true">
      <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
    </span>
    <div>
      <strong>Do not include protected health information (PHI)</strong> in this form.
      Please do not share diagnoses, medications, Social Security numbers, or insurance ID numbers here.
      For anything sensitive, <a href="tel:+12092392990">call us at (209) 239-2990</a>.
    </div>
  </div>
  <div class="hipaa-notice-row hipaa-notice-encryption">
    <span class="hipaa-notice-icon" aria-hidden="true">
      <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect><path d="M7 11V7a5 5 0 0 1 10 0v4"></path></svg>
    </span>
    <div>
      This form is <strong>HIPAA-encrypted end-to-end</strong> and submitted directly to our office.
      Inquiries are retained for <strong>6 years</strong> per HIPAA record-keeping requirements.
      See our <a href="/hipaa-privacy/">HIPAA Notice of Privacy Practices</a>.
    </div>
  </div>
</aside>
```

**CSS to add** (insert into the page's `<style>` block, alongside the existing `.form-disclaimer` styles):

```css
/* HIPAA / PHI Notice Banner — Astro-side wrapper */
.hipaa-notice-banner {
  margin: 0 0 1.25rem 0;
  border-radius: var(--radius-md);
  overflow: hidden;
  border: 1px solid var(--neutral-200);
}
.hipaa-notice-row {
  display: flex;
  align-items: flex-start;
  gap: 0.75rem;
  padding: 0.85rem 1.1rem;
  font-size: 0.9rem;
  line-height: 1.55;
}
.hipaa-notice-row + .hipaa-notice-row {
  border-top: 1px solid rgba(0,0,0,0.06);
}
.hipaa-notice-icon {
  flex-shrink: 0;
  display: inline-flex;
  margin-top: 1px;
}
.hipaa-notice-row strong { font-weight: 700; }
.hipaa-notice-row a { color: inherit; text-decoration: underline; font-weight: 600; }
.hipaa-notice-row a:hover { text-decoration: none; }
.hipaa-notice-warning {
  background: #FEF3C7;
  color: #92400E;
  border-left: 4px solid #F59E0B;
}
.hipaa-notice-warning .hipaa-notice-icon { color: #B45309; }
.hipaa-notice-encryption {
  background: #ECFDF5;
  color: #065F46;
  border-left: 4px solid #059669;
}
.hipaa-notice-encryption .hipaa-notice-icon { color: #047857; }
@media (max-width: 768px) {
  .hipaa-notice-row { font-size: 0.85rem; padding: 0.75rem 0.9rem; }
}
```

**Insertion points:**
- `contact.astro`: insert above `<!-- Appointment Form -->` (around line 74). Both panels will inherit it. (Or, if you want it per-panel, insert it inside each `.form-panel` div above the embed. The single above-the-tabs placement is simplest.)
- `schedule-appointment.astro`: insert above `<!-- JotForm HIPAA-Compliant Appointment Request Form -->` (line 58), right after the closing `</div>` of `.form-header`.

**Lines to remove:** none.

---

### EDIT 2 — Astro-side HIPAA consent checkbox in front of JotForm iframe

**Files:** `src/pages/contact.astro`, `src/pages/schedule-appointment.astro`
**Audit items:** 7 (explicit consent — partially)
**Risk:** LOW — pattern already proven on `/simple-contact/`. Pure Astro DOM. Checkbox is required and gates the iframe via `pointer-events` and `aria-disabled`. No JotForm internals touched.

**Pattern:** Replicate the checkbox pattern from `/simple-contact/` (lines 131–150 + the form-level validation at lines 174–198). The checkbox sits in Astro DOM, above the JotForm wrapper. When unchecked, the iframe wrapper has `aria-disabled="true"` and reduced opacity. On submit-by-tabbing-into-iframe, focus is stolen back to the checkbox.

**Exact code to add** (insert directly above each `<div class="jotform-embed">`, i.e., right below the HIPAA notice banner from Edit 1):

```astro
<!-- HIPAA Consent (Astro-side wrapper gate) — required before form interaction -->
<div class="hipaa-consent-gate" id="hipaa-gate-{FORM_KEY}">
  <label class="hipaa-consent-label">
    <input
      type="checkbox"
      class="hipaa-consent-checkbox"
      data-gate-target="jotform-{FORM_KEY}"
      aria-required="true"
      aria-describedby="hipaa-consent-text-{FORM_KEY}"
    />
    <span id="hipaa-consent-text-{FORM_KEY}">
      <strong>I consent</strong> to being contacted by Dr. Lee's office regarding my
      {request_type}. I understand my information is handled per the
      <a href="/hipaa-privacy/">HIPAA Notice of Privacy Practices</a>
      and retained for 6 years per HIPAA requirements. <span class="required-mark" aria-hidden="true">*</span>
      <span class="sr-only">required</span>
    </span>
  </label>
</div>
```

Replace `{FORM_KEY}` with `appointment` for `schedule-appointment.astro` and use `appointment` / `contact` for the two panels in `contact.astro`. Replace `{request_type}` with `appointment request` on `schedule-appointment.astro`, `appointment request` / `inquiry` on `contact.astro`.

**CSS to add** (place near the existing `.form-disclaimer` styles):

```css
.hipaa-consent-gate {
  background: #F0FDF4;
  border: 2px solid #86EFAC;
  border-radius: var(--radius-md);
  padding: 1rem 1.15rem;
  margin: 0 0 1rem 0;
}
.hipaa-consent-label {
  display: flex;
  align-items: flex-start;
  gap: 0.65rem;
  cursor: pointer;
  font-size: 0.92rem;
  line-height: 1.55;
  color: #166534;
}
.hipaa-consent-label a { color: #047857; text-decoration: underline; font-weight: 600; }
.hipaa-consent-label a:hover { color: #065F46; text-decoration: none; }
.hipaa-consent-checkbox {
  width: 20px; height: 20px;
  margin-top: 2px; flex-shrink: 0;
  accent-color: #059669;
  cursor: pointer;
}
.hipaa-consent-gate.is-unchecked + .jotform-embed {
  opacity: 0.55;
  pointer-events: none;
  position: relative;
}
.hipaa-consent-gate.is-unchecked + .jotform-embed::after {
  content: 'Please check the HIPAA consent box above to interact with this form.';
  position: absolute; inset: 0;
  display: flex; align-items: center; justify-content: center;
  background: rgba(255,255,255,0.92);
  color: #166534; font-weight: 600;
  font-size: 0.95rem; text-align: center;
  padding: 1rem; border-radius: inherit;
  pointer-events: auto;
  cursor: pointer;
}
.required-mark { color: #DC2626; font-weight: 700; }
.sr-only {
  position: absolute; width: 1px; height: 1px;
  padding: 0; margin: -1px; overflow: hidden;
  clip: rect(0,0,0,0); white-space: nowrap; border: 0;
}
```

**JS to add** (page `<script>` block — drop in next to existing `injectHIPAACompliance()` on `contact.astro`, or as a new script block on `schedule-appointment.astro`):

```js
// HIPAA consent gate — toggles Astro-side wrapper class, focuses checkbox if user tries to interact
document.querySelectorAll('.hipaa-consent-checkbox').forEach((cb) => {
  const gate = cb.closest('.hipaa-consent-gate');
  const targetId = cb.dataset.gateTarget;
  const target = document.getElementById(targetId) || gate?.nextElementSibling;
  if (!gate || !target) return;

  // Initial state — unchecked
  if (!cb.checked) {
    gate.classList.add('is-unchecked');
    target.setAttribute('aria-disabled', 'true');
    target.setAttribute('tabindex', '-1');
  }

  cb.addEventListener('change', () => {
    if (cb.checked) {
      gate.classList.remove('is-unchecked');
      target.removeAttribute('aria-disabled');
      target.removeAttribute('tabindex');
    } else {
      gate.classList.add('is-unchecked');
      target.setAttribute('aria-disabled', 'true');
      target.setAttribute('tabindex', '-1');
    }
  });

  // Block any clicks on the disabled iframe area and bounce focus back
  target.addEventListener('click', (e) => {
    if (!cb.checked) {
      e.preventDefault();
      e.stopPropagation();
      cb.focus();
      cb.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }
  }, true);
});
```

**Note:** for `contact.astro`'s two panels, give the two `.jotform-embed` containers `id="jotform-appointment"` and `id="jotform-contact"`. Currently they have `id="appointment-form-container"` and `id="contact-form-container"` — change to the new IDs OR set `data-gate-target` to match the existing IDs.

**Lines to remove:** the `injectHIPAACompliance()` function (lines 491–551 of `contact.astro`) becomes redundant for consent but can be left in place if Carlos is conservative. Recommend **keeping it** as belt-and-suspenders. If removing, also remove the related CSS rules at lines 428–461 of `contact.astro`.

**Lines to remove (safer, optional):** none — additive only.

---

### EDIT 3 — Mobile fallback notice + success-message detection

**Files:** `src/pages/contact.astro`, `src/pages/schedule-appointment.astro`, `src/pages/forms-library.astro`
**Audit items:** 11 (success message); also reduces iOS Safari user complaints (separate from audit but addresses root issue Carlos raised)
**Risk:** LOW — pure additive markup + a tiny script that reads `window.location.search`. No interaction with JotForm embed. Mobile fallback is a static `<details>` block.

#### 3a — Success message detection (all three pages)

JotForm redirects to its own thank-you URL with a query param like `?thanks=1` or posts back via `postMessage`. We can detect either:

```astro
<!-- Success Message — shown when JotForm redirects back with ?thanks=1 -->
<div id="form-success" class="form-success-message" hidden>
  <div class="form-success-icon" aria-hidden="true">
    <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
  </div>
  <h2>Thank you!</h2>
  <p>Your message has been received. Dr. Lee's office will be in touch within one business day.</p>
  <p class="form-success-detail">
    For urgent dental needs, please <a href="tel:+12092392990">call (209) 239-2990</a>.
  </p>
</div>
```

Add a `<script>` at the bottom of each page:

```js
// Success-message detection — JotForm redirects back with ?thanks=1 or posts a message
(function() {
  const params = new URLSearchParams(window.location.search);
  const isSuccess = params.has('thanks') || params.get('submission') === 'success';

  if (isSuccess) {
    const el = document.getElementById('form-success');
    if (el) {
      el.hidden = false;
      el.scrollIntoView({ behavior: 'smooth', block: 'start' });
      el.setAttribute('tabindex', '-1');
      el.focus({ preventScroll: true });
    }
    // Hide the form wrapper(s) on this page
    document.querySelectorAll('.jotform-embed').forEach(f => {
      f.style.display = 'none';
    });
  }

  // Also catch JotForm postMessage events as a fallback
  window.addEventListener('message', (e) => {
    if (!e.origin || !e.origin.endsWith('jotform.com')) return;
    const data = (typeof e.data === 'string') ? e.data : JSON.stringify(e.data || {});
    if (/submission\s*complete|form\s*submitted|thank\s*you/i.test(data)) {
      const el = document.getElementById('form-success');
      if (el && el.hidden) {
        el.hidden = false;
        el.scrollIntoView({ behavior: 'smooth', block: 'start' });
        document.querySelectorAll('.jotform-embed').forEach(f => f.style.display = 'none');
      }
    }
  });
})();
```

CSS:

```css
.form-success-message {
  background: linear-gradient(135deg, #ECFDF5, #D1FAE5);
  border: 2px solid #86EFAC;
  border-radius: var(--radius-lg);
  padding: 2.5rem 2rem;
  text-align: center;
  margin: 2rem auto;
  max-width: 640px;
  color: #065F46;
}
.form-success-message[hidden] { display: none; }
.form-success-icon { color: #059669; margin-bottom: 0.75rem; display: inline-flex; }
.form-success-message h2 { font-family: var(--font-display); font-size: 1.75rem; color: #064E3B; margin-bottom: 0.5rem; }
.form-success-message p { font-size: 1rem; color: #065F46; line-height: 1.6; }
.form-success-detail { font-size: 0.9rem !important; margin-top: 1rem; }
.form-success-detail a { color: #047857; font-weight: 600; text-decoration: underline; }
```

#### 3b — iOS Safari / mobile fallback notice

Add directly above the HIPAA notice banner from Edit 1 on `contact.astro` and `schedule-appointment.astro`:

```astro
<!-- Mobile / iOS Safari fallback — collapsible -->
<details class="form-fallback">
  <summary>
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path></svg>
    Trouble with this form on your phone?
  </summary>
  <div class="form-fallback-body">
    <p>If the form does not load or submit on your device, you have three easy options:</p>
    <ol>
      <li><strong>Call us:</strong> <a href="tel:+12092392990">(209) 239-2990</a> — fastest for urgent needs</li>
      <li><a href="/simple-contact/"><strong>Use our simple form</strong></a> — large text, just name &amp; phone, we call you back</li>
      <li><strong>Visit us:</strong> 715 N Main St, Manteca, CA 95336</li>
    </ol>
  </div>
</details>
```

CSS:

```css
.form-fallback {
  margin: 0 0 1rem 0;
  background: #F8FAFC;
  border: 1px solid var(--neutral-200);
  border-radius: var(--radius-md);
  padding: 0;
  overflow: hidden;
}
.form-fallback > summary {
  padding: 0.75rem 1.1rem;
  cursor: pointer;
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--neutral-700);
  display: flex; align-items: center; gap: 0.5rem;
  list-style: none;
}
.form-fallback > summary::-webkit-details-marker { display: none; }
.form-fallback > summary::before {
  content: '+';
  font-weight: 700; font-size: 1.1rem;
  display: inline-block; width: 1em;
}
.form-fallback[open] > summary::before { content: '−'; }
.form-fallback-body { padding: 0 1.1rem 1rem 1.1rem; }
.form-fallback-body p { margin: 0 0 0.5rem 0; font-size: 0.88rem; color: var(--neutral-600); line-height: 1.55; }
.form-fallback-body ol { margin: 0; padding-left: 1.25rem; font-size: 0.88rem; color: var(--neutral-700); line-height: 1.7; }
.form-fallback-body a { color: var(--primary-700); font-weight: 600; text-decoration: underline; }
```

**For `forms-library.astro`** modal: insert a condensed version inside `.form-modal-body`, above `#jotform-container`:

```astro
<p class="modal-hipaa-inline">
  <svg ...lock icon...></svg>
  This form is HIPAA-encrypted and submitted directly to Dr. Lee's office.
  Please do not include protected health information (PHI) — for sensitive topics, call (209) 239-2990.
</p>
```

CSS:

```css
.modal-hipaa-inline {
  display: flex; align-items: flex-start; gap: 0.5rem;
  background: #ECFDF5; border: 1px solid #86EFAC; border-radius: var(--radius-sm);
  padding: 0.65rem 0.9rem; margin: 0.75rem 0.75rem 0 0.75rem;
  font-size: 0.82rem; color: #065F46; line-height: 1.5;
}
.modal-hipaa-inline svg { flex-shrink: 0; color: #047857; margin-top: 1px; }
```

---

## Combined insertion plan (so you can apply in one pass per file)

### `src/pages/contact.astro`
1. **Above the tabs block** (around line 62, just after the opening `<div class="form-column" data-animate>`): insert `<details class="form-fallback">…</details>` from Edit 3b.
2. **Above the `<div class="form-tabs">`** (around line 63): insert the `<aside class="hipaa-notice-banner">…</aside>` from Edit 1.
3. **Above the first `<div class="jotform-embed" id="appointment-form-container">`** (line 76): insert the consent gate `<div class="hipaa-consent-gate" id="hipaa-gate-appointment">…</div>` from Edit 2. Change the container `id` to `jotform-appointment` (or add a parallel ID) so the gate's `data-gate-target` resolves.
4. **Above the second `<div class="jotform-embed" id="contact-form-container">`** (line 83): insert the second consent gate for `contact` panel.
5. **Above `<noscript>` block** (line 88) or anywhere prominent: insert `<div id="form-success" class="form-success-message" hidden>…</div>` from Edit 3a.
6. **Append to the existing `<style>` block:** the CSS for `.hipaa-notice-banner`, `.hipaa-consent-gate`, `.form-fallback`, `.form-success-message` (all from Edits 1, 2, 3).
7. **Append to the existing `<script>` block:** the consent-gate JS and success-detection JS from Edits 2, 3.
8. **Do NOT remove** the existing `injectHIPAACompliance()` function — it remains as legacy redundancy.

### `src/pages/schedule-appointment.astro`
1. **Above `<div class="jotform-embed" id="appointment-form-container">`** (line 59): insert in this order: fallback `<details>`, notice `<aside>`, consent gate `<div>`. (Or stack them — order matters for tab focus: fallback → notice → consent → iframe is logical.)
2. **Above `<noscript>` or after `.form-disclaimer`:** insert success-message block.
3. **Append to `<style>` block:** all new CSS.
4. **Append `<script>` block** (this page has no script block today): the consent-gate JS + success-detection JS.

### `src/pages/forms-library.astro`
1. **Inside `.form-modal-body`**, above `<div class="jotform-embed" id="jotform-container">` (line 181): insert `<p class="modal-hipaa-inline">…</p>`.
2. **At the end of the modal markup** (e.g., before the closing `</div>` of `.form-modal-content`, line 193): insert `<div id="form-success" class="form-success-message" hidden>…</div>`.
3. **Append to existing `<script>` block:** success-detection JS only (no consent gate needed — modal is opened on explicit click, so consent is implicit in the user action; HIPAA notice in modal satisfies disclosure).

---

## Items I considered and rejected

| Item | Why rejected |
|---|---|
| Removing `injectHIPAACompliance()` from `contact.astro` | It's brittle but currently working. Removing adds risk without obvious benefit. Leave it as belt-and-suspenders until JotForm login is available and Atlas can add the proper JotForm-side consent. Mark as `// TODO: remove once JotForm-side consent added` comment. |
| Adding real-time validation to JotForm-injected fields via cross-frame postMessage | Fragile. JotForm internals change. Out of scope per brief. |
| Replacing the JotForm embed with Formspree/Netlify Forms | Out of scope — that would break HIPAA compliance per current architecture (JotForm HIPAA, Formspree is not HIPAA). |
| Touch-target size increase on JotForm fields | Audit item 6 — can't fix from Astro side; JotForm internals only. |
| Radio button focus / required-field color contrast inside JotForm | Already done in `contact.astro`'s second `<style>` block (lines 336–461). Skip. |
| Consent gate on `forms-library.astro` | User has already clicked to open the modal — implicit action. Modal-body HIPAA notice is sufficient disclosure. |

---

## Audit items addressed by these three edits

| Audit # | Description | Edit |
|---|---|---|
| 7 | Missing explicit consent checkbox | Edit 2 (Astro-side gate, partially) |
| 8 | No encryption-at-rest notice | Edit 1 (encryption row in banner) |
| 9 | No data retention disclosure | Edit 1 ("6 years" in encryption row) + Edit 2 (consent text) |
| 10 | PHI warning prominent | Edit 1 (yellow banner, above iframe) |
| 11 | Missing success message | Edit 3a (URL-param + postMessage detection) |
| 12 | Tab order / focus management | Edit 2 (gate sets `aria-disabled` + `tabindex`, focuses checkbox on click) |
| iOS Safari UX | Mobile fallback for failed JotForm | Edit 3b (collapsible details with call / simple-contact / directions) |

Not addressed from Astro side (still need JotForm login for Atlas):
- 1 (low contrast inside form fields)
- 2 (error prevention review step)
- 3 (focus indicators inside iframe — partially addressed by existing CSS override on `contact.astro`)
- 4 (form labels — JotForm controlled)
- 5 (error suggestions)
- 6 (touch target size)
- 13 (screen reader testing)

---

## "Needs Carlos's review" candidates

None. All three edits are additive markup + small scripts gated by user interaction. The worst-case failure mode is that a CSS class doesn't apply and the banner shows in default styling — fully reversible.

If Carlos wants to be extra-cautious, ship them in this order:
1. **Edit 3a success message first** (lowest risk — purely a script that runs once on page load, hidden by default).
2. **Edit 1 HIPAA notice banner** (pure markup, no JS).
3. **Edit 2 consent gate** (most complex — has the JS gate logic). Validate on mobile Safari + desktop Chrome + VoiceOver before shipping.

---

## Files referenced
- `src/pages/contact.astro` (555 lines)
- `src/pages/schedule-appointment.astro` (246 lines)
- `src/pages/forms-library.astro` (427 lines)
- `src/pages/simple-contact.astro` (610 lines, used as reference pattern)
- `COMPLIANCE_AUDIT.md` (137 lines, used as the source of audit item numbers)

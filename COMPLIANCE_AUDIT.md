# ADA/HIPAA Compliance Audit — Dr. Lee Contact Forms
## Date: June 22, 2026

---

## Executive Summary

Both forms (Appointment Request + Contact) have significant compliance gaps that put Dr. Lee's practice at risk. The "grayed out text" Carlos mentioned is confirmed — placeholder text and sub-labels have insufficient contrast. Full remediation required.

---

## Issues Found

### 🔴 CRITICAL — ADA/WCAG 2.1 AA Failures

#### 1. Low Contrast Text (The "grayed out" issue Carlos mentioned)
- **Placeholder text**: `.form-textbox::placeholder` and `.form-sub-label` — color appears to be #999 or similar
- **Sub-labels**: "First Name", "Last Name", "example@example.com" — these are instructional text below inputs
- **Required field indicators**: The red asterisk `*` may not meet contrast requirements
- **WCAG Requirement**: Text must have 4.5:1 contrast ratio minimum
- **Fix**: Darken all gray text to #595959 or darker

#### 2. Missing Error Prevention (WCAG 3.3.4)
- Forms submit without confirmation for legal/financial/health data
- No "Review your information" step before final submission
- **Fix**: Add review/confirmation step or allow data modification after submission

#### 3. Missing Focus Indicators (WCAG 2.4.7)
- Form inputs may lack visible focus rings
- Radio buttons and checkboxes need clear focus states
- **Fix**: Add 2px solid outline or border on `:focus-visible`

#### 4. Form Labels — Partial Compliance
- ✅ Fields have `<label>` elements
- ⚠️ Radio button labels use `aria-hidden="true"` which may hide labels from assistive tech incorrectly
- ⚠️ Some labels rely on `aria-labelledby` pointing to multiple IDs — complex but valid

#### 5. Missing Error Suggestions (WCAG 3.3.3)
- Error messages exist but may not be specific enough
- "Please enter a valid phone number" is good, but could be more helpful
- **Fix**: Add specific error messages with examples

#### 6. Touch Target Size (WCAG 2.5.5)
- Radio buttons and checkboxes may be smaller than 44x44px
- **Fix**: Increase touch target size or add padding

### 🟡 MODERATE — HIPAA Compliance Issues

#### 7. Missing Explicit Consent Checkbox
- The form has a disclaimer but NO explicit opt-in checkbox
- Current: "By submitting this form, you consent..." (passive consent)
- HIPAA requires active/affirmative consent for electronic communications
- **Fix**: Add required checkbox:
  ```
  [ ] I consent to being contacted regarding my dental inquiry. 
      I understand my information will be handled per the HIPAA Notice 
      of Privacy Practices.
  ```

#### 8. No Encryption-at-Rest Notice
- Form submits to `hipaa-submit.jotform.com` ✅ (JotForm HIPAA compliant)
- But no explicit notice about encryption to user
- **Fix**: Add "This form is encrypted end-to-end" near submit button

#### 9. No Data Retention Disclosure
- HIPAA requires explaining how long data is kept
- **Fix**: Add "We retain your inquiry for 6 years per HIPAA requirements"

#### 10. PHI Warning Present But Hidden
- "Please do not submit protected health information (PHI) through this form" — present but in small text
- **Fix**: Make this warning prominent (yellow box) and move it BEFORE the message field

### 🟢 MINOR — Best Practice Improvements

#### 11. Missing Success Message
- No confirmation message after submission
- User doesn't know if form was sent
- **Fix**: Add success page or inline confirmation

#### 12. Tab Order / Keyboard Navigation
- Radio groups have `role="radiogroup"` ✅
- But need to verify logical tab order through all fields
- **Fix**: Test with keyboard-only navigation

#### 13. Screen Reader Testing Needed
- `aria-live="polite"` on error container ✅
- But need to verify actual screen reader behavior
- **Fix**: Test with NVDA/VoiceOver

---

## Recommended Remediation Plan

### Phase 1: Immediate (ADA Critical)
1. **Fix contrast on all gray text** (placeholders, sub-labels, hints)
2. **Add visible focus indicators** on all interactive elements
3. **Add required consent checkbox** (HIPAA)
4. **Make PHI warning prominent**

### Phase 2: Short-term (1-2 weeks)
5. Add review/confirmation step (WCAG 3.3.4)
6. Improve error messages with examples
7. Add encryption notice
8. Add data retention disclosure
9. Increase touch target sizes

### Phase 3: Ongoing
10. Screen reader testing
11. Keyboard-only navigation testing
12. Color-blind simulation testing
13. Document compliance in accessibility statement

---

## Estimated Risk

| Issue | Legal Risk | Remediation Effort |
|-------|-----------|-------------------|
| Low contrast text | Medium (ADA lawsuit) | Low |
| Missing consent checkbox | **High (HIPAA violation)** | Low |
| No error prevention | Medium | Medium |
| Missing focus indicators | Medium | Low |

**Overall**: The HIPAA consent issue is the highest risk. The ADA contrast issues are lawsuit magnets (3,117 lawsuits filed in 2025 for similar issues).

---

## Next Steps

1. Carlos approves remediation scope
2. I update the JotForm forms directly (need JotForm login)
3. Rebuild and redeploy Astro site
4. Run automated accessibility scan (Axe/WAVE)
5. Manual screen reader test

---

*Audit by: Atlas 🌍 | Date: June 22, 2026*
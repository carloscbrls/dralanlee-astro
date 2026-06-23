# Deployment Guide — DrAlanLee.com

## The Golden Rule
**Never deploy forms without iOS Safari testing.**

## Quick Deploy (When Not Changing Forms)
```bash
cd /Users/cc3po/.openclaw/workspace/dralanlee-astro
npm run build
npx netlify deploy --prod --dir=dist
```

## Full Deploy (When Forms Change — Mandatory)
```bash
cd /Users/cc3po/.openclaw/workspace/dralanlee-astro

# Step 1: Build
npm run build

# Step 2: Run iOS pre-deploy checks
bash scripts/pre-deploy-check.sh

# Step 3: If checks pass, deploy
npx netlify deploy --prod --dir=dist

# Step 4: Purge Cloudflare cache (forms are proxied)
curl -X POST "https://api.cloudflare.com/client/v4/zones/ZONE_ID/purge_cache" \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data '{"purge_everything":true}'

# Step 5: Test on iPhone (physical device)
# Open Safari → dralanlee.com/contact → Test form
# Open Safari → dralanlee.com/schedule-appointment → Test form
```

## iOS Testing Checklist
Before marking deploy as complete:

- [ ] iPhone Safari: Form loads without errors
- [ ] iPhone Safari: Can tap all input fields
- [ ] iPhone Safari: Native date picker works (if applicable)
- [ ] iPhone Safari: File upload opens camera roll (if applicable)
- [ ] iPhone Safari: Submit button responds to tap
- [ ] iPhone Safari: Success message appears after submit
- [ ] iPhone Safari: No horizontal scroll or zoom issues
- [ ] Chrome iOS: Repeat above checks

## Emergency Rollback
If forms break after deploy:
```bash
# Option 1: Netlify rollback (fastest)
# Log into Netlify dashboard → Deploys → Previous deploy → Publish

# Option 2: Git revert
git revert HEAD
npm run build
npx netlify deploy --prod --dir=dist
```

## What Breaks on iOS Safari
| Component | iOS Issue | Prevention |
|-----------|-----------|------------|
| JotForm iframe | Scroll trapping, submit failures | Always use JS embed |
| Date inputs | Custom styling breaks native picker | Test with `type="date"` |
| File uploads | Camera roll access blocked | Add `accept="image/*" capture` |
| Viewport | `user-scalable=no` blocks zoom | Remove it |
| Font sizes | < 16px causes zoom on focus | Minimum 16px for inputs |
| Touch targets | < 44px hard to tap | Use padding, not just margins |

## Troubleshooting

### "Form not loading on iPhone"
1. Check if JotForm URL uses HTTPS
2. Verify JS embed code (not iframe)
3. Check browser console for CSP errors

### "Can't submit form on iPhone"
1. Check if submit button has `type="submit"`
2. Verify button isn't covered by fixed elements
3. Test with iOS simulator in Xcode

### "Date picker broken on iPhone"
1. Use native `input type="date"` (not custom JS picker)
2. Ensure `-webkit-appearance: none` isn't hiding it
3. Test on actual device, not just simulator

## Automation Roadmap
- [ ] GitHub Actions CI with iOS Safari tests
- [ ] Firecrawl monitor for weekly form regression checks
- [ ] Uptime Kuma monitoring on form endpoints
- [ ] Automated iOS screenshot testing via BrowserStack

## Contact
If deploy fails or iOS issues persist:
- Check Netlify deploy logs
- Test on BrowserStack iPhone simulator
- Review Cloudflare caching headers
- Verify JotForm status page (status.jotform.com)

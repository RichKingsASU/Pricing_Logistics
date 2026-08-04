import { test, expect } from '@playwright/test';

test('has title', async ({ page }) => {
  await page.goto('/');

  // Expect a title "to contain" a substring.
  // Adjust this once you know what your app's actual title is!
  await expect(page).toHaveTitle(/Pricing Hub/);
});
